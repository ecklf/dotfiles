# macOS
# Disable macOS Dock bouncing (xterm bellIsUrgent)
printf "\e[?1042l"

if [[ $(arch) == "arm64" ]]; then
    export EDITOR="/opt/homebrew/opt/nvim/bin/nvim" 
    export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
else
    export EDITOR="/usr/local/bin/nvim" 
    export PATH="/usr/local/opt/openjdk/bin:$PATH"
fi

# alias code="code-insiders '$@'"

# Exports
source "$HOME/.cargo/env"
export DOCKER_HOST=$(docker context inspect | jq '.[] | select(.Name == "'$(docker context show)'") | .Endpoints.docker.Host' -r)
export INITVIM="~/.config/nvim/init.vim"
export LC_ALL=en_US.UTF-8
export PATH="/usr/local/opt/curl/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH=$PATH:/Users/$USER/Developer/flutter/bin
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$(go env GOPATH)/bin
# Haskell
export PATH=$PATH:/Users/ecklf/.ghcup/bin
# OpenJDK
export PATH="/usr/local/sbin:$PATH"
# Pnpm
export PNPM_HOME="/Users/ecklf/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
# Homebrew
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

# Tooling
export NEXT_TELEMETRY_DISABLED=1
export MEILI_NO_ANALYTICS="true"
export MEILI_NO_SENTRY="true"

# Aliases
# Other good date format: date "+%Y-%m-%d@%H:%M:%S"
alias c="clear"
alias backup="[ -d '/Volumes/MBP Backup' ] && mkdir /Volumes/MBP\ Backup/$(date +%F) && rsync -av --exclude='Applications' --exclude='Library' --exclude='Trash' --exclude='node_modules' --exclude='.*' /Users/${WHOAMI}/ /Volumes/MBP\ Backup/$(date +%F)"
alias dots="vim ~/dotfiles"
alias untar="tar -zxvf "
alias wget="wget -c "
alias gen_pass="gpg --gen-random --armor 0 32"
alias sha="shasum -a 256 "
alias ping="ping -c 5"
alias jcurl="curl -H 'Content-Type: application/json' '$@'"
alias diskusage="sudo smartctl --all /dev/disk0"
alias lnjava="sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk"
alias to_webp="for i in *.* ; do cwebp -q 80 "$i" -o "${i%.*}.webp" ; done"
alias to_png="for i in *.* ; do convert "$i" "${i%.*}.png" ; done"

alias noflakepls="git commit --allow-empty -m 'force: CI'"
alias nogpgflakepls="gpgconf --kill gpg-agent && gpg-connect-agent /bye"

# IP
alias ipi="ipconfig getifaddr en0"
alias ipe="curl ifconfig.me"

# External pages
alias tb="nc termbin.com 9999"
alias wttr="curl v2.wttr.in/Munich"

# youtube-dl
alias dl="youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 $1"
alias dl_mp3="youtube-dl --extract-audio --audio-format mp3 $1"

# GPG
# Restarts GPG agent
alias rgpg="gpg-connect-agent killagent /bye && gpg-connect-agent /bye"
# Docker
alias dip="docker image prune"
alias dls="docker ps"
alias dlsa="docker ps -a"
alias dcu="docker-compose up"
alias dcd="docker-compose down"
alias dcdv="docker-compose down -v"

# MongoDB
alias mdbu="brew services start mongodb-community"
alias mdbd="brew services stop mongodb-community"
alias mdbr="brew services restart mongodb-community"

# Redis
alias rdbu="brew services start redis"
alias rdbd="brew services stop redis"
alias rdbr="brew services restart redis"

# PostgreSQL 
alias pdbu="brew services start postgresql@15"
alias pdbd="brew services stop postgresql@15"
alias pdbr="brew services restart postgresql@15"

# Node
alias nls="npm list -g --depth 0"
alias cra="npx create-react-app $1"

# Terraform
alias tf="tf $1"

# Make a repo commitizen friendly
alias init_cz="commitizen init cz-conventional-changelog --yarn --dev --exact"

# List all vscode extensions
alias vscode_ls="code --list-extensions | xargs -L 1 echo code --install-extension"

# React Native
alias rni="npx react-native run-ios"
alias rna="npx react-native run-android"
# Reconnects adb to metro bundler
alias adbr="adb reverse tcp:8081 tcp:8081"
# Shows iOS / iPadOS devices
alias iosd="xcrun xctrace list devices"

# React
alias yat="yarn add -D postcss tailwindcss @tailwindcss/forms @tailwindcss/typography @tailwindcss/aspect-ratio"
alias reshim="asdf reshim nodejs"

# Google
alias google_cred="export GOOGLE_APPLICATION_CREDENTIALS='~/service-account.json'"
alias avd="cd ~/Library/Android/sdk/emulator/ && ./emulator -avd Pixel_3_API_29"
alias chrome_dbg="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222"

# Misc
# alias appid="osascript -e 'id of app "\""$@"\""'"
alias ms="meilisearch --db-path ~/data.ms"
. "$HOME/.cargo/env"
