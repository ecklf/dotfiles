({ config, lib, pkgs, ... }: {
  imports = [
    ../modules/home-manager/modules/git
    ../modules/home-manager/modules/nvim
  ];

  home = {
    stateVersion = "23.05";
    packages = [ pkgs.ripgrep pkgs.fd pkgs.curl pkgs.less ];
    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "nvim";
    };
  };

  programs = {
    git = {
      enable = true;
      lfs = {
        enable = true;
        # Skip automatic downloading of objects. Requires a manual `git lfs pull`
        skipSmudge = false;
      };
      ignores = [
        ".DS_Store"
        ".idea"
        ".scratch"
        "__scratch"
      ];
      # signing = {
      #   signByDefault = true;
      #   signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBY2vg6JN45hpcl9HH279/ityPEGGOrDjY3KdyulOUmX";
      # };
      extraConfig = {
        # Sign all commits using ssh key
        commit.gpgsign = true;
        gpg.format = "ssh";
        user.signingkey = "~/.ssh/id_ed25519.pub";
        # ssh.program = "/usr/local/bin/op-ssh-sign";
      };
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        # Abbreviations
        c = "clear";
        m = "make";
        n = "nvim";
        o = "open";
        p = "python3";
        # General
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
        to_webp = ''for i in *.* ; do cwebp -q 80 "$i " -o "''${i%.*}.webp" ; done'';
        to_png = ''for i in *.* ; do convert "''$i " "''${i%.*}.png" ; done'';
        dl = "youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 ''$1";
        dl_mp3 = "youtube-dl --extract-audio --audio-format mp3 ''$1";
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
        # Redis
        # rdbu="brew services start redis";
        # rdbd="brew services stop redis";
        # rdbr="brew services restart redis";
        # PostgreSQL 
        # pdbu="brew services start postgresql@15";
        # pdbd="brew services stop postgresql@15";
        # pdbr="brew services restart postgresql@15";;
        # Node
        nls = "npm list -g --depth 0";
        yat = "yarn add -D postcss tailwindcss @tailwindcss/forms @tailwindcss/typography @tailwindcss/aspect-ratio";
        # reshim = "asdf reshim nodejs";
        init_cz = "commitizen init cz-conventional-changelog --yarn --dev --exact";
        vscode_ls = "code --list-extensions | xargs -L 1 echo code --install-extension";
        # React
        rni = "npx react-native run-ios";
        rna = "npx react-native run-android";
        # React Native
        adbr = "adb reverse tcp:8081 tcp:8081"; # reconnect metro bundler
        iosd = "xcrun xctrace list devices"; # shows iOS devices
        # Terraform
        tf = "tf $1";
        # Credentials 
        # google_cred="export GOOGLE_APPLICATION_CREDENTIALS='~/service-account.json'";
        # avd="cd ~/Library/Android/sdk/emulator/ && ./emulator -avd Pixel_3_API_29";
        # chrome_dbg="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222";
      };
      profileExtra = ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      '';
      zsh-abbr.abbreviations = { };
      # Whether to enable Bash And Zsh shell history suggest box - easily view, navigate, search and manage your command history
      # programs.hstr.enable = true;
      prezto = {
        enable = true;
        pmodules = [
          "osx"
          "homebrew"
        ];
      };
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
        ignorePatterns = [ ];
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
      initExtraFirst = ''
        # Disable macOS Dock bouncing (xterm bellIsUrgent)
        printf "\e[?1042l"
        # Emacs keybindings
        bindkey -e 
        # Map end-of-line key in the same way as zprezto editor module to prevent issue with tmux-resurrect.
        bindkey "^E" end-of-line 
        # Allow pipe to existing file. Prevent issue with history save in tmux-resurrect.
        setopt CLOBBER 
      '';
      initExtraBeforeCompInit = ''
        zstyle ':completion:*' menu select
        zmodload zsh/complist
      '';
      initExtra = ''
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
      '';
      # Can be fetched /w nix-prefetch-github zsh-users zsh-autosuggestions
      plugins =
        [
          {
            name = "zsh-autosuggestions";
            src = pkgs.fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-autosuggestions";
              rev = "c3d4e576c9c86eac62884bd47c01f6faed043fc5";
              hash = "sha256-B+Kz3B7d97CM/3ztpQyVkE6EfMipVF8Y4HJNfSRXHtU=";
            };
          }
          {
            name = "zsh-completions";
            src = pkgs.fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-completions";
              rev = "9e341f6a202e83e2dc0a587f4970fa375de84d4e";
              sha256 = "sha256-HVuCHOCP2zeUY59JYhzQi6tHYBDUwNeY5fm8pALVxpc=";
            };
          }
          {
            name = "enhancd";
            file = "init.sh";
            src = pkgs.fetchFromGitHub {
              owner = "babarot";
              repo = "enhancd";
              rev = "230695f8da8463b18121f58d748851a67be19a00";
              sha256 = "sha256-XJl0XVtfi/NTysRMWant84uh8+zShTRwd7t2cxUk+qU=";
            };
          }
        ];
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
      # SPACESHIP_VI_MODE_SHOW=false
      # SPACESHIP_PACKAGE_PREFIX="\n"
      # SPACESHIP_GIT_PREFIX="\n"
      # SPACESHIP_NODE_PREFIX="\n"
      # SPACESHIP_PACKAGE_SHOW=true
      # SPACESHIP_CHAR_COLOR_SUCCESS="green"
      # SPACESHIP_CHAR_COLOR_SUCCESS="white"
      settings = {
        add_newline = false;
        gcloud = {
          disabled = true;
        };
        docker_context = {
          disabled = true;
        };
        # format = lib.concatStrings [
        #   "$line_break"
        #   "$package"
        #   "$line_break"
        #   "$character"
        # ];
        scan_timeout = 10;
        character = {
          success_symbol = "▲";
          error_symbol = "▲";
        };
      };
    };
    zellij = {
      enable = true;
      enableZshIntegration = false;
      settings = {
        theme = "catppuccin-mocha";
        default_layout = "default"; # compact
      };
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    bat = {
      enable = true;
      config.theme = "TwoDark";
    };
    eza = {
      enable = true;
      enableAliases = true;
      extraOptions = [
        "-G"
      ];
      icons = true;
      git = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    alacritty = {
      enable = true;
      settings.font.normal.family = "JetBrainsMono Nerd Font Mono";
      settings.font.size = 16;
    };
  };
})
