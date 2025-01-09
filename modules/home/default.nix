({
  system,
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
      stateVersion = "24.05";
      sessionVariables =
        {
          PAGER = "less";
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
          ".config/iterm2/com.googlecode.iterm2.plist".source = ./config/iterm2/com.googlecode.iterm2.plist;
          ".config/iterm2/nordic_light.itermcolors".source = ./config/iterm2/nordic_light.itermcolors;
          ".config/iterm2/nordic_dark.itermcolors".source = ./config/iterm2/nordic_dark.itermcolors;
        };

      packages = lib.flatten (
        config.homeManagerModules.extraPackages
        ++ lib.optional isDarwin [
          pkgs.gnupg # Modern release of the GNU Privacy Guard, a GPL OpenPGP implementation
          pkgs.gnused # GNU sed, a batch stream editor
          pkgs.gnutls # The GNU Transport Layer Security Library
          pkgs.gawk # GNU implementation of the Awk programming language
          # pkgs.lima # Linux virtual machines (on macOS, in most cases)
          # pkgs.mitmproxy # Man-in-the-middle proxy
          # pkgs.darwin.libiconv # required for -liconv mitmproxy compilation
        ]
        ++ lib.optional (config.homeManagerModules.minimal && lib.optional system == "aarch64-darwin") [
          # Fails to compile on x86_64
          pkgs.fclones # Efficient Duplicate File Finder and Remover
        ]
        ++ lib.optional config.homeManagerModules.minimal [
          # pkgs.nixpkgs-fmt # Nix code formatter for nixpkgs
          pkgs.ack # A grep-like tool tailored to working with large trees of source code
          pkgs.alejandra # Nix code formatter
          pkgs.curl # A command line tool for transferring files with URL syntax
          pkgs.direnv # A shell extension that manages your environment
          pkgs.eza # A modern, maintained replacement for ls
          pkgs.fd # Suite of speech signal processing tools
          pkgs.fnm # Fast and simple Node.js version manager
          pkgs.fzf # Fuzzy finder for your shell
          pkgs.git # Distributed version control system
          pkgs.git-lfs # Git extension for versioning large files
          pkgs.git-trim # Automatically trims your branches whose tracking remote refs are merged or gone
          pkgs.gitui # Blazing fast terminal-ui for Git written in Rust
          pkgs.master.go-task # A task runner / simpler Make alternative written in Go
          pkgs.htop # An interactive process viewer for Linux, with vim-style keybindings
          pkgs.jq # A lightweight and flexible command-line JSON processor
          pkgs.lazygit # Simple terminal UI for git commands
          pkgs.less # A more advanced file pager than 'more'
          pkgs.neofetch # A fast, highly customizable system info script
          pkgs.nix-prefetch-github # Prefetch sources from github
          pkgs.parallel # Shell tool for executing jobs in parallel
          pkgs.pv # Tool for monitoring the progress of data through a pipeline
          pkgs.ripgrep # A utility that combines the usability of The Silver Searcher with the raw speed of grep
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
          pkgs.certstrap # Tools to bootstrap CAs, certificate requests, and signed certificates
          pkgs.direnv # A shell extension that manages your environment
          pkgs.fx # Terminal JSON viewer
          pkgs.glow # Render markdown on the CLI, with pizzazz!
          pkgs.gomplate # A flexible commandline tool for template rendering
          pkgs.graphviz # Graph visualization tools
          pkgs.hexyl # A command-line hex viewer
          pkgs.jwt-cli # Super fast CLI tool to decode and encode JWTs
          pkgs.lnav # The Logfile Navigator
          pkgs.scrcpy # Display and control Android devices over USB or TCP/IP
          # Database
          pkgs.dbmate # Database migration tool
          pkgs.sea-orm-cli #  Command line utility for SeaORM
          # GitHub
          pkgs.act # Run your GitHub Actions locally
          pkgs.gh # GitHub CLI tool
          # Monitoring, Network and Benchmarking
          pkgs.btop # A monitor of resources
          pkgs.frp # A fast reverse proxy to help you expose a local server behind a NAT or firewall to the internet
          pkgs.glances # Cross-platform curses-based monitoring tool
          pkgs.httpstat # curl statistics made simple
          pkgs.hyperfine # Command-line benchmarking tool
          pkgs.inetutils # Collection of common network programs
          pkgs.ipcalc # Simple IP network calculator
          pkgs.master.plow # A high-performance HTTP benchmarking tool that includes a real-time web UI and terminal display
          pkgs.ncdu # Disk usage analyzer with an ncurses interface
          pkgs.ngrok # A Python wrapper for ngrok
          pkgs.nmap # A free and open source utility for network discovery and security auditing
          pkgs.smartmontools # Tools for monitoring the health of hard drives
          pkgs.speedtest-cli # Command line interface for testing internet bandwidth using speedtest.net
          pkgs.subfinder # Subdomain discovery tool
          pkgs.trippy # A network diagnostic tool
          pkgs.trivy # A simple and comprehensive vulnerability scanner for containers, suitable for CI
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
        ]
        ++ lib.optional config.homeManagerModules.hipster [
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
          # pkgs.stable.bitwarden-cli # A secure and free password manager for all of your devices
          # pkgs.vector # A high-performance observability data pipeline
          # pkgs.watchman # Watches files and takes action when they change
        ]
      );
    };
  };
})
