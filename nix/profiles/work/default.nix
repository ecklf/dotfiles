({ config, profile, lib, pkgs, nixpkgs-master, ... }: {
  home = {
    packages = [
      pkgs.aws-iam-authenticator # AWS IAM credentials for Kubernetes authentication
      pkgs.goreleaser # Deliver Go binaries as fast and easily as possible
      pkgs.lua51Packages.busted # Elegant Lua unit testing
      pkgs.lua51Packages.lua # Powerful, fast, lightweight, embeddable scripting language
      pkgs.lua51Packages.luacheck # A static analyzer and a linter for Lua
      pkgs.lua51Packages.luafilesystem # File System Library for the Lua Programming Language
      pkgs.lua51Packages.luarocks # A package manager for Lua
      pkgs.master.go-task # A task runner / simpler Make alternative written in Go
    ];
  };

  programs = {
    zsh = {
      shellAliases = {
        dsf = "/Users/$(whoami)/Projects/vercel/deploy-single-file/bin/deploy-single-file";
      };
    };
  };
})
