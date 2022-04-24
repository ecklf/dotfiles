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

# Adding color support for ls etc.
precmd () {print -Pn "\e]0;%~\a"}

# Check if zinit is installed, else autoinstall
if [[ ! -d ~/.zi ]]; then
  mkdir ~/.zi
  git clone https://github.com/z-shell/zi.git ~/.zi/bin
fi

###########################################################
# ZSH / zi
###########################################################
source "$HOME/.bashrc"
source "$HOME/.zi/bin/zi.zsh"

autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi

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
zi ice lucid pick'spaceship.zsh' compile'{lib/*,sections/*,tests/*.zsh}'
zi light denysdovhan/spaceship-prompt

# Snippets
zi ice svn pick"init.zsh"
zi snippet PZT::modules/git

zi ice svn pick"init.zsh"
zi snippet PZT::modules/directory
export AUTO_CD=true

# macOS specific
if [[ "$OSTYPE" == "darwin"* ]]; then
  zi ice svn pick"init.zsh"
  zi snippet PZT::modules/homebrew

  zi ice svn pick"init.zsh"
  zi snippet PZT::modules/osx
fi

# Plugins
zi ice lucid wait"0" blockf
zi light zsh-users/zsh-completions

zi ice lucid wait"0" atload"_zsh_autosuggest_start"
zi light zsh-users/zsh-autosuggestions

zi ice lucid wait"0" atinit"zpcompinit; zpcdreplay"
zi light zdharma/fast-syntax-highlighting

# zoxide > z
# zi ice lucid wait"0"
# zi light agkozak/zsh-z
eval "$(zoxide init zsh)"

# Specify fnm arch for M1
if [[ $(arch) == "arm64" ]]; then
  eval "$(fnm env --arch arm64 --use-on-cd)"
else
  eval "$(fnm env --use-on-cd)"
fi

# pnpm autocomplete
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true