{
  system,
  lib,
  config,
  pkgs,
  homeStateVersion,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  imports = [
    ./bat
    ./btop
    ./direnv
    ./eza
    ./fzf
    ./gh
    ./git
    ./gpg
    ./jq
    ./nnn
    ./nvim
    ./ripgrep
    ./ssh
    ./starship
    ./tmux
    ./yazi
    ./zellij
    ./zoxide
    ./zsh
  ];

  options.home.modules = lib.mkOption {
    type = lib.types.submodule {
      options = {
        minimal = lib.mkOption {
          default = true;
          type = lib.types.bool;
          description = "Install minimal software";
        };
        developer = lib.mkOption {
          default = false;
          type = lib.types.bool;
          description = "Install developer software";
        };
        personal = lib.mkOption {
          default = false;
          type = lib.types.bool;
          description = "Install personal software";
        };
        work = lib.mkOption {
          default = false;
          type = lib.types.bool;
          description = "Install work software";
        };
        hipster = lib.mkOption {
          default = false;
          type = lib.types.bool;
          description = "Install hipster software";
        };
        modelling = lib.mkOption {
          default = false;
          type = lib.types.bool;
          description = "Install software for 3D modelling";
        };
        extraPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [];
          description = "Extra packages to install";
        };
      };
    };
  };

  config = {
    home = {
      stateVersion = homeStateVersion;
      sessionVariables =
        {
          PAGER = "less";
          MANPAGER = "less";
          CLICLOLOR = 1;
          EDITOR = "nvim";
          VISUAL = "nvim";
        }
        // lib.optionalAttrs (isDarwin && system == "aarch64-darwin")
        {
          GSETTINGS_SCHEMA_DIR = "/opt/homebrew/share/glib-2.0/schemas";
        };
      file =
        {}
        // lib.optionalAttrs
        isDarwin
        {
          ".config/ghostty/config".source = ./config/ghostty/config;
          ".config/ghostty/themes".source = ./config/ghostty/themes;
          ".config/opencode/opencode.jsonc".source = ./config/opencode/opencode.jsonc;
          ".config/opencode/plugins".source = ./config/opencode/plugins;
          ".config/opencode/commands".source = ./config/opencode/commands;
          ".config/iterm2/com.googlecode.iterm2.plist".source = ./config/iterm2/com.googlecode.iterm2.plist;
          ".config/iterm2/nordic_light.itermcolors".source = ./config/iterm2/nordic_light.itermcolors;
          ".config/iterm2/nordic_dark.itermcolors".source = ./config/iterm2/nordic_dark.itermcolors;
          ".wezterm.lua".source = ./config/wezterm/config.lua;
          ".lmstudio/config-presets".source = ./config/lmstudio/config-presets;
        };

      packages = lib.flatten (
        config.home.modules.extraPackages
        ++ lib.optional isDarwin [
          pkgs.mas # Mac App Store command line interface
          # pkgs.gnupg # Managed by programs.gpg
          pkgs.gnused # GNU sed, a batch stream editor
          pkgs.gnutls # The GNU Transport Layer Security Library
          pkgs.gawk # GNU implementation of the Awk programming language
          # pkgs.lima # Linux virtual machines (on macOS, in most cases)
          # pkgs.mitmproxy # Man-in-the-middle proxy
          # pkgs.darwin.libiconv # required for -liconv mitmproxy compilation
        ]
        ++ lib.optional (config.home.modules.minimal && system == "aarch64-darwin") [
          # Fails to compile on x86_64
          pkgs.fclones # Efficient Duplicate File Finder and Remover
        ]
        ++ lib.optional config.home.modules.minimal [
          # pkgs.master.gitui # Blazing fast terminal-ui for Git written in Rust
          # pkgs.nixpkgs-fmt # Nix code formatter for nixpkgs
          pkgs.ack # A grep-like tool tailored to working with large trees of source code
          pkgs.alejandra # Nix code formatter
          pkgs.curl # A command line tool for transferring files with URL syntax
          # pkgs.direnv # Managed by programs.direnv
          pkgs.eza # A modern, maintained replacement for ls
          pkgs.fd # Suite of speech signal processing tools
          pkgs.fnm # Fast and simple Node.js version manager
          pkgs.fzf # Fuzzy finder for your shell
          pkgs.git # Distributed version control system
          pkgs.git-lfs # Git extension for versioning large files
          pkgs.git-trim # Automatically trims your branches whose tracking remote refs are merged or gone
          pkgs.htop # An interactive process viewer for Linux, with vim-style keybindings
          # pkgs.jq # Managed by programs.jq
          pkgs.lazygit # Simple terminal UI for git commands
          pkgs.less # A more advanced file pager than 'more'
          pkgs.go-task # A task runner / simpler Make alternative written in Go
          pkgs.most # A pager with syntax highlighting for man pages
          pkgs.neofetch # A fast, highly customizable system info script
          pkgs.nix-prefetch-github # Prefetch sources from github
          pkgs.parallel # Shell tool for executing jobs in parallel
          pkgs.pv # Tool for monitoring the progress of data through a pipeline
          pkgs.rclone # Command line program to sync files and directories to and from major cloud storage
          pkgs.repgrep # Interactive replacer for ripgrep that makes it easy to find and replace across files on the command line
          # pkgs.ripgrep # Managed by programs.ripgrep
          pkgs.rsync # Fast incremental file transfer utility
          pkgs.stow # A tool for managing the installation of multiple software packages in the same run-time directory tree
          pkgs.subversion # A version control system intended to be a compelling replacement for CVS in the open source community
          pkgs.tree # Command to produce a depth indented directory listing
          pkgs.wget # Tool for retrieving files using HTTP, HTTPS, and FTP
          pkgs.yazi # A fast, modern, and minimalistic cli file explorer
          pkgs.yq # Portable command-line YAML processor
          pkgs.zellij # A terminal workspace with batteries included
          pkgs.zoxide # A fast cd command that learns your habits
          pkgs.zsh # The Z shell
        ]
        ++ lib.optional config.home.modules.developer [
          # Embedded
          pkgs.elf2uf2-rs # A tool to convert ELF files to UF2 format for flashing microcontrollers
          pkgs.probe-rs-tools # CLI tool for on-chip debugging and flashing of ARM chips
          # pkgs.gdb # The GNU Project debugger
          pkgs.openocd # On-Chip Debugging, In-System Programming and Boundary-Scan Testing for Embedded Target Devices
          # AI agents
          pkgs.claude-code
          pkgs.crush
          pkgs.master.opencode
          # Utilities
          pkgs.ncdu # Disk usage analyzer with an ncurses interface
          pkgs.rmlint # Extremely fast tool to remove duplicates filesystem
          pkgs.ntfy # Utility for sending notifications, on demand and when commands finish
          # Development
          pkgs.cargo-nextest # Next-generation test runner for Rust projects
          pkgs.cargo-watch # A Cargo subcommand for watching over Cargo project's source
          pkgs.cargo-zigbuild # A tool to compile Cargo projects with zig as the linker
          pkgs.cargo-binstall # A Cargo subcommand to install Rust binaries
          pkgs.cargo-binutils # Cargo integration for LLVM's binary utilities
          pkgs.cmake # CMake is an open-source, cross-platform family of tools designed to build, test and package software
          pkgs.cargo-lambda # A Cargo subcommand to help you work with AWS Lambda
          pkgs.cargo-sweep # A Cargo subcommand for cleaning up unused build files generated by Cargo
          pkgs.cargo-tauri # Build smaller, faster, and more secure desktop applications with a web frontend
          pkgs.cargo-release # A Cargo subcommand to help you release your Rust projects
          pkgs.pandoc # Conversion between documentation formats
          pkgs.rustup # The Rust toolchain installer
          pkgs.stylua # An opinionated Lua code formatter
          pkgs.typeshare # Command Line Tool for generating language files with typeshare
          pkgs.upx # The Ultimate Packer for eXecutables
          pkgs.zig # General-purpose programming language and toolchain for maintaining robust, optimal, and reusable software
          # Runtimes
          pkgs.bun # Incredibly fast JavaScript runtime, bundler, transpiler and package manager – all in one
          pkgs.go # The Go Programming language
          # Containers
          pkgs.devbox # Instant, easy, predictable shells and containers
          pkgs.dive # A tool for exploring each layer in a docker image
          pkgs.docker # NVIDIA Container Toolkit
          pkgs.docker-compose # Multi-container orchestration for Docker
          pkgs.k3d # A helper to run k3s (Lightweight Kubernetes. 5 less than k8s) in a docker container
          pkgs.k9s # Kubernetes CLI To Manage Your Clusters In Style
          pkgs.kubectl # Production-Grade Container Scheduling and Management
          pkgs.kubectl-cnpg # Plugin for kubectl to manage a CloudNativePG cluster in Kubernetes
          pkgs.kubectx # Fast way to switch between clusters and namespaces in kubectl!
          pkgs.kubent # Easily check your cluster for use of deprecated APIs
          pkgs.kubernetes-helm # Package manager for kubernetes
          pkgs.skaffold # Easy and Repeatable Kubernetes Development
          pkgs.entr # Run arbitrary commands when files change
          pkgs.tilt # A multi-service development environment for teams on Kubernetes
          pkgs.lazydocker # A simple terminal UI for both docker and docker-compose
          # Databases
          pkgs.postgresql_17
          # Helpers
          pkgs.age # Modern encryption tool with small explicit keys
          pkgs.ast-grep # A tool to search for AST nodes in source code
          pkgs.certstrap # Tools to bootstrap CAs, certificate requests, and signed certificates
          # pkgs.direnv # Managed by programs.direnv
          pkgs.fx # Terminal JSON viewer
          pkgs.glow # Render markdown on the CLI, with pizzazz!
          pkgs.gomplate # A flexible commandline tool for template rendering
          pkgs.graphviz # Graph visualization tools
          pkgs.hexyl # A command-line hex viewer
          pkgs.jwt-cli # Super fast CLI tool to decode and encode JWTs
          pkgs.lnav # The Logfile Navigator
          pkgs.picotool # Tool for interacting with RP-series device(s) in BOOTSEL mode, or with an RP-series binary
          pkgs.scrcpy # Display and control Android devices over USB or TCP/IP
          pkgs.unstable.biome # Toolchain of the web
          # Database
          pkgs.dbmate # Database migration tool
          pkgs.rainfrog # Database management TUI for postgres
          pkgs.sea-orm-cli #  Command line utility for SeaORM
          # GitHub
          pkgs.act # Run your GitHub Actions locally
          # pkgs.gh # Managed by programs.gh
          pkgs.serie # Rich git commit graph in your terminal, like magic
          # Networking / Monitoring / Benchmarking
          pkgs.atac # Simple API client (postman like) in your terminal
          # pkgs.btop # Managed by programs.btop
          pkgs.frp # A fast reverse proxy to help you expose a local server behind a NAT or firewall to the internet
          pkgs.glances # Cross-platform curses-based monitoring tool
          pkgs.httpstat # curl statistics made simple
          pkgs.hyperfine # Command-line benchmarking tool
          pkgs.wrk # A HTTP benchmarking tool
          pkgs.inetutils # Collection of common network programs
          pkgs.ipcalc # Simple IP network calculator
          pkgs.plow # A high-performance HTTP benchmarking tool that includes a real-time web UI and terminal display
          pkgs.ngrok # A Python wrapper for ngrok
          pkgs.nmap # A free and open source utility for network discovery and security auditing
          # pkgs.s-tui # Stress-Terminal UI monitoring tool - disabled because marked as broken
          pkgs.smartmontools # Tools for monitoring the health of hard drives
          pkgs.speedtest-cli # Command line interface for testing internet bandwidth using speedtest.net
          pkgs.subfinder # Subdomain discovery tool
          pkgs.trippy # A network diagnostic tool
          pkgs.trivy # A simple and comprehensive vulnerability scanner for containers, suitable for CI
          # Cloud
          pkgs.awscli2 # Unified tool to manage your AWS services
          pkgs.google-cloud-sdk # Tools for the google cloud platform
          # pkgs.nodePackages_latest.aws-cdk # CDK Toolkit, the command line tool for CDK apps
          pkgs.terraform # OpenTofu, Terraform, Terragrunt and Atmos version manager written in Go
          # Media
          pkgs.cairo # A 2D graphics library with support for multiple output devices
          pkgs.ffmpeg # A complete, cross-platform solution to record, convert and stream audio and video (Jellyfin fork)
          pkgs.graphicsmagick # Swiss army knife of image processing
          pkgs.imagemagick # A software suite to create, edit, compose, or convert bitmap images
          pkgs.libavif # C implementation of the AV1 Image File Format
          pkgs.yt-dlp # Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
          pkgs.psutils # Collection of useful utilities for manipulating PS documents
          # Nix
          pkgs.nixos-anywhere # NixOS installer for any Linux distribution
          # Docs
          pkgs.tui-journal # A terminal-based journal application
          pkgs.wikiman # Offline search engine for manual pages
          pkgs.tealdeer # A very fast implementation of tldr in Rust
          # Yubikey
          # pkgs.yubikey-manager # Command line tool for configuring any YubiKey over all USB transports
          # pkgs.yubikey-personalization # A library and command line tool to personalize YubiKeys
        ]
        ++ lib.optional config.home.modules.personal [
          pkgs.stripe-cli # A command-line tool for Stripe
          pkgs.meilisearch # Powerful, fast, and an easy to use search engine
          pkgs.caddy # Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS
          pkgs.gcc-arm-embedded # GNU Arm Embedded Toolchain
          pkgs.master.mitmproxy # Man-in-the-middle proxy
        ]
        ++ lib.optional config.home.modules.work [
          pkgs.ssm-session-manager-plugin # AWS Systems Manager Session Manager plugin for the AWS CLI
          pkgs.aws-iam-authenticator # AWS IAM credentials for Kubernetes authentication
          pkgs.goreleaser # Deliver Go binaries as fast and easily as possible
          pkgs.lua51Packages.busted # Elegant Lua unit testing
          pkgs.lua51Packages.lua # Powerful, fast, lightweight, embeddable scripting language
          pkgs.lua51Packages.luacheck # A static analyzer and a linter for Lua
          pkgs.lua51Packages.luafilesystem # File System Library for the Lua Programming Language
          pkgs.lua51Packages.luarocks # A package manager for Lua
          pkgs.python312Packages.setuptools
          pkgs.python312Packages.setuptoolsBuildHook
          pkgs.python312Packages.distutils
        ]
        ++ lib.optional config.home.modules.hipster [
          # Hipster editors
          pkgs.emacs # The extensible, customizable GNU text editor
          pkgs.helix # A post-modern modal text editor
          # Misc
          # pkgs.cowsay # Cowsay reborn, written in Go
          # pkgs.irssi # Terminal based IRC client
          # pkgs.mutagen # Make remote development work with your local tools
          # pkgs.mutagen-compose # Compose with Mutagen integration
          # pkgs.pv # A Wave-to-Notes transcriber
          # Sort these
          # pkgs.cfssl # Cloudflare's PKI and TLS toolkit
          # pkgs.httpie # A command line HTTP client whose goal is to make CLI human-friendly
          # pkgs.nats-server # High-Performance server for NATS
          # pkgs.natscli # NATS Command Line Interface
          # pkgs.neovim # Vim text editor fork focused on extensibility and agility
          # pkgs.redis # An open source, advanced key-value store
          # pkgs.bitwarden-cli # A secure and free password manager for all of your devices
          # pkgs.vector # A high-performance observability data pipeline
          # pkgs.watchman # Watches files and takes action when they change
        ]
        ++ lib.optional config.home.modules.modelling [
          pkgs.uv # Python package installer
        ]
      );
    };
  };
}
