({pkgs, ...}: {
  homebrewModules = {
    personal = false;
    work = true;
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
  services = {};
})
