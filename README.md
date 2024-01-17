# dotfiles

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
