# Exports
export ANDROID_HOME=/Users/$USER/Library/Android/sdk
export PATH=${PATH}:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
export PATH=$PATH:/Users/$USER/Development/flutter/bin
# Aliases
alias ls='ls -G'
alias tb='nc termbin.com 9999'
alias wttr="curl wttr.in/Munich"
alias jcurl='curl -H "Content-Type: application/json" "$@"'
# Launch Pixel 2 Emu
alias vdroid='cd /Users/lynx/Library/Android/sdk/emulator/ && ./emulator -avd Pixel_2_XL_API_28'
# Chrome
alias chromeDebug="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222"
alias googleCred='export GOOGLE_APPLICATION_CREDENTIALS="/Users/lynx/service-account.json"'
# Node
alias node8='nvm use 8.15.1'
# List all global npm packages
alias npmls='npm list -g --depth 0'
# Docker
alias dls='docker ps'
alias dlsa='docker ps -a'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcdv='docker-compose down -v'
# List all vscode extensions
alias vscodels='code --list-extensions | xargs -L 1 echo code --install-extension'