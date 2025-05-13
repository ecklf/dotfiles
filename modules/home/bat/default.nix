({pkgs, ...}: {
  programs = {
    bat = {
      enable = true;
      config.theme = "TwoDark";
      extraPackages = with pkgs.bat-extras; [batdiff batman batgrep batwatch];
      # extraOptions = [
      #   "--style=plain"
      #   "--color=always"
      #   "--decorations=always"
      #   "--paging=always"
      #   "--theme=TwoDark"
      #   "--terminal-width=80"
      # ];
    };
  };
})
