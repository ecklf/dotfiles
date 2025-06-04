({...}: let
  isWorkMachine = false;
in {
  homebrewModules = {
    affinity = true;
    developer = true;
    messenger = true;
    monitor = true;
    personal = !isWorkMachine;
    work = isWorkMachine;
    disk = true;
    photography = true;
    movie = true;
    music = true;
    latex = true;
    downloader = true;
    tax = true;
    language = true;
    wine = false;
    game = false;
    extraCasks = ["chromium" "gog-galaxy" "steam"];
  };
})
