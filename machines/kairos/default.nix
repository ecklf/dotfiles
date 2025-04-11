{
  pkgs,
  username,
  hostname,
  timezone,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  time.timeZone = timezone;
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = false;
  networking.hostName = hostname;
  networking.domain = "";
  services.openssh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+ZSLLubx/+U947o2n0mc3zm3A2ezAkCsCYKIcg3RQs ecklf@icloud.com''];
  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel" "kvm" "libvirtd" "docker"];
    openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+ZSLLubx/+U947o2n0mc3zm3A2ezAkCsCYKIcg3RQs ecklf@icloud.com''];
  };

  environment.systemPackages = with pkgs; [
    busybox
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      dates = "weekly";
      enable = true;
    };
  };
  virtualisation.oci-containers.backend = "docker";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443 4000 4001 7000 7700 7701];
    # allowedUDPPortRanges = [
    #   { from = 4000; to = 4007; }
    #   { from = 8000; to = 8010; }
    # ];
  };

  system.stateVersion = "25.05";
}
