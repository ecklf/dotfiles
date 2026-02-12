{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 50000;
    escapeTime = 0;
    mouse = true;
    baseIndex = 1;
    keyMode = "vi";
    # prefix = "C-a";
    sensibleOnTop = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      }
      vim-tmux-navigator
    ];
    extraConfig = ''
      # True color support
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -as terminal-features ",xterm-256color:RGB"

      # Renumber windows when one is closed
      set -g renumber-windows on

      # Start panes at 1
      setw -g pane-base-index 1

      # Split panes with | and -
      # bind | split-window -h -c "#{pane_current_path}"
      # bind - split-window -v -c "#{pane_current_path}"
      # unbind '"'
      # unbind %

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

      # Resize panes with vim keys
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Quick pane switching
      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R

      # Create new window in current path
      bind c new-window -c "#{pane_current_path}"

      # Zoom pane toggle
      bind z resize-pane -Z

      # Kanso theme colors
      # bg: #090E13 (zen) / #14171d (ink)
      # fg: #c5c9c7
      # red: #c4746e, green: #8a9a7b, yellow: #c4b28a
      # blue: #8ba4b0, magenta: #a292a3, cyan: #8ea4a2
      # selection: #24262D

      # Status bar styling - bottom position
      set -g status-position bottom
      set -g status-style 'bg=#14171d fg=#c5c9c7'
      set -g status-justify left
      set -g status-left-length 100
      set -g status-right-length 100

      # Left: session name with icon
      set -g status-left '#[fg=#8ba4b0,bg=#14171d,bold]  #S #[fg=#14171d,bg=default]'

      # Right: indicators + git branch + host + time
      # Prefix indicator: shows [CMD] when prefix is active
      # Zoom indicator: shows [ZOOM] when pane is zoomed
      # Git branch: current branch in pane's directory
      # Host: shows hostname in badge
      set -g status-right '#{?client_prefix,#[fg=#14171d]#[bg=#a292a3]#[bold] CMD #[bg=default]#[fg=default]#[nobold] ,}#{?window_zoomed_flag,#[fg=#14171d]#[bg=#8a9a7b]#[bold] ZOOM #[bg=default]#[fg=default]#[nobold] ,}#[fg=#a292a3]#(cd "#{pane_current_path}" && git branch --show-current 2>/dev/null | sed "s/^/ /") #[fg=#c5c9c7]#[bg=#24262D]#[bold] #H #[bg=default]#[nobold] #[fg=#a4a7a4]%Y-%m-%d #[fg=#8ea4a2]%H:%M '

      # Window styling
      set -g window-status-separator ""
      setw -g window-status-format '#[fg=#a4a7a4,bg=#14171d] #I #W '
      setw -g window-status-current-format '#[fg=#c5c9c7,bg=#24262D,bold] #I #W #[fg=#24262D,bg=#14171d]'

      # Pane borders - using kanso colors
      set -g pane-border-style 'fg=#24262D'
      set -g pane-active-border-style 'fg=#8ba4b0'

      # Message styling
      set -g message-style 'fg=#c5c9c7 bg=#24262D bold'
      set -g message-command-style 'fg=#c5c9c7 bg=#24262D'

      # Mode styling (copy mode, etc.)
      setw -g mode-style 'fg=#c5c9c7 bg=#24262D bold'

      # Clock mode
      setw -g clock-mode-colour '#8ba4b0'

      # Activity monitoring
      setw -g monitor-activity on
      set -g visual-activity off
    '';
  };
}
