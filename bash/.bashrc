# Exports
source "$HOME/.cargo/env"
export LC_ALL=en_US.UTF-8
export PATH="/usr/local/opt/curl/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH=$PATH:/Users/$USER/Developer/flutter/bin
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH="/usr/local/opt/openjdk@8/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
# export EDITOR="/usr/local/bin/nvim" 
export MEILI_NO_ANALYTICS="true"
export MEILI_NO_SENTRY="true"

# Aliases
# Other good date format: date "+%Y-%m-%d@%H:%M:%S"
alias backup="[ -d '/Volumes/MBP Backup' ] && mkdir /Volumes/MBP\ Backup/$(date +%F) && rsync -av --exclude='Applications' --exclude='Library' --exclude='Trash' --exclude='node_modules' --exclude='.*' /Users/${WHOAMI}/ /Volumes/MBP\ Backup/$(date +%F)"
alias dots="cd ~/dotfiles && vim"
alias untar='tar -zxvf '
alias wget='wget -c '
alias getpass="openssl rand -base64 32"
alias sha='shasum -a 256 '
alias ping='ping -c 5'
alias c='clear'
alias jcurl='curl -H "Content-Type: application/json" "$@"'
alias diskusage='sudo smartctl --all /dev/disk0'

# IP
alias ipi='ipconfig getifaddr en0'
alias ipe='curl ifconfig.me'

# External pages
alias tb='nc termbin.com 9999'
alias wttr="curl v2.wttr.in/Munich"

# youtube-dl
alias dl='youtube-dl -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio" --merge-output-format mp4 $1'
alias dlmp3='youtube-dl --extract-audio --audio-format mp3 $1'

# Docker
alias dip='docker image prune'
alias dls='docker ps'
alias dlsa='docker ps -a'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcdv='docker-compose down -v'

# MongoDB
alias mdbu='brew services start mongodb-community'
alias mdbd='brew services stop mongodb-community'

# Redis
alias rdbu='brew services start redis'
alias rdbd='brew services stop redis'

# PostgreSQL 
alias pdbu='brew services start postgresql'
alias pdbd='brew services stop postgresql'

# Node
alias nls='npm list -g --depth 0'
alias cra='npx create-react-app $1'

# Make a repo commitizen friendly
alias init-cz='commitizen init cz-conventional-changelog --yarn --dev --exact'

# List all vscode extensions
alias vscodels='code --list-extensions | xargs -L 1 echo code --install-extension'

# React Native
alias rni='npx react-native run-ios'
alias rna='npx react-native run-android'

# React
alias yat='yarn add -D postcss tailwindcss @tailwindcss/forms @tailwindcss/typography @tailwindcss/aspect-ratio'

# Google
alias googleCred='export GOOGLE_APPLICATION_CREDENTIALS="~/service-account.json"'
alias vdroid='cd ~/Library/Android/sdk/emulator/ && ./emulator -avd Pixel_3_API_29'
alias chromeDebug="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222"

# Misc
alias ms='meilisearch --db-path ~/data.ms'