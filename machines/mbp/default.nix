(_: let
  isWorkMachine = false;
in {
  homebrewModules = {
    enable = false;
  };

  activationScriptModules.extraPreActivationScripts = [];

  services = {};
})
