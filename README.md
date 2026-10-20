# Dotfiles

Linux dotfiles managed with GNU Stow. The install script sets up system packages, development tools, and desktop configs for a Hyprland-based workflow on Arch Linux, Fedora, and Ubuntu.

## Quick Start

```bash
git clone https://github.com/Jojojojodr/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

If you only want the development tools and shell/editor setup, use:

```bash
./install.sh --dev-only
```

## Supported Distros

The script detects your package manager and loads the matching distro script:

| Distro | Script | Desktop (Hyprland) | Notes |
| --- | --- | --- | --- |
| Arch Linux and derivatives | `arch.sh` | Yes | Uses `pacman`, installs `yay` for AUR packages |
| Fedora | `fedora.sh` | Yes | Uses `dnf`, adds third-party repos, builds `wayle` from source |
| Debian/Ubuntu | `debian.sh` | No | Development setup only, no desktop packages |

## What It Does

- Updates the system and installs packages from `packages.conf`
- **Arch:** installs `yay` if it is missing
- **Fedora:** adds the Docker CE, Brave, and VS Code repositories, plus the `sdegler/hyprland` and `scottames/ghostty` COPRs
- **Fedora:** builds `wayle` from source into `~/.local/bin` (not packaged for Fedora)
- **Ubuntu:** adds the Docker CE repository
- Installs `superfile`
- Optionally sets up `zsh` with oh-my-zsh, plugins, and powerlevel10k
- Adds your user to the `docker` group
- Symlinks dotfiles into `~/.config` and your home directory with Stow

## Included Configs

Always installed:

- `git`
- `nvim`
- `tmux`
- `superfile`
- `zsh` (only when you choose to set up zsh)

Desktop only (skipped with `--dev-only`):

- `hypr`
- `wayle`
- `rofi`
- `ghostty`

## Notes

- Run the script from the repository root so the relative paths resolve correctly.
- Existing configs for the included programs are removed before they are symlinked, so back up anything you want to keep.
- Reboot after setup to ensure shell, group, and desktop changes take effect.
- Wallpapers can be stored in `~/Pictures/wallpapers/`.
- **Fedora:** building `wayle` takes a while and needs a fair amount of RAM. The script limits parallel jobs based on available memory.
- **Fedora:** if a COPR has no build for your Fedora release yet, the script falls back to another chroot (rawhide or an older release) automatically.
