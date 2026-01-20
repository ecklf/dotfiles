{...}: let
  isWorkMachine = true;
in {
  homebrewModules = {
    affinity = true;
    developer = true;
    messenger = true;
    monitor = true;
    personal = !isWorkMachine;
    work = isWorkMachine;
    disk = false;
    photography = false;
    movie = false;
    music = false;
    latex = false;
    downloader = false;
    tax = false;
    language = true;
    wine = false;
    game = true;
    modelling = true;
    extraBrews = ["bintrim"];
  };

  activationScriptModules.extraPreActivationScripts = [];

  services = {};
}
