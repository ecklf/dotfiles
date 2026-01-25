{
  lib,
  config,
  pkgs,
  username,
  ...
}: let
  cfg = config.homelab.vnc;

  # Create a wrapper script that starts Xvnc directly
  #
  # NOTE: On first login, LXQt will prompt to select a window manager.
  # Select: /run/current-system/sw/bin/openbox
  #
  # Default VNC password is "clawdbot". Change it after first login with:
  #   vncpasswd
  #
  vncStartScript = pkgs.writeShellScript "vnc-start" ''
    export HOME="/home/${username}"
    export DISPLAY=:${toString cfg.display}
    export XDG_SESSION_TYPE=x11
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"

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

    # Start dbus session
    eval $(${pkgs.dbus}/bin/dbus-launch --sh-syntax)
    export DBUS_SESSION_BUS_ADDRESS

    # Start LXQt session (uses the NixOS-configured session)
    exec ${pkgs.lxqt.lxqt-session}/bin/startlxqt
  '';
in {
  options.homelab.vnc = {
    enable = lib.mkEnableOption "Lightweight LXQt desktop with VNC access";
    port = lib.mkOption {
      type = lib.types.int;
      default = 5900;
      description = "VNC server port";
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
    # Use NixOS's built-in LXQt + Openbox support
    services.xserver = {
      enable = true;
      desktopManager.lxqt.enable = true;
      windowManager.openbox.enable = true;
    };

    # systemd service for VNC
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

    # Additional packages for clawdbot computer-use
    environment.systemPackages = with pkgs; [
      tigervnc
      lxqt.lxqt-qtplugin
      lxqt.obconf-qt # Openbox configuration tool

      # Basic desktop apps for clawdbot computer-use
      firefox
      xterm
      xclip
      scrot
      xdotool
    ];

    # Firewall - open VNC port
    networking.firewall.allowedTCPPorts = [cfg.port];

    # Enable dbus for desktop apps
    services.dbus.enable = true;

    # PipeWire for audio
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };

    # Polkit for desktop privilege escalation
    security.polkit.enable = true;

    # Fonts
    fonts.packages = with pkgs; [
      dejavu_fonts
      noto-fonts
      liberation_ttf
    ];
  };
}
