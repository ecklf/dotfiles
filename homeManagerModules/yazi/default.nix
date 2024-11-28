(_: {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    keymap = {
      manager.prepend_keymap = [
        {
          on = "<C-p>";
          # This breaks for video files
          # Have to figure out a way to preview videos differently
          # run = "shell 'qlmanage -p \"$@\"' --confirm";
          run = "shell 'if [[ \"$@\" =~ \.(jpg|jpeg|png|gif|pdf)$ ]]; then qlmanage -p \"$@\"; fi' --confirm";
        }
      ];
    };

    settings = {
      manager = {
        layout = [
          1
          4
          3
        ];
        sort_by = "natural";
        sort_sensitive = true;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "none";
        show_hidden = true;
        show_symlink = true;
      };
      # preview = {
      #   image_filter = "lanczos3";
      #   image_quality = 90;
      #   tab_size = 1;
      #   max_width = 600;
      #   max_height = 900;
      #   cache_dir = "";
      #   ueberzug_scale = 1;
      #   ueberzug_offset = [
      #     0
      #     0
      #     0
      #     0
      #   ];
      # };
      # tasks = {
      #   micro_workers = 5;
      #   macro_workers = 10;
      #   bizarre_retry = 5;
      # };
    };
  };
})
