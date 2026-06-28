{
  modulesPath,
  hostname,
  pkgs,
  ...
}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  networking.hostName = hostname;
  networking.firewall.allowedTCPPorts = [80 443];

  services.postgresql.enable = true;
  services.redis.servers.nextcloud.enable = true;
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    https = false;
    hostName = hostname;
    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      adminpassFile = "/var/lib/nextcloud-admin-pass";
    };
    database.createLocally = true;
    configureRedis = true;
    settings = {
      trusted_domains = [hostname];
      default_phone_region = "US";
    };
  };

  boot.loader.grub.device = "/dev/vda";
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi"];
  boot.initrd.kernelModules = ["nvme"];
  fileSystems."/" = {
    device = "/dev/vda2";
    fsType = "ext4";
  };
  swapDevices = [{device = "/dev/vda3";}];
  system.stateVersion = "24.05";
}
