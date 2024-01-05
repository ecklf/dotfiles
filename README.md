# dotfiles

## Nix

### Installation

1. Install [nix](https://nixos.org/download) for package and dotfiles management
2. Clone this repository

```sh
git clone git@github.com:ecklf/dotfiles.git
```

### macOS

1. Install [homebrew](https://brew.sh) for GUI app management
2. Ensure Xcode command line tools are installed (should have been done by brew)
3. Ensure you are signed into the App Store

For a fresh macOS install you can clear your bloated dock.

```sh
defaults write com.apple.dock persistent-apps -array && killall Dock
```

```sh
# For the first run — `darwin-rebuild`` won't be installed in your path yet
nix run nix-darwin --extra-experimental-features flakes --extra-experimental-features nix-command -- switch --flake ~/dotfiles/nix#omega
# For consecutive runs
# Build the flake `omega` (see flake.nix)
darwin-rebuild build --flake ~/dotfiles/nix#omega
# Switch to `omega` (see flake.nix)
darwin-rebuild switch --flake ~/dotfiles/nix#omega
```

## Legacy GNU Stow

### Install

```sh
# All packages
brew bundle
```

⏤ or ⏤

```sh
# Minimum packages
brew install zsh git subversion neovim
```

### Configuration

Pre 10.15 Catalina:

```sh
chsh -s $(which zsh)
```

Tmux Plugin Manager:

```shell
# prefix + I to install
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### Setting up symlinks

```sh
# Creating 
stow folderName 
# Removing
stow -D folderName 

```
