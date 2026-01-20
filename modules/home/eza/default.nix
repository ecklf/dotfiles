{...}: {
  programs = {
    eza = {
      enable = true;
      enableZshIntegration = true;
      extraOptions = [
        "-G"
      ];
      icons = "auto";
      git = true;
    };
  };
}
