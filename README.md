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

For a fresh macOS install you can clear your bloated dock using:

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

```sh
# Upgrading nix — https://nixos.org/manual/nix/stable/installation/upgrading
# Updating packages
nix flake lock --update-all
nix flake lock --update-input <input>
```
