({pkgs, ...}: {
  homeManagerModules = {
    developer = false;
    personal = false;
    work = false;
    hipster = false;
    extraPackages = [
      pkgs.keka
      pkgs.iina
      pkgs.raycast
      pkgs.iterm2
    ];
  };
})
