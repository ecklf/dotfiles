# dotfiles

[![Managed with GNU Stow](https://img.shields.io/badge/Managed%20with-GNU%20Stow-red.svg)](https://www.gnu.org/software/stow/)

My current macOS dotfiles managed with GNU stow.

## Setup

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

Setting up symlinks:

```sh
# Creating 
stow folderName 
# Removing
stow -D folderName 

```
