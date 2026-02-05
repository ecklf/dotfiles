{pkgs, ...}: {
  programs.starship = {
    package = pkgs.master.starship;
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      command_timeout = 1500;
      scan_timeout = 10;

      character = {
        success_symbol = "▲";
        error_symbol = "[▲](bold red)";
      };

      directory = {
        truncation_length = 5;
        truncation_symbol = "…/";
        read_only = " 󰌾";
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
      };

      git_status = {
        disabled = false;
        style = "bold yellow";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        staged = "[++\${count}](green)";
      };

      nodejs = {
        disabled = false;
        symbol = " ";
      };

      rust = {
        disabled = false;
        symbol = " ";
      };

      golang = {
        disabled = false;
        symbol = "󰟓 ";
      };

      python = {
        disabled = false;
        symbol = " ";
      };

      lua = {
        disabled = false;
        symbol = " ";
      };

      nix_shell = {
        disabled = false;
        symbol = "󱄅 ";
        format = "[$symbol$state( \($name\))]($style) ";
      };

      package = {
        disabled = false;
        symbol = "󰏗 ";
      };

      swift = {
        disabled = false;
        symbol = " ";
      };

      zig = {
        disabled = false;
        symbol = " ";
      };

      terraform = {
        disabled = false;
        symbol = "󱁢 ";
      };

      helm = {
        disabled = false;
        symbol = "󰠳 ";
      };

      buf = {
        disabled = false;
        symbol = " ";
      };

      bun = {
        disabled = false;
        symbol = " ";
      };

      deno = {
        disabled = false;
        symbol = " ";
      };

      cmd_duration = {
        min_time = 2000;
        format = "took [$duration](bold yellow)";
      };

      # disabled
      memory_usage = {
        disabled = true;
        symbol = "󰍛 ";
      };

      os = {
        disabled = true;
        symbols = {
          Macos = " ";
          Linux = " ";
          NixOS = " ";
          Ubuntu = " ";
          Debian = " ";
          Fedora = " ";
          Arch = " ";
          Windows = " ";
        };
      };

      docker_context = {
        disabled = true;
        symbol = " ";
      };

      gcloud = {
        disabled = true;
        symbol = "󱇶 ";
      };

      aws = {
        disabled = true;
        symbol = " ";
      };

      kubernetes = {
        disabled = true;
        symbol = "󱃾 ";
        format = "[$symbol$context( \($namespace\))]($style) ";
      };
    };
  };
}
