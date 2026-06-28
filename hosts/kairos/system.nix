{modulesPath, username, ...}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  boot.loader.grub.device = "/dev/vda";
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi"];
  boot.initrd.kernelModules = ["nvme"];
  fileSystems."/" = {
    device = "/dev/vda2";
    fsType = "ext4";
  };
  swapDevices = [{device = "/dev/vda3";}];

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      features = {
        buildkit = true;
      };
    };
  };

  users.users."${username}".extraGroups = ["docker"];

  system.stateVersion = "24.05";
}
