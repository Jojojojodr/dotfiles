#!/usr/bin/env bash

titleBar() {
    cat << "EOF"
|========================================================|
|---  Setting up the system for a Fedora environment  ---|
|========================================================|
EOF
}

add_docker_repository() {
    echo "Adding the official Docker CE repository..."
    sudo dnf -y install ca-certificates curl
    sudo curl -fsSL https://download.docker.com/linux/fedora/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo
}

# Enable a COPR repo, falling back to another chroot when the project
# has no build for the running Fedora release (e.g. only rawhide)
enable_copr() {
    local project="$1"
    local release arch
    release="$(rpm -E %fedora)"
    arch="$(uname -m)"

    local chroots=("fedora-$release-$arch" "fedora-rawhide-$arch")
    for ((v = release - 1; v >= release - 3; v--)); do
        chroots+=("fedora-$v-$arch")
    done

    for chroot in "${chroots[@]}"; do
        if sudo dnf -y copr enable "$project" "$chroot" &> /dev/null; then
            echo "Enabled COPR $project ($chroot)"
            return 0
        fi
    done

    echo "Warning: could not enable COPR $project for any known chroot, skipping." >&2
    return 0
}

add_third_party_repositories() {
    echo "Adding third-party and COPR repositories..."

    # COPR support (dnf5 vs classic dnf provide the copr command differently)
    if dnf --version 2> /dev/null | grep -q 'dnf5'; then
        sudo dnf -y install dnf5-plugins
    else
        sudo dnf -y install dnf-plugins-core
    fi

    # Hyprland ecosystem (provides hyprshot) via the solopasha COPR
    enable_copr solopasha/hyprland

    # Ghostty via the upstream-recommended COPR
    enable_copr scottames/ghostty

    # Brave Browser (official vendor repository)
    sudo curl -fsSL https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo -o /etc/yum.repos.d/brave-browser.repo
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

    # Visual Studio Code (official Microsoft repository)
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo tee /etc/yum.repos.d/vscode.repo > /dev/null << 'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
}

update_system() {
    echo "Updating system packages..."
    add_docker_repository
    add_third_party_repositories
    sudo dnf -y upgrade --refresh
}

is_installed() {
    rpm -q "$1" &> /dev/null
}

install_packages() {
    local packages=("$@")
    local to_install=()

    for pkg in "${packages[@]}"; do
        if ! is_installed "$pkg"; then
            to_install+=("$pkg")
        else
            echo "Package '$pkg' is already installed."
        fi
    done

    if [ ${#to_install[@]} -ne 0 ]; then
        echo "Installing packages: ${to_install[*]}"
        sudo dnf install -y --skip-broken "${to_install[@]}"
    else
        echo "All specified packages are already installed."
    fi
}

build_wayle() {
    if [ -x "$HOME/.local/bin/wayle" ]; then
        echo "wayle is already installed."
        return
    fi

    echo "Building wayle from source (not packaged for Fedora)..."
    sudo dnf install -y git cmake pkgconf-pkg-config gtk4-devel gtk4-layer-shell-devel \
        gtksourceview5-devel pulseaudio-libs-devel fftw-devel pipewire-devel \
        systemd-devel libxkbcommon-devel wayland-devel clang gcc

    # Build on disk instead of /tmp (tmpfs on Fedora, so it eats RAM)
    local build_dir="$HOME/.cache/wayle-build"
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    git clone --depth 1 https://github.com/wayle-rs/wayle "$build_dir/wayle"

    # The release profile uses LTO, which needs a lot of memory per rustc job;
    # allow roughly one job per 2.5 GB of RAM so the OOM killer stays away
    local mem_kb jobs
    mem_kb="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
    jobs=$((mem_kb / 2500000))
    [ "$jobs" -lt 1 ] && jobs=1
    [ "$jobs" -gt "$(nproc)" ] && jobs="$(nproc)"
    echo "Compiling with $jobs parallel job(s)..."

    # Share one target dir so common dependencies are only compiled once
    export CARGO_TARGET_DIR="$build_dir/target"

    # wayle's release profile sets lto = true and codegen-units = 1, which
    # makes rustc hold an entire crate (wayle-shell is huge) in memory at
    # once. Thin LTO with more codegen units uses far less RAM.
    export CARGO_PROFILE_RELEASE_LTO=thin
    export CARGO_PROFILE_RELEASE_CODEGEN_UNITS=16
    cargo install -j "$jobs" --path "$build_dir/wayle/wayle" --root "$HOME/.local"
    cargo install -j "$jobs" --path "$build_dir/wayle/crates/wayle-settings" --root "$HOME/.local"
    unset CARGO_TARGET_DIR CARGO_PROFILE_RELEASE_LTO CARGO_PROFILE_RELEASE_CODEGEN_UNITS

    (cd "$build_dir/wayle" && "$HOME/.local/bin/wayle" icons setup)

    rm -rf "$build_dir"
}

install_system() {
    local dev_only="$1"

    # Install system packages
    echo "Installing system packages..."
    install_packages "${SYSTEM_PACKAGES[@]}"

    # Install development packages
    echo "Installing development packages..."
    install_packages "${DEV_PACKAGES[@]}"
    install_packages "${FEDORA_DEV_PACKAGES[@]}"

    if [ "$dev_only" = true ]; then
        echo "Development-only mode enabled. Skipping additional packages."
    else
        echo "Installing desktop packages..."
        install_packages "${DESKTOP_PACKAGES[@]}"

        xdg-user-dirs-update

        build_wayle

        # Install additional packages
        echo "Installing additional packages..."
        install_packages "${ADDITIONAL_PACKAGES[@]}"
        install_packages "${FEDORA_ADDITIONAL_PACKAGES[@]}"
    fi
}
