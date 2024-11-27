({pkgs, ...}: {
  home = {
    packages = [
      pkgs.master.stripe-cli # A command-line tool for Stripe
      pkgs.meilisearch # Powerful, fast, and an easy to use search engine
    ];
  };
})
