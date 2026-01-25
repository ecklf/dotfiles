{
  lib,
  config,
  pkgs,
  username,
  ...
}: {
  options.homelab.vnc = {
    enable = lib.mkEnableOption "Lightweight LXQt desktop with VNC access";
    port = lib.mkOption {
      type = lib.types.int;
      default = 5900;
      description = "VNC server port (display :0 = 5900, :1 = 5901, etc)";
    };
    display = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "VNC display number";
    };
    resolution = lib.mkOption {
      type = lib.types.str;
      default = "1920x1080";
      description = "Virtual display resolution";
    };
  };

  config = lib.mkIf config.homelab.vnc.enable {
    # LXQt desktop environment - very lightweight (~200-300MB RAM)
    services.xserver = {
      enable = true;
      desktopManager.lxqt.enable = true;
    };

    # No display manager needed for headless VNC
    services.displayManager = {
      enable = false;
    };

    # TigerVNC server - creates a virtual X display accessible via VNC
    # This is ideal for headless servers
    systemd.services.tigervnc = {
      description = "TigerVNC Server - LXQt Desktop";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        User = username;
        WorkingDirectory = "/home/${username}";

        # Create .vnc directory and password file before starting
        ExecStartPre = let
          setupScript = pkgs.writeShellScript "vnc-setup" ''
            mkdir -p /home/${username}/.vnc
            # Create password file if it doesn't exist
            # Default password: clawdbot (change with vncpasswd after first login!)
            if [ ! -f /home/${username}/.vnc/passwd ]; then
              echo "clawdbot" | ${pkgs.tigervnc}/bin/vncpasswd -f > /home/${username}/.vnc/passwd
              chmod 600 /home/${username}/.vnc/passwd
            fi
          '';
        in "${setupScript}";

        ExecStart = let
          xstartup = pkgs.writeShellScript "xstartup" ''
            #!/bin/sh
            unset SESSION_MANAGER
            unset DBUS_SESSION_BUS_ADDRESS
            export XDG_SESSION_TYPE=x11
            exec startlxqt
          '';
        in ''
          ${pkgs.tigervnc}/bin/Xvnc :${toString config.homelab.vnc.display} \
            -geometry ${config.homelab.vnc.resolution} \
            -depth 24 \
            -rfbport ${toString config.homelab.vnc.port} \
            -rfbauth /home/${username}/.vnc/passwd \
            -desktop "yun-lxqt" \
            -alwaysshared \
            -dpi 96
        '';

        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    # Start LXQt session when VNC server is ready
    systemd.services.lxqt-session = {
      description = "LXQt Desktop Session";
      after = ["tigervnc.service"];
      requires = ["tigervnc.service"];
      wantedBy = ["multi-user.target"];

      environment = {
        DISPLAY = ":${toString config.homelab.vnc.display}";
        XDG_SESSION_TYPE = "x11";
      };

      serviceConfig = {
        Type = "simple";
        User = username;
        WorkingDirectory = "/home/${username}";
        ExecStart = "${pkgs.lxqt.lxqt-session}/bin/startlxqt";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    # Packages for desktop use
    environment.systemPackages = with pkgs; [
      # VNC tools
      tigervnc

      # Basic desktop apps for clawdbot computer-use
      firefox
      xterm
      xclip # Clipboard support
      scrot # Screenshots
      xdotool # Mouse/keyboard automation

      # File manager (comes with LXQt but explicit)
      lxqt.pcmanfm-qt

      # Fonts
      dejavu_fonts
      noto-fonts
      liberation_ttf
    ];

    # Firewall - open VNC port
    networking.firewall.allowedTCPPorts = [
      config.homelab.vnc.port
    ];

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
  };
}
