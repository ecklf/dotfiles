{ config, pkgs, lib, libs, ... }:
{
  programs.git = {
    enable = true;
    userName = "Florentin Eckl";
    userEmail = "ecklf@icloud.com";

    delta = {
      enable = true;
      options = {
        syntax-theme = "TwoDark";
        side-by-side = true;
      };
    };

    extraConfig = {
      github = {
        user = "ecklf";
      };
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = true;
      };
      push = {
        autoSetupRemote = true;
      };
      core = {
        editor = "nvim";
        fileMode = false;
        ignorecase = false;
      };
    };
  };
}
