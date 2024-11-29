(_: let
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
    movie = true;
    music = true;
    latex = false;
    downloader = false;
    tax = false;
    language = false;
    wine = false;
    game = false;
  };

  activationScriptModules.extraPreActivationScripts = [];

  services = {};
})
