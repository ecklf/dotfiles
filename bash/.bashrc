# Exports
export ANDROID_HOME=/Users/$USER/Library/Android/sdk
export PATH=${PATH}:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
export PATH=$PATH:/Users/$USER/Development/flutter/bin

# Aliases
alias untar='tar -zxvf '
alias wget='wget -c '
alias getpass="openssl rand -base64 20"
alias sha='shasum -a 256 '
alias ping='ping -c 5'
alias c='clear'
alias ls='ls -G'
alias jcurl='curl -H "Content-Type: application/json" "$@"'

# IP
alias ipi='ipconfig getifaddr en0'
alias ipe='curl ipinfo.io/ip'

# External pages
alias tb='nc termbin.com 9999'
alias wttr="curl wttr.in/Munich"

# Docker
alias dls='docker ps'
alias dlsa='docker ps -a'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcdv='docker-compose down -v'

# List all global npm packages
alias node8='nvm use --lts=carbon'
alias node10='nvm use --lts=dubnium'
alias npmls='npm list -g --depth 0'

# List all vscode extensions
alias vscodels='code --list-extensions | xargs -L 1 echo code --install-extension'

# Google
alias googleCred='export GOOGLE_APPLICATION_CREDENTIALS="/Users/lynx/service-account.json"'
alias vdroid='cd /Users/lynx/Library/Android/sdk/emulator/ && ./emulator -avd Pixel_2_XL_API_28'
alias chromeDebug="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222"
