#!/usr/bin/env bash

titleBar() {
    cat << "EOF"
|===============================================================|
|---  Setting up the system for a Debian/Ubuntu environment  ---|
|===============================================================|
EOF
}

add_docker_repository() {
    sudo apt update
    sudo apt install ca-certificates curl

    # 1. Ensure keyrings directory exists
    sudo install -m 0755 -d /etc/apt/keyrings

    # 2. Download the official Docker GPG key
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # 3. Read the OS codename into a variable
    . /etc/os-release

    # 4. Write the repository list file using the evaluated variable
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME:-$VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
}

update_system() {
    echo "Updating system packages..."
    add_docker_repository
    sudo apt update && sudo apt upgrade -y
}

is_installed() {
    dpkg -l | grep -qw "$1"
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
        sudo apt install -y "${to_install[@]}"
    fi
}

install_desktop_stack() {
    # install dependenties
    install_packages "${DEB_DESKTOP_DEPENDENCIES_PACKAGES[@]}"

    # create work directory
    cd ~
    if [ -d "install-hyprland" ]; then
        rm -rf install-hyprland
    fi
    mkdir install-hyprland
    cd install-hyprland

    # install hyprwayland-scanner
    git clone https://github.com/hyprwm/hyprwayland-scanner.git
    cd hyprwayland-scanner
    cmake -DCMAKE_INSTALL_PREFIX=/usr -B build
    cmake --build build -j$(nproc)
    sudo cmake --install build
    cd ..

    # install hyprutils
    git clone https://github.com/hyprwm/hyprutils.git
    cd hyprutils
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local -B build
    cmake --build build -j$(nproc)
    sudo cmake --install build
    cd ..

    # install aquamarine
    git clone https://github.com/hyprwm/aquamarine.git
    cd aquamarine
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local -B build
    cmake --build build -j$(nproc)
    sudo cmake --install build
    cd ..

    # install wayland-protocols
    git clone https://gitlab.freedesktop.org/wayland/wayland-protocols.git
    cd wayland-protocols
    meson setup build --prefix=/usr
    ninja -C build
    sudo ninja -C build install
    cd ..

    # install hyprland
    git clone --recursive https://github.com/hyprwm/Hyprland
    cd Hyprland
    make all && sudo make install
    cd ..

    # install hyprwire
    git clone https://github.com/hyprwm/hyprwire.git
    cd hyprwire
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local -B build
    cmake --build build -j$(nproc)
    sudo cmake --install build
    cd ..

    # install hyprgraphics
    git clone https://github.com/hyprwm/hyprgraphics.git
    cd hyprgraphics
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local -B build
    cmake --build build -j$(nproc)
    sudo cmake --install build
    cd ..

    # install hyprtoolkit
    git clone https://github.com/hyprwm/hyprtoolkit.git
    cd hyprtoolkit
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local -B build
    cmake --build build -j$(nproc)
    sudo cmake --install build
    cd ..

    # install hyprpaper
    git clone --recursive https://github.com/hyprwm/hyprpaper
    cd hyprpaper
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target hyprpaper -j`nproc 2>/dev/null || getconf _NPROCESSORS_CONF`
    cmake --install ./build
    cd ..

    # install hyprpicker
    git clone --recursive https://github.com/hyprwm/hyprpicker
    cd hyprpicker
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target hyprpicker -j`nproc 2>/dev/null || getconf _NPROCESSORS_CONF`
    cmake --install ./build
    cd ..

    # install hyprshot
    git clone https://github.com/Gustash/hyprshot.git Hyprshot
    ln -s $(pwd)/Hyprshot/hyprshot $HOME/.local/bin
    chmod +x Hyprshot/hyprshot

    # install hyprlock
    git clone --recursive https://github.com/hyprwm/hyprlock
    cd hyprlock
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -S . -B ./build
    cmake --build ./build --config Release --target hyprlock -j`nproc 2>/dev/null || getconf _NPROCESSORS_CONF`
    sudo cmake --install build
    cd ..

    # install wayle
    git clone https://github.com/wayle-rs/wayle
    cd wayle
    cargo install --path wayle
    cargo install --path crates/wayle-settings
    wayle icons setup
}

install_system() {
    local dev_only="$1"
    
    # Install system packages
    echo "Installing system packages..."
    install_packages "${SYSTEM_PACKAGES[@]}"

    # Install development packages
    echo "Installing development packages..."
    install_packages "${DEV_PACKAGES[@]}"
    install_packages "${DEB_DEV_PACKAGES[@]}"

    if [ "$dev_only" = true ]; then
        echo "Development-only mode enabled. Skipping additional packages."
    else
        echo "Installing desktop packages..."
        install_packages "${DESKTOP_PACKAGES[@]}"
        install_desktop_stack

        xdg-user-dirs-update

        # install additional packages
        install_packages "${ADDITIONAL_PACKAGES[@]}"
        install_packages "${DEB_ADDITIONAL_PACKAGES[@]}"
    fi
}

