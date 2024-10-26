({ config, lib, pkgs, ... }: {
  home = {
    packages = [
      pkgs.meilisearch
      pkgs.master.stripe-cli
    ];
  };
})
