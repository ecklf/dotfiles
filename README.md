# dotfiles

## Nix

### Installation

1. Install [nix](https://nixos.org/download) for package and dotfiles management
2. Install [homebrew](https://brew.sh) for GUI app management
3. Ensure Xcode command line tools are installed and you are signed into the App Store
4. Ensure you are signed into the App Store
5. Clone this repository

```sh
git clone git@github.com:ecklf/dotfiles.git
```

### Fresh Install

For the first run — `darwin-rebuild` won't be installed in your path yet
```sh
nix run nix-darwin --extra-experimental-features flakes --extra-experimental-features nix-command -- switch --flake ~/dotfiles/nix#omega
```

Clear the default macOS dock:

```sh
defaults write com.apple.dock persistent-apps -array && killall Dock
```

### Usage

```sh
# Build the flake `omega` (see flake.nix)
darwin-rebuild build --flake ~/dotfiles/nix#omega
# Switch to `omega` (see flake.nix)
darwin-rebuild switch --flake ~/dotfiles/nix#omega
```

```sh
# Upgrading nix — https://nix.dev/manual/nix/2.22/installation/upgrading
# Updating packages
nix flake lock --update-all
nix flake lock --update-input <input>
```
