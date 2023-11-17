({ pkgs, username, hostname, ... }: {
  imports = [
    ./system.nix
    ./homebrew.nix
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
})
