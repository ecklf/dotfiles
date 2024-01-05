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

function copy_curr_branch(){
  local ref="$(command git symbolic-ref HEAD 2> /dev/null)"

  if [[ -n "$ref" ]]; then
    echo "${ref#refs/heads/}" | pbcopy
  fi
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
  alias tree1='exa --tree --level=1 --icons .'
  alias tree2='exa --tree --level=2 --icons .'
  alias tree3='exa --tree --level=3 --icons .'
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
if [[ ! -d /Users/$(whoami)/.local/share/zinit ]]; then
  bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
fi

###########################################################
# ZSH / zinit
###########################################################
source "$HOME/.bashrc"
source "/Users/$(whoami)/.local/share/zinit/zinit.git/zinit.zsh"

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# fzf - respect .gitignore
# https://github.com/junegunn/fzf#respecting-gitignore
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Spaceship settings
# SPACESHIP_CHAR_SYMBOL="❯"
SPACESHIP_CHAR_SYMBOL="▲"
SPACESHIP_CHAR_SUFFIX=" "
SPACESHIP_VI_MODE_SHOW=false
SPACESHIP_PACKAGE_PREFIX="\n"
SPACESHIP_GIT_PREFIX="\n"
SPACESHIP_NODE_PREFIX="\n"
SPACESHIP_PACKAGE_SHOW=true
SPACESHIP_BATTERY_SHOW=false
SPACESHIP_PROMPT_ADD_NEWLINE=false
# SPACESHIP_CHAR_COLOR_SUCCESS="green"
SPACESHIP_CHAR_COLOR_SUCCESS="white"
SPACESHIP_DOCKER_SHOW=false
SPACESHIP_GCLOUD_SHOW=false	
SPACESHIP_ASYNC_SHOW=false
SPACESHIP_ASYNC_SYMBOL="󰹻"

# Spaceship theme
zinit ice lucid pick'spaceship.zsh' compile'{lib/*,sections/*,tests/*.zsh}'

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    denysdovhan/spaceship-prompt \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-completions \
    zsh-users/zsh-autosuggestions \
    joshskidmore/zsh-fzf-history-search \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust 

# Snippets
zinit ice svn pick"init.zsh"
zinit snippet PZT::modules/git

zinit ice svn pick"init.zsh"
zinit snippet PZT::modules/directory
export AUTO_CD=true

zinit snippet OMZ::plugins/aws/aws.plugin.zsh

# macOS specific
if [[ "$OSTYPE" == "darwin"* ]]; then
  zinit ice svn pick"init.zsh"
  zinit snippet PZT::modules/homebrew

  zinit ice svn pick"init.zsh"
  zinit snippet PZT::modules/osx
fi

# Plugins
zinit ice lucid wait"0" blockf
zinit ice lucid wait"0" atload"_zsh_autosuggest_start"
zinit ice lucid wait"0" atinit"zpcompinit; zpcdreplay"
zinit ice lucid wait"0"


# zoxide > z
# zinit ice lucid wait"0"
# zinit light agkozak/zsh-z
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"

# Specify fnm arch for M1
if [[ $(arch) == "arm64" ]]; then
  eval "$(fnm env --arch arm64 --use-on-cd)"
else
  eval "$(fnm env --use-on-cd)"
fi

complete -o nospace -C /opt/homebrew/bin/terraform terraform
source /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
source /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true
