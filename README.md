# dotfiles

> [!NOTE]  
> Old config can be found in legacy branch

### Installation

1. Install [nix](https://nixos.org/download)
2. Install [homebrew](https://brew.sh)
3. Ensure Xcode command line tools are installed (setting up brew should already do this)
4. Ensure you are signed into the App Store (when providing appids for `mas`)
5. Clone this repository

```sh
git clone git@github.com:ecklf/dotfiles.git
```

### Fresh Install

> [!TIP]
> The macOS dock can be wiped with:
> ```sh
> defaults write com.apple.dock persistent-apps -array && killall Dock
> ```

> [!IMPORTANT]  
> For the very first run, `darwin-rebuild` won't be installed in your path.
> ```sh
> nix run nix-darwin --extra-experimental-features flakes --extra-experimental-features nix-command -- switch --flake ~/dotfiles/nix#omega
> ```

### Usage

```sh
# Build the flake `omega` (see flake.nix)
darwin-rebuild build --flake ~/dotfiles/nix#omega
# Switch to `omega` (see flake.nix)
darwin-rebuild switch --flake ~/dotfiles/nix#omega
```

```sh
# Upgrading nix — https://nix.dev/manual/nix/2.22/installation/upgrading
# Updating inputs
nix flake lock --update-all
nix flake lock --update-input <input>
```
