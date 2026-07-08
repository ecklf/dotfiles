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
    movie = true;
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
    extraBrews = [
      "datadog-labs/pack/pup"
    ];
    extraApps = {
      "Okta Verify" = 490179405;
      "NordLayer" = 1488888843;
    };
  };

  activationScriptModules.extraPreActivationScripts = [];

  services = {};
}
