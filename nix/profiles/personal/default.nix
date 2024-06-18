({ config, lib, pkgs, nixpkgs-master, ... }: {
  home = {
    packages = [
      /* pkgs.ansible */
      pkgs.meilisearch
    ];
  };
})
