{...}: {
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "Default";
      theme_background = false;
      truecolor = true;
      force_tty = false;
      vim_keys = true;
      rounded_corners = true;
      graph_symbol = "braille";
      shown_boxes = "cpu mem net proc";
      update_ms = 1000;
      proc_sorting = "cpu lazy";
      proc_reversed = false;
      proc_tree = false;
      proc_colors = true;
      proc_gradient = true;
      proc_per_core = true;
      proc_mem_bytes = true;
      proc_cpu_graphs = true;
      cpu_graph_upper = "total";
      cpu_graph_lower = "total";
      show_uptime = true;
      check_temp = true;
      mem_graphs = true;
      mem_below_net = false;
      zfs_arc_cached = true;
      show_swap = true;
      swap_disk = true;
      show_disks = true;
      only_physical = true;
      use_fstab = true;
      zfs_hide_datasets = false;
      disk_free_priv = false;
      show_io_stat = true;
      io_mode = false;
      io_graph_combined = false;
      net_download = 100;
      net_upload = 100;
      net_auto = true;
      net_sync = true;
      net_iface = "";
      show_battery = true;
      log_level = "WARNING";
    };
  };
}
