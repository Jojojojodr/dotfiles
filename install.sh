#!/usr/bin/env bash

# This script sets up a Linux environment with essential packages, services, and configurations.

set_zsh_as_default() { 
    # Set zsh as the default shell
    zsh_path=$(grep zsh$ /etc/shells | head -n 1)
    if [ "$SHELL" != "$zsh_path" ]; then
        echo "Changing default shell to zsh..." 
        chsh -s "$zsh_path" "$(whoami)"
    else
        echo "zsh is already the default shell."
    fi
}

install_oh_my_zsh() {
    # Install oh-my-zsh
    if [ ! -d ~/.oh-my-zsh ]; then
        echo "Installing oh-my-zsh..."
        CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        echo "oh-my-zsh installed successfully."
    else
        echo "oh-my-zsh is already installed."
    fi
}

install_zsh_plugins() {
    # Install zsh plugins
    if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
        echo "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        echo "zsh-autosuggestions installed successfully."
    else
        echo "zsh-autosuggestions is already installed."
    fi
    if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
        echo "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        echo "zsh-syntax-highlighting installed successfully."
    else
        echo "zsh-syntax-highlighting is already installed."
    fi
}

install_powerlevel10k_theme() {
    # Install powerlevel10k theme
    if [ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
        echo "Installing powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
        echo "Powerlevel10k theme installed successfully."
    else
        echo "powerlevel10k theme is already installed."
    fi
}

install_zsh() {
    set_zsh_as_default
    install_oh_my_zsh
    install_zsh_plugins
    install_powerlevel10k_theme
}

setup_zsh() {
    if [[ -t 0 ]]; then
        read -r -p "Do you want to install and use zsh as your default shell? [y/N]: " use_zsh_reply
        case "$use_zsh_reply" in
            [Yy]|[Yy][Ee][Ss])
                USE_ZSH=true
                ;;
            *)
                echo "Skipping zsh installation and setup."
                ;;
        esac
    else
        echo "Non-interactive mode detected. Skipping zsh installation and setup."
    fi

    if [[ "$USE_ZSH" == true ]]; then
        # Install zsh and oh-my-zsh
        echo "Installing zsh and oh-my-zsh..."
        install_zsh
    fi
}

install_superfile() {
    if ! command -v spf &> /dev/null; then
        bash -c "$(curl -sLo- https://superfile.dev/install.sh)"
    else
        echo "spf (superfile) is already installed."
    fi
}

setup_symlinks() {
    # Create symlinks for dotfiles
    echo "Creating symlinks for dotfiles..."
    cd ~/dotfiles

    if [[ "$USE_ZSH" == true ]]; then
        rm -f ~/.zshrc  # Remove existing .zshrc to avoid conflicts
        stow --adopt zsh
    fi

    rm -f ~/.gitconfig  # Remove existing .gitconfig to avoid conflicts
    stow --adopt git
    for dir in nvim tmux superfile; do
        rm -rf ~/.config/$dir  # Remove existing config to avoid conflicts
        stow --adopt $dir
    done

    if [[ "$DEV_ONLY" == true ]]; then
        echo "Development-only mode enabled. Skipping additional dotfiles."
    else
        for dir in hypr wayle rofi ghostty; do
            rm -rf ~/.config/$dir  # Remove existing config to avoid conflicts
            stow --adopt $dir
        done
    fi
}

setup_docker() {
    # Add user to docker group
    if ! groups $USER | grep -q "\bdocker\b"; then
        echo "Adding user to docker group..."
        sudo usermod -aG docker $(whoami)
    else
        echo "User is already in the docker group."
    fi
}

main() {
    clear
    titleBar

    update_system
    install_system "$DEV_ONLY"
    install_superfile
    setup_zsh
    setup_symlinks
    setup_docker

    echo "Development environment setup complete."
    echo "Please reboot your system to apply all changes."
}

set -e

if command -v pacman &> /dev/null; then
    source ./arch.sh
elif command -v apt &> /dev/null; then
    source ./debian.sh
elif command -v dnf &> /dev/null; then
    source ./fedora.sh
else
    echo "Your system is not supported. This script is intended for Debian/Ubuntu, Arch Linux and their derivatives."
    exit 1
fi

source ./packages.conf  # Load package list

USE_ZSH=false
DEV_ONLY=false

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --dev-only)
            DEV_ONLY=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

main "$@"
