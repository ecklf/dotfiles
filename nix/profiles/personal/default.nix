({ config, lib, pkgs, ... }: {
  home = {
    packages = [
      pkgs.meilisearch
      pkgs.stripe-cli
    ];
  };
})
