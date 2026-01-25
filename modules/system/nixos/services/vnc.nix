{
  lib,
  config,
  pkgs,
  username,
  ...
}: let
  cfg = config.homelab.vnc;

  # Define the PATH for all LXQt and X dependencies
  desktopPath = lib.makeBinPath (with pkgs; [
    coreutils
    dbus
    lxqt.lxqt-session
    lxqt.lxqt-panel
    lxqt.lxqt-runner
    lxqt.lxqt-config
    lxqt.lxqt-notificationd
    lxqt.lxqt-policykit
    lxqt.pcmanfm-qt
    lxqt.qterminal
    openbox
    xorg.xrdb
    xorg.xsetroot
    xorg.xinit
  ]);

  # xstartup script with full paths baked in
  xstartupScript = pkgs.writeShellScript "xstartup" ''
    #!/bin/sh
    export PATH="${desktopPath}:$PATH"
    export XDG_SESSION_TYPE=x11
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"

    unset SESSION_MANAGER
    unset DBUS_SESSION_BUS_ADDRESS

    # Start dbus session
    eval $(${pkgs.dbus}/bin/dbus-launch --sh-syntax)
    export DBUS_SESSION_BUS_ADDRESS

    # Set background color
    ${pkgs.xorg.xsetroot}/bin/xsetroot -solid "#2e3440"

    # Start LXQt session
    exec ${pkgs.lxqt.lxqt-session}/bin/startlxqt
  '';

  # Create a wrapper script that starts Xvnc directly (bypassing vncserver wrapper)
  vncStartScript = pkgs.writeShellScript "vnc-start" ''
    export HOME="/home/${username}"
    export PATH="${desktopPath}:$PATH"
    export DISPLAY=:${toString cfg.display}

    # Create VNC directory
    mkdir -p "$HOME/.vnc"

    # Create VNC password if it doesn't exist
    if [ ! -f "$HOME/.vnc/passwd" ]; then
      echo "clawdbot" | ${pkgs.tigervnc}/bin/vncpasswd -f > "$HOME/.vnc/passwd"
      chmod 600 "$HOME/.vnc/passwd"
    fi

    # Clean up any stale lock files
    rm -f /tmp/.X${toString cfg.display}-lock
    rm -f /tmp/.X11-unix/X${toString cfg.display}

    # Start Xvnc directly in background
    ${pkgs.tigervnc}/bin/Xvnc :${toString cfg.display} \
      -geometry ${cfg.resolution} \
      -depth 24 \
      -rfbport ${toString cfg.port} \
      -rfbauth "$HOME/.vnc/passwd" \
      -pn \
      -localhost=0 \
      -SecurityTypes VncAuth &

    XVNC_PID=$!

    # Wait for X server to be ready
    for i in $(seq 1 30); do
      if [ -e /tmp/.X11-unix/X${toString cfg.display} ]; then
        break
      fi
      sleep 0.1
    done

    # Run the xstartup script
    ${xstartupScript}

    # If xstartup exits, kill Xvnc
    kill $XVNC_PID 2>/dev/null
  '';
in {
  options.homelab.vnc = {
    enable = lib.mkEnableOption "Lightweight LXQt desktop with VNC access";
    port = lib.mkOption {
      type = lib.types.int;
      default = 5900;
      description = "VNC server port (display :0 = 5900, :1 = 5901, etc)";
    };
    display = lib.mkOption {
      type = lib.types.int;
      default = 1;
      description = "VNC display number (default :1 to avoid conflicts)";
    };
    resolution = lib.mkOption {
      type = lib.types.str;
      default = "1920x1080";
      description = "Virtual display resolution";
    };
  };

  config = lib.mkIf cfg.enable {
    # Single systemd service that runs VNC + desktop
    systemd.services.vnc-desktop = {
      description = "VNC Desktop (LXQt)";
      after = ["network.target" "dbus.service"];
      wants = ["dbus.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        User = username;
        Group = "users";
        WorkingDirectory = "/home/${username}";
        ExecStart = "${vncStartScript}";
        ExecStop = "${pkgs.coreutils}/bin/kill -TERM $MAINPID";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    # Packages for desktop use
    environment.systemPackages = with pkgs; [
      # VNC tools
      tigervnc

      # LXQt desktop and dependencies
      lxqt.lxqt-session
      lxqt.lxqt-panel
      lxqt.lxqt-runner
      lxqt.lxqt-config
      lxqt.lxqt-notificationd
      lxqt.lxqt-policykit
      lxqt.lxqt-qtplugin
      lxqt.pcmanfm-qt
      lxqt.qterminal

      # Window manager (LXQt uses openbox by default)
      openbox

      # X utilities
      xorg.xrdb
      xorg.xsetroot
      xorg.xinit

      # Basic desktop apps for clawdbot computer-use
      firefox
      xterm
      xclip # Clipboard support
      scrot # Screenshots
      xdotool # Mouse/keyboard automation

      # Fonts
      dejavu_fonts
      noto-fonts
      liberation_ttf
    ];

    # Firewall - open VNC port
    networking.firewall.allowedTCPPorts = [cfg.port];

    # Enable dbus for desktop apps
    services.dbus.enable = true;

    # PipeWire for audio (optional, for clawdbot voice features)
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };

    # Polkit for desktop privilege escalation
    security.polkit.enable = true;

    # Fonts configuration
    fonts.packages = with pkgs; [
      dejavu_fonts
      noto-fonts
      liberation_ttf
    ];
  };
}
