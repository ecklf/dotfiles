###########################################################
# GENERAL
###########################################################
# Keybindings
bindkey -e # Emacs keybindings
# Fixes
bindkey "^E" end-of-line # Map end-of-line key in the same way as zprezto editor module to prevent issue with tmux-resurrect.
setopt CLOBBER # Allow pipe to existing file. Prevent issue with history save in tmux-resurrect.
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

# Prefer nvim over vim
if type nvim > /dev/null 2>&1; then
  alias vim='nvim'
  alias viml="nvim -c 'let &background="\""light"\""'"
fi

# Prefer exa over ls
if type exa > /dev/null 2>&1; then
  alias l='exa -Gl --icons'
  alias ls='exa -G --icons'
  alias la='exa -Ga --icons'
else
  alias l='ls -Gl'
  alias ls='ls -G'
  alias la='ls -Ga'
fi

# Prefer bat over cat
#export BAT_PAGER="less -RF"
#if type bat > /dev/null 2>&1; then
  #alias cat='bat'
#fi

# Check if zinit is installed, else autoinstall
if [[ ! -d ~/.zinit ]]; then
  mkdir ~/.zinit
  git clone https://github.com/zdharma/zinit.git ~/.zinit/bin
fi

# Adding color support for ls etc.
precmd () {print -Pn "\e]0;%~\a"}

###########################################################
# zinit / SOURCE
###########################################################
source "$HOME/.bashrc"
source "$HOME/.zinit/bin/zinit.zsh"

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# fzf - respect .gitignore
# https://github.com/junegunn/fzf#respecting-gitignore
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

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
SPACESHIP_GCLOUD_SHOW=false	

# Spaceship theme
zinit ice lucid pick'spaceship.zsh' compile'{lib/*,sections/*,tests/*.zsh}'
zinit light denysdovhan/spaceship-prompt

# Snippets
zinit ice svn pick"init.zsh"
zinit snippet PZT::modules/git

zinit ice svn pick"init.zsh"
zinit snippet PZT::modules/directory
export AUTO_CD=true

# macOS specific
if [[ "$OSTYPE" == "darwin"* ]]; then
  export SYSTEM_APPEARANCE="dark" && [[ $(defaults read -g AppleInterfaceStyle 2> /dev/null) != "Dark" ]]  && SYSTEM_APPREARANCE="light" 

  zinit ice svn pick"init.zsh"
  zinit snippet PZT::modules/homebrew

  zinit ice svn pick"init.zsh"
  zinit snippet PZT::modules/osx
fi

# Plugins
zinit ice lucid wait"0" blockf
zinit light zsh-users/zsh-completions

zinit ice lucid wait"0" atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

zinit ice lucid wait"0" atinit"zpcompinit; zpcdreplay"
zinit light zdharma/fast-syntax-highlighting

# Using zoxide as alternative
#zinit ice lucid wait"0"
#zinit light agkozak/zsh-z
eval "$(zoxide init zsh)"

if [ ! -f "$HOME/.asdf/asdf.sh" ]; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
fi
. $HOME/.asdf/asdf.sh
