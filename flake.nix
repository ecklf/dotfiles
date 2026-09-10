{
  description = "NixOS and Darwin flakes";
  inputs = {
    # Darwin/macOS inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs";
    # NixOS inputs
    nixpkgs-nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-nixos-master.url = "github:nixos/nixpkgs";
    # Nix user repository
    nur.url = "github:nix-community/NUR";
    # Atomic secret provisioning for NixOS based on sops
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };
    # Nix modules for darwin aka macOS
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Manages configs links and home directory
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-master,
    nixpkgs-nixos,
    nixpkgs-nixos-master,
    nur,
    sops-nix,
    darwin,
    home-manager,
    disko,
    hermes-agent,
  }: let
    mkDarwin = import ./lib/mkdarwin.nix;
    mkNixOS = import ./lib/mknixos.nix;

    # Shared overlays for both Darwin and NixOS
    overlays = [
      (final: prev: {
        # OpenCode 2 beta (official native npm release)
        opencode2 = prev.stdenv.mkDerivation rec {
          pname = "opencode2";
          version = "0.0.0-beta-19271";
          src = let
            platform =
              if prev.stdenv.hostPlatform.isDarwin
              then "darwin"
              else "linux";
            arch =
              if prev.stdenv.hostPlatform.isAarch64
              then "arm64"
              else "x64";
            artifact = "${platform}-${arch}${prev.lib.optionalString prev.stdenv.hostPlatform.isx86_64 "-baseline"}";
            hashes = {
              "darwin-arm64" = "sha512-CHfMY/7pPq4Andvrif34tC/N9mFppSujjscVISVOSMc/twAvkIGGfDUZgU65qHDsifSnt6+IJr3NZ2AbPzWOfA==";
              "darwin-x64-baseline" = "sha512-lhxjdTMnly2zb88/yOQHJwaDgvKH8kyCrmHIBnOiYexYW394EGwmxHjHkQRWfrgXXRk9vqzKHw8ldx0ust0Msw==";
              "linux-arm64" = "sha512-0WIzqvdgTUwUaQK5cXibZauGbRW7NZcuXGrA8dMsRWmAyONKDCnI9LbSXigGwc1RkGeRJrLtP/Xwmc8UCeXoJA==";
              "linux-x64-baseline" = "sha512-o0rfUrWksGpmUw7lsN208wT79jb9oBeiMVVtYPNKqhCRvkPuSYOiDv8aYjX7OPW2xtcxUpz8eS78mjvGDjKw0g==";
            };
          in
            prev.fetchurl {
              url = "https://registry.npmjs.org/@opencode-ai/cli-${artifact}/-/cli-${artifact}-${version}.tgz";
              hash = hashes.${artifact};
            };
          sourceRoot = "package";
          nativeBuildInputs = prev.lib.optionals prev.stdenv.hostPlatform.isLinux [
            prev.autoPatchelfHook
          ];
          buildInputs = prev.lib.optionals prev.stdenv.hostPlatform.isLinux [
            prev.stdenv.cc.cc.lib
          ];
          installPhase = ''
            runHook preInstall
            install -Dm755 bin/opencode2 $out/bin/opencode2
            runHook postInstall
          '';
          # Preserve the upstream Developer ID signature on macOS.
          dontStrip = true;
          meta = with prev.lib; {
            description = "OpenCode 2.0 preview command line interface";
            homepage = "https://opencode.ai/v2/docs";
            license = licenses.mit;
            platforms = [
              "aarch64-darwin"
              "x86_64-darwin"
              "aarch64-linux"
              "x86_64-linux"
            ];
            mainProgram = "opencode2";
          };
        };
      })
      (final: prev: {
        # Disable nushell tests - SHLVL tests fail in Nix sandbox
        nushell = prev.nushell.overrideAttrs (old: {
          doCheck = false;
        });
        # tree-sitter CLI 0.26.1 (library stays at 0.25 for neovim compat)
        tree-sitter = prev.tree-sitter.overrideAttrs (old: rec {
          version = "0.26.1";
          src = prev.fetchFromGitHub {
            owner = "tree-sitter";
            repo = "tree-sitter";
            rev = "v${version}";
            hash = "sha256-k8X2qtxUne8C6znYAKeb4zoBf+vffmcJZQHUmBvsilA=";
          };
          cargoDeps = prev.rustPlatform.fetchCargoVendor {
            inherit src;
            hash = "sha256-hnFHYQ8xPNFqic1UYygiLBWu3n82IkTJuQvgcXcMdv0=";
          };
          patches = [];
        });
      })
    ];
    # NixOS-only overlays (tree-sitter 0.26.1 + requires bindgen/libclang)
    nixosOverlays =
      overlays
      ++ [
        (final: prev: {
          # Disable nushell tests - SHLVL tests fail in Nix sandbox
          nushell = prev.nushell.overrideAttrs (old: {
            doCheck = false;
          });
          # tree-sitter CLI 0.26.1 (library stays at 0.25 for neovim compat)
          tree-sitter = prev.tree-sitter.overrideAttrs (old: rec {
            version = "0.26.1";
            src = prev.fetchFromGitHub {
              owner = "tree-sitter";
              repo = "tree-sitter";
              rev = "v${version}";
              hash = "sha256-k8X2qtxUne8C6znYAKeb4zoBf+vffmcJZQHUmBvsilA=";
            };
            cargoDeps = prev.rustPlatform.fetchCargoVendor {
              inherit src;
              hash = "sha256-hnFHYQ8xPNFqic1UYygiLBWu3n82IkTJuQvgcXcMdv0=";
            };
            patches = [];
            # tree-sitter 0.26+ uses rquickjs-sys which requires libclang for bindgen
            nativeBuildInputs =
              (old.nativeBuildInputs or [])
              ++ [
                prev.libclang
              ];
            LIBCLANG_PATH = "${prev.libclang.lib}/lib";
            BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${prev.stdenv.cc.libc.dev}/include";
          });
        })
      ];
  in {
    nixosConfigurations = {
      soma = mkNixOS "soma" {
        inherit inputs nur sops-nix;
        overlays = nixosOverlays;
        nixpkgs = nixpkgs-nixos;
        nixpkgs-master = nixpkgs-nixos-master;
        system = "x86_64-linux";
        username = "soma";
        timezone = "Europe/Berlin";
        extraModules = [
          disko.nixosModules.disko
        ];
        extraHomeModules = [];
        homeStateVersion = "24.05";
      };
      skia = mkNixOS "skia" {
        inherit inputs nur sops-nix;
        overlays = nixosOverlays;
        nixpkgs = nixpkgs-nixos;
        nixpkgs-master = nixpkgs-nixos-master;
        system = "x86_64-linux";
        username = "skia";
        timezone = "Europe/Berlin";
        extraModules = [
          disko.nixosModules.disko
        ];
        extraHomeModules = [];
        homeStateVersion = "24.05";
      };
      kairos = mkNixOS "kairos" {
        inherit inputs nur sops-nix;
        overlays = nixosOverlays;
        nixpkgs = nixpkgs-nixos;
        nixpkgs-master = nixpkgs-nixos-master;
        system = "x86_64-linux";
        username = "kairos";
        timezone = "America/New_York";
        extraModules = [];
        extraHomeModules = [];
        homeStateVersion = "24.05";
      };
      snowflake = mkNixOS "snowflake" {
        inherit inputs nur sops-nix;
        overlays = nixosOverlays;
        nixpkgs = nixpkgs-nixos;
        nixpkgs-master = nixpkgs-nixos-master;
        system = "x86_64-linux";
        username = "ecklf";
        extraModules = [];
        extraHomeModules = [];
        homeStateVersion = "24.05";
      };
      yun = mkNixOS "yun" {
        inherit inputs nur sops-nix;
        overlays = nixosOverlays;
        nixpkgs = nixpkgs-nixos;
        nixpkgs-master = nixpkgs-nixos-master;
        system = "x86_64-linux";
        username = "nixos";
        extraModules = [
          hermes-agent.nixosModules.default
        ];
        extraHomeModules = [];
        homeStateVersion = "25.11";
      };
    };
    darwinConfigurations = {
      omega = mkDarwin "omega" {
        inherit inputs nixpkgs-master nur darwin home-manager overlays;
        system = "aarch64-darwin";
        username = "ecklf";
        patchBld = true;
        homeStateVersion = "24.05";
      };
      vercel = mkDarwin "vercel" {
        inherit inputs nixpkgs-master nur darwin home-manager overlays;
        system = "aarch64-darwin";
        username = "ecklf";
        homeStateVersion = "24.05";
      };
    };
  };
}
