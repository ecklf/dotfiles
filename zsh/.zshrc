###########################################################
# GENERAL
###########################################################
bindkey -e

###########################################################
# HISTORY
###########################################################
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
# Timestamps
setopt extended_history
# Remove duplicates
setopt hist_expire_dups_first
# Ignore duplicates
setopt hist_ignore_dups
# Ignore space prefixed commands
setopt hist_ignore_space
# Show history expansion command
setopt hist_verify
# Add commands in order of execution
setopt inc_append_history
# Share command history data
setopt share_history

###########################################################
# COMPINIT AND FUNCTIONS
###########################################################
autoload -Uz compinit
zstyle ':completion:*' menu select
zmodload zsh/complist

compinit
# Include hidden files
_comp_options+=(globdots)

autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# Usage: cheat $1, returns RL examples of provided tool 
function cheat(){
  command curl "cheat.sh/$1"
}

function fu(){
  command fnm use $1
}

# Prefer nvim over vim
if type nvim > /dev/null 2>&1; then
  alias vim='nvim'
fi

# Prefer lsd over ls
# if type lsd > /dev/null 2>&1; then
#   alias ls='lsd'
# fi

# Prefer bat over cat
export BAT_PAGER="less -RF"
if type bat > /dev/null 2>&1; then
  alias cat='bat'
fi

# Check if zplugin is installed, else autoinstall
if [[ ! -d ~/.zplugin ]]; then
  mkdir ~/.zplugin
  git clone https://github.com/zdharma/zplugin.git ~/.zplugin/bin
fi

# Adding color support for ls etc.
precmd () {print -Pn "\e]0;%~\a"}

###########################################################
# ZPLUGIN / SOURCE
###########################################################
source "$HOME/.bashrc"
source "$HOME/.zplugin/bin/zplugin.zsh"

autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin

# Spaceship settings
SPACESHIP_CHAR_SYMBOL="❯"
SPACESHIP_CHAR_SUFFIX=" "
SPACESHIP_VI_MODE_SHOW=false
SPACESHIP_PACKAGE_PREFIX="\n"
SPACESHIP_GIT_PREFIX="\n"
SPACESHIP_NODE_PREFIX="\n"
SPACESHIP_PACKAGE_SHOW=true
SPACESHIP_BATTERY_SHOW=false
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_CHAR_COLOR_SUCCESS="green"
SPACESHIP_DOCKER_SHOW=false

# Spaceship theme
zplugin ice lucid pick'spaceship.zsh' compile'{lib/*,sections/*,tests/*.zsh}'
zplugin light denysdovhan/spaceship-prompt

# Snippets
zplugin ice svn pick"init.zsh"
zplugin snippet PZT::modules/git

zplugin ice svn pick"init.zsh"
zplugin snippet PZT::modules/directory
export AUTO_CD=true

# macOS specific
if [[ "$OSTYPE" == "darwin"* ]]; then
  zplugin ice svn pick"init.zsh"
  zplugin snippet PZT::modules/homebrew

  zplugin ice svn pick"init.zsh"
  zplugin snippet PZT::modules/osx
fi

# Plugins
zplugin ice lucid wait"0" blockf
zplugin light zsh-users/zsh-completions

zplugin ice lucid wait"0" atload"_zsh_autosuggest_start"
zplugin light zsh-users/zsh-autosuggestions

zplugin ice lucid wait"0" atinit"zpcompinit; zpcdreplay"
zplugin light zdharma/fast-syntax-highlighting

zplugin ice lucid wait"0"
zplugin light agkozak/zsh-z

#eval "$(starship init zsh)"
eval "$(fnm env --use-on-cd --multi)"
