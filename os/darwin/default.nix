({
  pkgs,
  username,
  hostname,
  casks,
  ...
}: {
  imports = [
    ./system
    ./homebrew/${casks}.nix
  ];

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  networking = {
    hostName = hostname;
    computerName = hostname;
    localHostName = hostname;
  };

  environment = {
    systemPath = ["/opt/homebrew/bin"];
    pathsToLink = ["/Applications"];
    shells = [pkgs.bash pkgs.zsh];
  };
})
