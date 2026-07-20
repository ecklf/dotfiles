{pkgs, ...}: {
  programs.java = {
    enable = true;
    package = pkgs.jdk21;
  };

  home.modules = {
    developer = true;
    personal = false;
    work = true;
    hipster = false;
    modelling = true;
    ai = true;
    embedded = true;
  };
}
