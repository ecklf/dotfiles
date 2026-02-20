{...}: {
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    config = {
      global = {
        load_dotenv = true;
        strict_env = false;
        warn_timeout = "5s";
      };
      whitelist = {
        prefix = [
          "~/code"
          "~/projects"
          "~/work"
        ];
        exact = [
          "~/.envrc"
        ];
      };
    };
  };
}
