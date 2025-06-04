{
  pkgs,
  lib,
  system,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      zsh-abbr.abbreviations = {};
      # Whether to enable Bash And Zsh shell history suggest box - easily view, navigate, search and manage your command history
      # programs.hstr.enable = true;
      history = {
        # Expire duplicates first
        expireDuplicatesFirst = true;
        # Save timestamp into the history file
        extended = true;
        # If a new command line being added to the history list duplicates an older one, the older command is removed from the list (even if it is not the previous event)
        ignoreAllDups = true;
        # Do not enter command lines into the history list if they are duplicates of the previous event
        ignoreDups = true;
        # Do not enter command lines into the history list if they match any one of the given shell patterns
        ignorePatterns = [];
        # Do not enter command lines into the history list if the first character is a space
        ignoreSpace = true;
        # History file location	string
        # programs.zsh.history.path = "${pkgs.home-manager.home}/.zsh_history";
        # Number of history lines to save
        save = 50000;
        # Number of history lines to keep
        size = 10000;
        # Share command history between zsh sessions
        share = true;
        # historySubstringSearch = {
        #   historySubstringSearch.enable = true;
        #   # The key codes to be used when searching down. The default of ^[[B may correspond to the DOWN key – if not, try $terminfo[kcud1].	(list of string) or string
        #   historySubstringSearch.searchDownKey = [ ];
        #   historySubstringSearch.searchUpKey = true;
        # };
      };
      sessionVariables = {
        NEXT_TELEMETRY_DISABLED = 1;
        MEILI_NO_ANALYTICS = true;
        PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = true;
        PUPPETEER_EXECUTABLE_PATH = "which chromium";
      };
      profileExtra = lib.mkIf isDarwin (
        if system == "aarch64-darwin"
        then ''
          eval "$(/opt/homebrew/bin/brew shellenv)"
        ''
        else ''
          eval "$(/usr/local/bin/brew shellenv)"
        ''
      );

      initContent = lib.mkMerge [
        # Before CompInit
        (lib.mkBefore ''
          # Disable macOS Dock bouncing (xterm bellIsUrgent)
          printf "\e[?1042l"
          # Emacs keybindings
          bindkey -e

          # Map end-of-line key in the same way as zprezto editor module to prevent issue with tmux-resurrect.
          bindkey "^E" end-of-line

          # Edit command line in $EDITOR
          autoload edit-command-line
          zle -N edit-command-line
          bindkey "^X^E" edit-command-line

          # Allow pipe to existing file. Prevent issue with history save in tmux-resurrect.
          setopt CLOBBER
        '')
        # Init
        (lib.mkOrder 550 ''
          zstyle ':completion:*' menu select
          zmodload zsh/complist
        '')
        # Config
        ''
          # pnpm
          export PNPM_HOME="/Users/$(whoami)/Library/pnpm"
          export PATH="$PNPM_HOME:$PATH"
          export PATH="$HOME/development/flutter/bin:$PATH"

          eval "$(direnv hook zsh)"

          # Adding color support for ls etc.
          precmd () {print -Pn "\e]0;%~\a"}

          # Include hidden files
          _comp_options+=(globdots)
          autoload -Uz url-quote-magic
          zle -N self-insert url-quote-magic

          # cheat $1, returns RL examples of provided tool
          function cheat(){
            command curl "cheat.sh/$1"
          }

          function update_input() {
            input=$(nix flake metadata --json | nix run nixpkgs#jq ".locks.nodes.root.inputs[]" | sed "s/\"//g" | nix run nixpkgs#fzf)
            nix flake update "$input"
          }

          # bundle_id $1, returns the macOS bundle id for the provided app name
          function bundle-id() {
            osascript -e "id of app \"$1\""
          }

          # Copies current branch name to clipboard
          function copy_curr_branch(){
            local ref="$(command git symbolic-ref HEAD 2> /dev/null)"

            if [[ -n "$ref" ]]; then
              echo "''${ref#refs/heads/}" | pbcopy
            fi
          }

          if [[ $(arch) == "arm64" ]]; then
            eval "$(fnm env --arch arm64 --use-on-cd)"
          else
            eval "$(fnm env --use-on-cd)"
          fi
          eval "$(task --completion zsh)"
        ''
      ];

      shellAliases =
        {
          nix-shell = "nix-shell --run zsh";
          # Abbreviations
          c = "clear";
          m = "make";
          n = "nvim";
          # General
          fman = "compgen -c | fzf | xargs man";
          tree1 = "exa --tree --level=1 --icons .";
          tree2 = "exa --tree --level=2 --icons .";
          tree3 = "exa --tree --level=3 --icons .";
          diskusage = "sudo smartctl --all /dev/disk0";
          # Common
          dots = "vim ~/dotfiles";
          untar = "tar -zxvf ";
          backup = ''[ -d '/Volumes/MBP Backup' ] && mkdir /Volumes/MBP\ Backup/''$(date +%F) && rsync -av --exclude='Applications' --exclude='Library' --exclude='Trash' --exclude='node_modules' --exclude='.*' /Users/''${WHOAMI}/ /Volumes/MBP\ Backup/''$(date +%F)'';
          # Crypto
          sha = "shasum -a 256 ";
          gen_pass = "gpg --gen-random --armor 0 32";
          # Git
          noflakepls = "git commit --allow-empty -m 'force: CI'";
          nogpgflakepls = "gpgconf --kill gpg-agent && gpg-connect-agent /bye";
          rgpg = "gpg-connect-agent killagent /bye && gpg-connect-agent /bye";
          # Network
          ping = "ping -c 5";
          jcurl = ''curl -H 'Content-Type: application/json' "''$@"'';
          wget = "wget -c ";
          ipi = "ipconfig getifaddr en0";
          ipe = "curl ifconfig.me";
          # Media
          to_webp = ''for i in *.* ; do cwebp -q 80 "$i" -o "''${i%.*}.webp" ; done'';
          to_png = ''for i in *.* ; do convert "''$i" "''${i%.*}.png" ; done'';
          to_mp4 = ''for i in *.* ; do ffmpeg -i "''$i" "''${i%.*}-o.mp4" ; done'';
          dl = "yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 ''$1";
          dl_mp3 = "yt-dlp --extract-audio --audio-format mp3 ''$1";
          # Misc
          tb = "nc termbin.com 9999";
          wttr = "curl v2.wttr.in/Munich";
          ms = "meilisearch --db-path ~/data.ms";
          # Docker
          dip = "docker image prune";
          dls = "docker ps";
          dlsa = "docker ps -a";
          dcu = "docker-compose up";
          dcd = "docker-compose down";
          dcdv = "docker-compose down -v";
          # lnjava = "sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk";
          # Node
          p = "pnpm";
          nls = "npm list -g --depth 0";
          yat = "yarn add -D postcss tailwindcss @tailwindcss/forms @tailwindcss/typography @tailwindcss/aspect-ratio";
          # reshim = "asdf reshim nodejs";
          init_cz = "commitizen init cz-conventional-changelog --yarn --dev --exact";
          vscode_ls = "code --list-extensions | xargs -L 1 echo code --install-extension";
          # React
          rna = "npx react-native run-android";
          # React Native
          adbr = "adb reverse tcp:8081 tcp:8081"; # reconnect metro bundler
          # Terraform
          tf = "tf $1";
          # Kubernetes
          k = "kubectl";
          t = "task";
          tl = "task --list-all";
          # Credentials
          # google_cred="export GOOGLE_APPLICATION_CREDENTIALS='~/service-account.json'";
          # avd="cd ~/Library/Android/sdk/emulator/ && ./emulator -avd Pixel_3_API_29";
          # chrome_dbg="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222";
        }
        // lib.optionalAttrs isDarwin {
          rni = "npx react-native run-ios";
          o = "open";
          iosd = "xcrun xctrace list devices"; # shows iOS devices
        };
      prezto = {
        enable = true;
        pmodules = lib.flatten ([
            "git"
          ]
          ++ lib.optional isDarwin [
            "osx"
            "homebrew"
          ]);
      };
      # Can be fetched /w nix-prefetch-github zsh-users zsh-autosuggestions
      plugins = [
        {
          name = "zsh-autosuggestions";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-autosuggestions";
            rev = "0e810e5afa27acbd074398eefbe28d13005dbc15";
            hash = "sha256-85aw9OM2pQPsWklXjuNOzp9El1MsNb+cIiZQVHUzBnk=";
          };
        }
        {
          name = "zsh-completions";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-completions";
            rev = "85e041be36a33d8f6ca71746654406425d3a910f";
            sha256 = "sha256-jamYAmvanI/upc1PsRA/6VLiER8qJ3kOCgXsPT9WkYU";
          };
        }
        {
          name = "aws";
          file = "aws.plugin.zsh";
          src =
            pkgs.fetchFromGitHub
            {
              owner = "ohmyzsh";
              repo = "ohmyzsh";
              rev = "33d4db7feeacaf82c8e277555010cd6f5d9f1c7c";
              hash = "sha256-uTyUXEqPblKTyy08OQj2EuzadQMqzY7rjWg3sbT+EHs=";
            }
            + "/plugins/aws";
        }
        {
          name = "enhancd";
          file = "init.sh";
          src = pkgs.fetchFromGitHub {
            owner = "babarot";
            repo = "enhancd";
            rev = "5afb4eb6ba36c15821de6e39c0a7bb9d6b0ba415";
            sha256 = "sha256-pKQbwiqE0KdmRDbHQcW18WfxyJSsKfymWt/TboY2iic=";
          };
        }
      ];
    };
  };
}
