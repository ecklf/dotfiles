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
    photography = true;
    movie = false;
    music = false;
    latex = false;
    downloader = false;
    tax = false;
    language = true;
    wine = false;
    game = true;
    modelling = true;
    ai = true;
    embedded = true;
    extraBrews = ["pup"];
    extraApps = {
      "Okta Verify" = 490179405;
    };
  };

  activationScriptModules.extraPreActivationScripts = [];

  services = {};
}
