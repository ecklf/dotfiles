({ config, lib, pkgs, ... }: {
  home = {
    packages = [
      /* pkgs.ansible */
      pkgs.meilisearch
    ];
  };
})
