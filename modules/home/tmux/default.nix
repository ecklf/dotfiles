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

      # Auto-rename windows based on current directory
      set -g automatic-rename on
      set -g automatic-rename-format '#{b:pane_current_path}'

      # Split panes in current pane's directory
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

      # Resize panes with vim keys
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Quick pane switching (prefix + hjkl)
      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R

      # Pane navigation with Ctrl+hjkl is handled by vim-tmux-navigator plugin
      # which detects vim/nvim and passes keys through when needed

      # Window navigation with Alt+[ and Alt+]
      bind -n M-[ previous-window
      bind -n M-] next-window

      # Pane resizing with Ctrl+Shift+HJKL (no prefix needed)
      bind -n C-S-h resize-pane -L 5
      bind -n C-S-j resize-pane -D 5
      bind -n C-S-k resize-pane -U 5
      bind -n C-S-l resize-pane -R 5

      # Create new window in current path
      bind c new-window -c "#{pane_current_path}"

      # Development layout: nvim (60% width, 85% height) | opencode (40% width, 85% height) / terminal (15% height, 100% width)
      bind D new-window -c "#{pane_current_path}" \; \
        split-window -v -p 15 -c "#{pane_current_path}" \; \
        select-pane -t 1 \; \
        split-window -h -p 40 -c "#{pane_current_path}" \; \
        send-keys -t 1 'nvim' Enter \; \
        send-keys -t 2 'opencode --port' Enter \; \
        select-pane -t 1

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
      set -g status-left '#[fg=#ffffff,bg=#14171d,bold]  #S #[fg=#14171d,bg=default]'

      # Right: indicators + git branch + host + time
      # Prefix indicator: shows [CMD] when prefix is active
      # Zoom indicator: shows [ZOOM] when pane is zoomed
      # Git branch: current branch in pane's directory
      # Host: shows hostname in badge
      set -g status-right '#{?client_prefix,#[fg=#14171d]#[bg=#bf7fff]#[bold] CMD ,}#{?window_zoomed_flag,#[fg=#14171d]#[bg=#8a9a7b]#[bold] ZOOM ,}#[fg=#c5c9c7]#[bg=#24262D]#[bold] #H #[bg=default]#[nobold] #[fg=#a0a0a0]%Y-%m-%d #[fg=#a0a0a0]%H:%M '

      # Window styling
      set -g window-status-separator ""
      setw -g window-status-format '#[fg=#a4a7a4,bg=#14171d] #I #W '
      setw -g window-status-current-format '#[fg=#14171d,bg=#bf7fff,bold] #I #W #[fg=#bf7fff,bg=#14171d]'

      # Pane borders - using kanso colors
      set -g pane-border-style 'fg=#24262D'
      set -g pane-active-border-style 'fg=#5c5c5c'

      # Message styling
      set -g message-style 'fg=#c5c9c7 bg=#24262D bold'
      set -g message-command-style 'fg=#c5c9c7 bg=#24262D'

      # Mode styling (copy mode, etc.)
      setw -g mode-style 'fg=#c5c9c7 bg=#24262D bold'

      # Clock mode
      setw -g clock-mode-colour '#ffffff'

      # Activity monitoring
      setw -g monitor-activity on
      set -g visual-activity off
    '';
  };
}
