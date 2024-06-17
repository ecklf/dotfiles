({ config, profile, lib, pkgs, nixpkgs-master, ... }: {
  home = {
    packages = [
      pkgs.aws-iam-authenticator
      pkgs.lua51Packages.busted
      pkgs.lua51Packages.lua
      pkgs.lua51Packages.luacheck
      pkgs.lua51Packages.luafilesystem
      pkgs.lua51Packages.luarocks
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
