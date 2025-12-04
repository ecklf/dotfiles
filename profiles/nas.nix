({pkgs, ...}: {
  homeManagerModules = {
    extraPackages = [
      pkgs.zfs # ZFS Filesystem Linux Userspace Tools
      pkgs.dive # A tool for exploring each layer in a docker image
      pkgs.docker # NVIDIA Container Toolkit
      pkgs.docker-compose # Multi-container orchestration for Docker
      pkgs.lazydocker # A simple terminal UI for both docker and docker-compose
      pkgs.iperf3 # Iperf3 client and server wrapper for dynamic server ports
    ];
  };
})
