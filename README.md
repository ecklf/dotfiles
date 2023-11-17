# dotfiles

## Nix macOS

### Prerequisites

1. Install [nix](https://nixos.org/download) — for package and dotfiles management
2. Install [homebrew](https://brew.sh) for GUI app management
3. Ensure Xcode command line tools are installed and you are signed into the App Store

### Installation

For a fresh macOS install you can clear your bloated dock.

```sh
defaults write com.apple.dock persistent-apps -array && killall Dock
```

Clone this repository.

```sh
git clone git@github.com:ecklf/dotfiles.git
```

```sh
# For the first run — `darwin-rebuild`` won't be installed in your path yet
nix run nix-darwin --extra-experimental-features flakes --extra-experimental-features nix-command -- switch --flake ~/dotfiles/nix#omega
# Build the flake
darwin-rebuild build --flake ~/dotfiles/nix#omega
# Switch to the flake
darwin-rebuild switch --flake ~/dotfiles/nix#omega
```

## Legacy GNU Stow

### Setup

#### Install

```sh
# All packages
brew bundle
```

⏤ or ⏤

```sh
# Minimum packages
brew install zsh git subversion neovim
```

#### Configuration

Pre 10.15 Catalina:

```sh
chsh -s $(which zsh)
```

Tmux Plugin Manager:

```shell
# prefix + I to install
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Setting up symlinks:

```sh
# Creating 
stow folderName 
# Removing
stow -D folderName 

```
