({ config, profile, lib, pkgs, ... }: {
  imports = [
    ../home/bat
    ../home/eza
    ../home/fzf
    ../home/git
    ../home/nnn
    ../home/nvim
    ../home/starship
    ../home/zellij
    ../home/zoxide
    ../home/zsh
    ./${profile}
  ];

  home = {
    stateVersion = "24.11";
    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "nvim";
      VISUAL = "nvim";
      GSETTINGS_SCHEMA_DIR = "/opt/homebrew/share/glib-2.0/schemas";
    };
    file = {
      ".config/ghostty/config".source = ./../config/ghostty/config;
    };
    packages = [
      # Not needed as home-manager installs it's own configured version
      # pkgs.cfssl
      # pkgs.darwin.libiconv # required for -liconv mitmproxy compilation
      # pkgs.httpie
      # pkgs.lima
      # pkgs.mitmproxy
      # pkgs.nats-server
      # pkgs.natscli
      # pkgs.neovim
      # pkgs.redis
      # pkgs.vector
      # pkgs.watchman
      pkgs.ack
      pkgs.act
      pkgs.age
      pkgs.awscli2
      pkgs.btop
      pkgs.bun
      pkgs.caddy
      pkgs.cairo
      pkgs.cargo-nextest
      pkgs.cargo-sweep
      pkgs.cargo-watch
      pkgs.cargo-zigbuild
      pkgs.certstrap
      pkgs.cmake
      pkgs.cowsay
      pkgs.curl
      pkgs.dbmate
      pkgs.direnv
      pkgs.dive
      pkgs.docker
      pkgs.docker-compose
      pkgs.emacs
      pkgs.eza
      pkgs.fclones
      pkgs.fd
      pkgs.ffmpeg
      pkgs.fnm
      pkgs.fx
      pkgs.fzf
      pkgs.gawk
      pkgs.gh
      pkgs.git
      pkgs.git-lfs
      pkgs.git-trim
      pkgs.gitui
      pkgs.glances
      pkgs.glow
      pkgs.gnupg
      pkgs.gnused
      pkgs.gnutls
      pkgs.go
      pkgs.gomplate
      pkgs.google-cloud-sdk
      pkgs.graphicsmagick
      pkgs.graphviz
      pkgs.helix
      pkgs.hexyl
      pkgs.htop
      pkgs.httpstat
      pkgs.hyperfine
      pkgs.imagemagick
      pkgs.inetutils
      pkgs.ipcalc
      pkgs.irssi
      pkgs.jq
      pkgs.jwt-cli
      pkgs.k3d
      pkgs.k9s
      pkgs.kubectl
      pkgs.lazydocker
      pkgs.lazygit
      pkgs.less
      pkgs.libavif
      pkgs.lnav
      /* pkgs.stable.bitwarden-cli */
      pkgs.master.cargo-lambda
      pkgs.master.cargo-tauri
      pkgs.master.plow
      pkgs.master.yt-dlp
      pkgs.mutagen
      pkgs.mutagen-compose
      pkgs.ncdu
      pkgs.neofetch
      pkgs.ngrok
      pkgs.nix-prefetch-github
      pkgs.nixpkgs-fmt
      pkgs.nmap
      pkgs.nodePackages_latest.aws-cdk
      pkgs.pandoc
      pkgs.parallel
      pkgs.psutils
      pkgs.pv
      pkgs.ripgrep
      pkgs.rsync
      pkgs.rustup
      pkgs.scrcpy
      pkgs.sea-orm-cli
      pkgs.smartmontools
      pkgs.speedtest-cli
      pkgs.stow
      pkgs.stylua
      pkgs.subversion
      pkgs.terraform
      pkgs.tmux
      pkgs.tree
      pkgs.trippy
      pkgs.trivy
      pkgs.typeshare
      pkgs.upx
      pkgs.wget
      pkgs.yq
      pkgs.yubikey-manager
      pkgs.yubikey-personalization
      pkgs.zellij
      pkgs.zig
      pkgs.zoxide
      pkgs.zsh
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
      profileExtra = ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      '';
      prezto = {
        enable = true;
        pmodules = [
          "git"
          "osx"
          "homebrew"
        ];
      };
      sessionVariables = {
        NEXT_TELEMETRY_DISABLED = 1;
        MEILI_NO_ANALYTICS = true;
        PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = true;
        PUPPETEER_EXECUTABLE_PATH = "which chromium";
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
