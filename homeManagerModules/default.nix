({
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  imports = [
    ./bat
    ./eza
    ./fzf
    ./git
    ./nnn
    ./nvim
    ./starship
    ./yazi
    ./zellij
    ./zoxide
    ./zsh
  ];

  options.homeManagerModules = lib.mkOption {
    type = lib.types.submodule {
      options = {
        minimal = lib.mkOption {
          default = true;
          type = lib.types.bool;
          description = "Install minimal software";
        };
        developer = lib.mkOption {
          type = lib.types.bool;
          description = "Install developer software";
        };
        personal = lib.mkOption {
          type = lib.types.bool;
          description = "Install personal software";
        };
        work = lib.mkOption {
          type = lib.types.bool;
          description = "Install work software";
        };
        hipster = lib.mkOption {
          type = lib.types.bool;
          description = "Install hipster software";
        };
      };
    };
  };

  config = {
    home = {
      stateVersion = "24.05";
      sessionVariables =
        {
          PAGER = "less";
          CLICLOLOR = 1;
          EDITOR = "nvim";
          VISUAL = "nvim";
        }
        // lib.optionalAttrs isDarwin
        {
          GSETTINGS_SCHEMA_DIR = "/opt/homebrew/share/glib-2.0/schemas";
        };
      file =
        {}
        // lib.optionalAttrs
        isDarwin
        {
          ".config/ghostty/config".source = ./../config/ghostty/config;
          ".config/iterm2/com.googlecode.iterm2.plist".source = ./../config/iterm2/com.googlecode.iterm2.plist;
          ".config/iterm2/nordic_light.itermcolors".source = ./../config/iterm2/nordic_light.itermcolors;
          ".config/iterm2/nordic_dark.itermcolors".source = ./../config/iterm2/nordic_dark.itermcolors;
        };

      # pkgs.cfssl # Cloudflare's PKI and TLS toolkit
      # pkgs.httpie # A command line HTTP client whose goal is to make CLI human-friendly
      # pkgs.nats-server # High-Performance server for NATS
      # pkgs.natscli # NATS Command Line Interface
      # pkgs.neovim # Vim text editor fork focused on extensibility and agility
      # pkgs.redis # An open source, advanced key-value store
      # pkgs.stable.bitwarden-cli # A secure and free password manager for all of your devices
      # pkgs.vector # A high-performance observability data pipeline
      # pkgs.watchman # Watches files and takes action when they change
      packages = lib.flatten ([]
        ++ lib.optional isDarwin [
          pkgs.gnupg # Modern release of the GNU Privacy Guard, a GPL OpenPGP implementation
          pkgs.gnused # GNU sed, a batch stream editor
          pkgs.gnutls # The GNU Transport Layer Security Library
          pkgs.gawk # GNU implementation of the Awk programming language
          # pkgs.lima # Linux virtual machines (on macOS, in most cases)
          # pkgs.mitmproxy # Man-in-the-middle proxy
          # pkgs.darwin.libiconv # required for -liconv mitmproxy compilation
        ]
        ++ lib.optional (config.homeManagerModules.minimal && lib.optional builtins.currentSystem == "aarch64-darwin") [
          pkgs.fclones # Efficient Duplicate File Finder and Remover - does not work on x86_64
        ]
        ++ lib.optional config.homeManagerModules.minimal [
          pkgs.ack # A grep-like tool tailored to working with large trees of source code
          pkgs.curl # A command line tool for transferring files with URL syntax
          pkgs.eza # A modern, maintained replacement for ls
          pkgs.fd # Suite of speech signal processing tools
          pkgs.fzf # Fuzzy finder for your shell
          pkgs.git # Distributed version control system
          pkgs.git-lfs # Git extension for versioning large files
          pkgs.git-trim # Automatically trims your branches whose tracking remote refs are merged or gone
          pkgs.gitui # Blazing fast terminal-ui for Git written in Rust
          pkgs.htop # An interactive process viewer for Linux, with vim-style keybindings
          pkgs.jq # A lightweight and flexible command-line JSON processor
          pkgs.lazygit # Simple terminal UI for git commands
          pkgs.less # A more advanced file pager than 'more'
          pkgs.neofetch # A fast, highly customizable system info script
          pkgs.parallel # Shell tool for executing jobs in parallel
          pkgs.ripgrep # A utility that combines the usability of The Silver Searcher with the raw speed of grep
          pkgs.rsync # Fast incremental file transfer utility
          pkgs.stow # A tool for managing the installation of multiple software packages in the same run-time directory tree
          pkgs.subversion # A version control system intended to be a compelling replacement for CVS in the open source community
          pkgs.tmux # Terminal multiplexer
          pkgs.tree # Command to produce a depth indented directory listing
          pkgs.wget # Tool for retrieving files using HTTP, HTTPS, and FTP
          pkgs.yazi # A fast, modern, and minimalistic cli file explorer
          pkgs.yq # Portable command-line YAML processor
          pkgs.zoxide # A fast cd command that learns your habits
          pkgs.zsh # The Z shell
          pkgs.alejandra # Nix code formatter
          pkgs.nix-prefetch-github # Prefetch sources from github
          # pkgs.nixpkgs-fmt # Nix code formatter for nixpkgs
        ]
        ++ lib.optional config.homeManagerModules.developer [
          # Development
          pkgs.cargo-nextest # Next-generation test runner for Rust projects
          pkgs.cargo-watch # A Cargo subcommand for watching over Cargo project's source
          pkgs.cargo-zigbuild # A tool to compile Cargo projects with zig as the linker
          pkgs.cmake # CMake is an open-source, cross-platform family of tools designed to build, test and package software
          pkgs.master.cargo-lambda # A Cargo subcommand to help you work with AWS Lambda
          pkgs.master.cargo-sweep # A Cargo subcommand for cleaning up unused build files generated by Cargo
          pkgs.master.cargo-tauri # Build smaller, faster, and more secure desktop applications with a web frontend
          pkgs.pandoc # Conversion between documentation formats
          pkgs.rustup # The Rust toolchain installer
          pkgs.stylua # An opinionated Lua code formatter
          pkgs.typeshare # Command Line Tool for generating language files with typeshare
          pkgs.upx # The Ultimate Packer for eXecutables
          pkgs.zellij # A terminal workspace with batteries included
          pkgs.zig # General-purpose programming language and toolchain for maintaining robust, optimal, and reusable software
          # Runtimes
          pkgs.fnm # Fast and simple Node.js version manager
          pkgs.bun # Incredibly fast JavaScript runtime, bundler, transpiler and package manager – all in one
          pkgs.go # The Go Programming language
          # Containers
          pkgs.dive # A tool for exploring each layer in a docker image
          pkgs.docker # NVIDIA Container Toolkit
          pkgs.docker-compose # Multi-container orchestration for Docker
          pkgs.k3d # A helper to run k3s (Lightweight Kubernetes. 5 less than k8s) in a docker container
          pkgs.k9s # Kubernetes CLI To Manage Your Clusters In Style
          pkgs.kubectl # Production-Grade Container Scheduling and Management
          pkgs.lazydocker # A simple terminal UI for both docker and docker-compose
          # Helpers
          pkgs.scrcpy # Display and control Android devices over USB or TCP/IP
          pkgs.age # Modern encryption tool with small explicit keys
          pkgs.direnv # A shell extension that manages your environment
          pkgs.jwt-cli # Super fast CLI tool to decode and encode JWTs
          pkgs.hexyl # A command-line hex viewer
          pkgs.fx # Terminal JSON viewer
          pkgs.glow # Render markdown on the CLI, with pizzazz!
          pkgs.certstrap # Tools to bootstrap CAs, certificate requests, and signed certificates
          pkgs.graphviz # Graph visualization tools
          pkgs.gomplate # A flexible commandline tool for template rendering
          pkgs.lnav # The Logfile Navigator
          # Database
          pkgs.dbmate # Database migration tool
          pkgs.sea-orm-cli #  Command line utility for SeaORM
          # GitHub
          pkgs.act # Run your GitHub Actions locally
          pkgs.gh # GitHub CLI tool
          # Monitoring, Network and Benchmarking
          pkgs.btop # A monitor of resources
          pkgs.glances # Cross-platform curses-based monitoring tool
          pkgs.ncdu # Disk usage analyzer with an ncurses interface
          pkgs.smartmontools # Tools for monitoring the health of hard drives
          pkgs.trivy # A simple and comprehensive vulnerability scanner for containers, suitable for CI
          pkgs.httpstat # curl statistics made simple
          pkgs.hyperfine # Command-line benchmarking tool
          pkgs.inetutils # Collection of common network programs
          pkgs.ipcalc # Simple IP network calculator
          pkgs.master.plow # A high-performance HTTP benchmarking tool that includes a real-time web UI and terminal display
          pkgs.ngrok # A Python wrapper for ngrok
          pkgs.nmap # A free and open source utility for network discovery and security auditing
          pkgs.speedtest-cli # Command line interface for testing internet bandwidth using speedtest.net
          pkgs.trippy # A network diagnostic tool
          # Cloud platforms
          pkgs.awscli2 # Unified tool to manage your AWS services
          pkgs.google-cloud-sdk # Tools for the google cloud platform
          pkgs.nodePackages_latest.aws-cdk # CDK Toolkit, the command line tool for CDK apps
          pkgs.terraform # OpenTofu, Terraform, Terragrunt and Atmos version manager written in Go
          # Graphics and media
          pkgs.cairo # A 2D graphics library with support for multiple output devices
          pkgs.ffmpeg # A complete, cross-platform solution to record, convert and stream audio and video (Jellyfin fork)
          pkgs.graphicsmagick # Swiss army knife of image processing
          pkgs.imagemagick # A software suite to create, edit, compose, or convert bitmap images
          pkgs.libavif # C implementation of the AV1 Image File Format
          pkgs.master.yt-dlp # Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
          pkgs.psutils # Collection of useful utilities for manipulating PS documents
          # Yubikey
          # pkgs.yubikey-manager # Command line tool for configuring any YubiKey over all USB transports
          # pkgs.yubikey-personalization # A library and command line tool to personalize YubiKeys
        ]
        ++ lib.optional config.homeManagerModules.personal [
          pkgs.master.stripe-cli # A command-line tool for Stripe
          pkgs.meilisearch # Powerful, fast, and an easy to use search engine
          pkgs.caddy # Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS
        ]
        ++ lib.optional config.homeManagerModules.work [
          pkgs.aws-iam-authenticator # AWS IAM credentials for Kubernetes authentication
          pkgs.goreleaser # Deliver Go binaries as fast and easily as possible
          pkgs.lua51Packages.busted # Elegant Lua unit testing
          pkgs.lua51Packages.lua # Powerful, fast, lightweight, embeddable scripting language
          pkgs.lua51Packages.luacheck # A static analyzer and a linter for Lua
          pkgs.lua51Packages.luafilesystem # File System Library for the Lua Programming Language
          pkgs.lua51Packages.luarocks # A package manager for Lua
          pkgs.master.go-task # A task runner / simpler Make alternative written in Go
        ]
        ++ lib.optional config.homeManagerModules.hipster [
          # Hipster Editors
          pkgs.emacs # The extensible, customizable GNU text editor
          pkgs.helix # A post-modern modal text editor
          # Misc
          # pkgs.cowsay # Cowsay reborn, written in Go
          # pkgs.irssi # Terminal based IRC client
          # pkgs.mutagen # Make remote development work with your local tools
          # pkgs.mutagen-compose # Compose with Mutagen integration
          # pkgs.pv # A Wave-to-Notes transcriber
        ]);
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
        profileExtra = lib.mkIf isDarwin ''
          eval "$(/opt/homebrew/bin/brew shellenv)"
        '';
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
        sessionVariables = {
          NEXT_TELEMETRY_DISABLED = 1;
          MEILI_NO_ANALYTICS = true;
          PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = true;
          PUPPETEER_EXECUTABLE_PATH = "which chromium";
        };
        shellAliases =
          {
            # Abbreviations
            c = "clear";
            m = "make";
            n = "nvim";
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
      };
    };
  };
})
