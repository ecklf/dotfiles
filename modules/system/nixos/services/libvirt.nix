{
  lib,
  config,
  pkgs,
  username,
  ...
}: {
  options.homelab.libvirt = {
    enable = lib.mkEnableOption "libvirt/QEMU virtualization for VMs";
    vncPort = lib.mkOption {
      type = lib.types.int;
      default = 5900;
      description = "Base VNC port (VM display :0 will be on this port)";
    };
  };

  config = lib.mkIf config.homelab.libvirt.enable {
    # Enable virtualization
    # https://wiki.nixos.org/wiki/Libvirt
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true; # TPM emulation (useful for Windows 11, optional for Ubuntu)
      };
    };

    # Enable USB redirection (optional, useful for passing USB devices to VMs)
    virtualisation.spiceUSBRedirection.enable = true;

    # Add user to libvirtd group
    users.users."${username}".extraGroups = ["libvirtd" "kvm"];

    # Packages for VM management
    environment.systemPackages = with pkgs; [
      virt-manager # GUI management (can be used over SSH X11 forwarding)
      virt-viewer # For SPICE/VNC connections
      libvirt # virsh CLI
      qemu_kvm
      dnsmasq # Required for default NAT network
      swtpm # TPM emulation
    ];

    # Enable nested virtualization (optional, useful if you want VMs inside VMs)
    boot.extraModprobeConfig = ''
      options kvm_intel nested=1
    '';

    # Trust the libvirt bridge interface
    networking.firewall.trustedInterfaces = ["virbr0"];

    # Firewall rules for VNC access
    networking.firewall.allowedTCPPorts = [
      config.homelab.libvirt.vncPort # VNC :0
      (config.homelab.libvirt.vncPort + 1) # VNC :1 (in case of multiple VMs)
      (config.homelab.libvirt.vncPort + 2) # VNC :2
    ];

    # Enable default network (NAT)
    # The VM will have internet access and can be accessed from host
    systemd.services.libvirt-default-network = {
      description = "Enable libvirt default network";
      after = ["libvirtd.service"];
      requires = ["libvirtd.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.libvirt}/bin/virsh net-start default 2>/dev/null || true
        ${pkgs.libvirt}/bin/virsh net-autostart default 2>/dev/null || true
      '';
    };
  };
}
