# Exports
export LC_ALL=en_US.UTF-8
export ANDROID_HOME=/Users/$USER/Library/Android/sdk
export PATH=${PATH}:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
export PATH=$PATH:/Users/$USER/Development/flutter/bin
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/curl/bin:$PATH"
# export EDITOR="/usr/local/bin/nvim" 

# Aliases
alias untar='tar -zxvf '
alias wget='wget -c '
alias getpass="openssl rand -base64 20"
alias sha='shasum -a 256 '
alias ping='ping -c 5'
alias c='clear'
alias l='ls -Gl'
alias ls='ls -G'
alias la='ls -Ga'
alias jcurl='curl -H "Content-Type: application/json" "$@"'

# IP
alias ipi='ipconfig getifaddr en0'
alias ipe='curl ipinfo.io/ip'

# External pages
alias tb='nc termbin.com 9999'
alias wttr="curl wttr.in/Munich"

# youtube-dl
alias dl='youtube-dl -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio" --merge-output-format mp4 $1'
alias dlmp3='youtube-dl --extract-audio --audio-format mp3 $1'

# Docker
alias dls='docker ps'
alias dlsa='docker ps -a'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcdv='docker-compose down -v'

# Node
alias nls='npm list -g --depth 0'

# Make a repo commitizen friendly
alias init-cz='commitizen init cz-conventional-changelog --yarn --dev --exact'

# List all vscode extensions
alias vscodels='code --list-extensions | xargs -L 1 echo code --install-extension'

# Google
alias googleCred='export GOOGLE_APPLICATION_CREDENTIALS="/Users/lynx/service-account.json"'
alias vdroid='cd /Users/lynx/Library/Android/sdk/emulator/ && ./emulator -avd Pixel_3_XL_API_29'
alias chromeDebug="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222"
