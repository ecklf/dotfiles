# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory 
setopt extendedglob 
setopt nomatch 
setopt notify
bindkey -e
# End of lines configured by zsh-newuser-install

zstyle ':completion:*' menu select

# # The following lines were added by compinstall
# zstyle :compinstall filename "/Users/lynx/.zshrc"
# autoload -Uz compinit
# compinit
# # End of lines added by compinstall

# initialize autocomplete here, otherwise functions won't be loaded
autoload -U compinit
compinit

# quote pasted URLs
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# Exports and aliases
export LC_ALL=en_US.UTF-8
export PATH="/usr/local/opt/curl/bin:$PATH"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

function cheat(){
  command curl "cheat.sh/$1"
}

# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update --self
fi

if type nvim > /dev/null 2>&1; then
  alias vim='nvim'
fi

# Essential
source ~/.zplug/init.zsh
source ~/.bashrc

# Plugins
zplug "djui/alias-tips"
zplug "lukechilds/zsh-nvm"
zplug "plugins/npm", from:oh-my-zsh
zplug "plugins/brew", from:oh-my-zsh
# zplug "plugins/cargo", from:oh-my-zsh # Rust Cargo
zplug "modules/directory", from:prezto
zplug "modules/git", from:prezto
zplug "modules/osx", from:prezto
zplug "rupa/z", as:plugin, use:z.sh
# Suggestions
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions", defer:2
zplug "zsh-users/zsh-syntax-highlighting", defer:3 # Should be loaded 2nd last.
# zplug "zsh-users/zsh-history-substring-search", defer:3 # Should be loaded last.

# Plugin Options
export AUTO_CD=true
# export NVM_LAZY_LOAD=true

# Theme
zplug denysdovhan/spaceship-prompt, use:spaceship.zsh, from:github, as:theme
SPACESHIP_CHAR_SYMBOL="❯"
SPACESHIP_CHAR_SUFFIX=" "
SPACESHIP_VI_MODE_SHOW=false
SPACESHIP_PACKAGE_PREFIX="\n"
SPACESHIP_GIT_PREFIX="\n"
SPACESHIP_NODE_PREFIX="\n"
SPACESHIP_PACKAGE_SHOW=true
SPACESHIP_BATTERY_SHOW=false
SPACESHIP_PROMPT_ADD_NEWLINE="false"
SPACESHIP_CHAR_COLOR_SUCCESS="white"

# Install packages that have not been installed yet
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    else
        echo
    fi
fi

precmd () {print -Pn "\e]0;%~\a"}
zplug load #-- verbose
