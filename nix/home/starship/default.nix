_: {
  programs = {
    starship = {
      enable = true;
      enableZshIntegration = true;
      # SPACESHIP_VI_MODE_SHOW=false
      # SPACESHIP_PACKAGE_PREFIX="\n"
      # SPACESHIP_GIT_PREFIX="\n"
      # SPACESHIP_NODE_PREFIX="\n"
      # SPACESHIP_PACKAGE_SHOW=true
      # SPACESHIP_CHAR_COLOR_SUCCESS="green"
      # SPACESHIP_CHAR_COLOR_SUCCESS="white"
      settings = {
        add_newline = false;
        gcloud = {
          disabled = true;
        };
        docker_context = {
          disabled = true;
        };
        # format = lib.concatStrings [
        #   "$line_break"
        #   "$package"
        #   "$line_break"
        #   "$character"
        # ];
        command_timeout = 1500;
        scan_timeout = 10;
        character = {
          success_symbol = "▲";
          error_symbol = "▲";
        };
      };
    };
  };
}
