({ config, profile, lib, pkgs, ... }: {
  imports = [
    ../../home/bat
    ../../home/eza
    ../../home/fzf
    ../../home/git
    ../../home/nnn
    ../../home/nvim
    ../../home/starship
    ../../home/zellij
    ../../home/zoxide
    ../../home/zsh
  ];

  home = {
    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    packages = [
      pkgs.ack # A grep-like tool tailored to working with large trees of source code
      pkgs.age # Modern encryption tool with small explicit keys
      pkgs.awscli2 # Unified tool to manage your AWS services
      pkgs.btop # A monitor of resources
      pkgs.caddy # Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS
      pkgs.cargo-zigbuild # A tool to compile Cargo projects with zig as the linker
      pkgs.certstrap # Tools to bootstrap CAs, certificate requests, and signed certificates
      pkgs.cmake # CMake is an open-source, cross-platform family of tools designed to build, test and package software
      pkgs.curl # A command line tool for transferring files with URL syntax
      pkgs.dbmate # Database migration tool
      pkgs.direnv # A shell extension that manages your environment
      pkgs.dive # A tool for exploring each layer in a docker image
      pkgs.docker # NVIDIA Container Toolkit
      pkgs.docker-compose # Multi-container orchestration for Docker
      pkgs.eza # A modern, maintained replacement for ls
      pkgs.fclones # Efficient Duplicate File Finder and Remover
      pkgs.fd # Suite of speech signal processing tools
      pkgs.ffmpeg # A complete, cross-platform solution to record, convert and stream audio and video (Jellyfin fork)
      pkgs.fnm # Fast and simple Node.js version manager
      pkgs.fx # Terminal JSON viewer
      pkgs.fzf # A command-line fuzzy finder
      pkgs.gawk # GNU implementation of the Awk programming language
      pkgs.gh # GitHub CLI tool
      pkgs.git # Distributed version control system
      pkgs.git-lfs # Git extension for versioning large files
      pkgs.gitui # Blazing fast terminal-ui for Git written in Rust
      pkgs.glances # Cross-platform curses-based monitoring tool
      pkgs.gnupg # Modern release of the GNU Privacy Guard, a GPL OpenPGP implementation
      pkgs.gnused # GNU sed, a batch stream editor
      pkgs.gnutls # The GNU Transport Layer Security Library
      pkgs.go # The Go Programming language
      pkgs.gomplate # A flexible commandline tool for template rendering
      pkgs.graphicsmagick # Swiss army knife of image processing
      pkgs.hexyl # A command-line hex viewer
      pkgs.htop # An interactive process viewer for Linux, with vim-style keybindings
      pkgs.httpstat # curl statistics made simple
      pkgs.hyperfine # Command-line benchmarking tool
      pkgs.imagemagick # A software suite to create, edit, compose, or convert bitmap images
      pkgs.inetutils # Collection of common network programs
      pkgs.ipcalc # Simple IP network calculator
      pkgs.jq # A lightweight and flexible command-line JSON processor
      pkgs.k3d # A helper to run k3s (Lightweight Kubernetes. 5 less than k8s) in a docker container
      pkgs.k9s # Kubernetes CLI To Manage Your Clusters In Style
      pkgs.kubectl # Production-Grade Container Scheduling and Management
      pkgs.lazydocker # A simple terminal UI for both docker and docker-compose
      pkgs.lazygit # Simple terminal UI for git commands
      pkgs.less # A more advanced file pager than 'more'
      pkgs.lnav # The Logfile Navigator
      pkgs.master.plow # A high-performance HTTP benchmarking tool that includes a real-time web UI and terminal display
      pkgs.master.yt-dlp # Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
      pkgs.mutagen # Make remote development work with your local tools
      pkgs.mutagen-compose # Compose with Mutagen integration
      pkgs.ncdu # Disk usage analyzer with an ncurses interface
      pkgs.neofetch # A fast, highly customizable system info script
      pkgs.ngrok # A Python wrapper for ngrok
      pkgs.nix-prefetch-github # Prefetch sources from github
      pkgs.alejandra # Nix code formatter
      pkgs.nmap # A free and open source utility for network discovery and security auditing
      pkgs.nodePackages_latest.aws-cdk # CDK Toolkit, the command line tool for CDK apps
      pkgs.pandoc # Conversion between documentation formats
      pkgs.parallel # Shell tool for executing jobs in parallel
      pkgs.pv # A Wave-to-Notes transcriber
      pkgs.ripgrep # A utility that combines the usability of The Silver Searcher with the raw speed of grep
      pkgs.rsync # Fast incremental file transfer utility
      pkgs.rustup # The Rust toolchain installer
      pkgs.smartmontools # Tools for monitoring the health of hard drives
      pkgs.speedtest-cli # Command line interface for testing internet bandwidth using speedtest.net
      pkgs.stylua # An opinionated Lua code formatter
      pkgs.subversion # A version control system intended to be a compelling replacement for CVS in the open source community
      pkgs.terraform # OpenTofu, Terraform, Terragrunt and Atmos version manager written in Go
      pkgs.tmux # Terminal multiplexer
      pkgs.tree # Command to produce a depth indented directory listing
      pkgs.trippy # A network diagnostic tool
      pkgs.upx # The Ultimate Packer for eXecutables
      pkgs.wget # Tool for retrieving files using HTTP, HTTPS, and FTP
      pkgs.yq # Portable command-line YAML processor
      pkgs.yubikey-personalization # A library and command line tool to personalize YubiKeys
      pkgs.zellij # A terminal workspace with batteries included
      pkgs.zig # General-purpose programming language and toolchain for maintaining robust, optimal, and reusable software
      pkgs.zoxide # A fast cd command that learns your habits
      pkgs.zsh # The Z shell
    ];
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
      profileExtra = '' '';
      prezto = {
        enable = true;
        pmodules = [
          "git"
        ];
      };
      sessionVariables = {
        NEXT_TELEMETRY_DISABLED = 1;
        MEILI_NO_ANALYTICS = true;
      };
      shellAliases = {
        # Abbreviations
        c = "clear";
        m = "make";
        n = "nvim";
        o = "open";
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
    };
  };
})
