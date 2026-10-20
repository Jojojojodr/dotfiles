#!/usr/bin/env bash

titleBar() {
    cat << "EOF"
|========================================================|
|---  Setting up the system for a Ubuntu environment  ---|
|========================================================|
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

install_system() {
    local dev_only="$1"
    
    # Install system packages
    echo "Installing system packages..."
    install_packages "${SYSTEM_PACKAGES[@]}"

    # Install development packages
    echo "Installing development packages..."
    install_packages "${DEV_PACKAGES[@]}"
    install_packages "${DEB_DEV_PACKAGES[@]}"
}

