({pkgs, ...}: {
  homeManagerModules = {
    developer = false;
    personal = false;
    work = false;
    hipster = false;
    extraPackages = [
      pkgs.openssh
      pkgs.k3s
      pkgs.k9s
      pkgs.dive # A tool for exploring each layer in a docker image
      pkgs.docker # NVIDIA Container Toolkit
      pkgs.docker-compose # Multi-container orchestration for Docker
      pkgs.lazydocker # A simple terminal UI for both docker and docker-compose
    ];
  };
})
