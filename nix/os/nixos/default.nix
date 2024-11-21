({ config, username, hostname, lib, pkgs, timezone, ... }: {
  networking.hostName = "${hostname}";
  time.timeZone = "${timezone}";
  # Post install: set a new password with ‘passwd’.
  # Enable ‘sudo’ for the user.
  users.users."${username}" = {
    isNormalUser = true;
    initialPassword = "init123";
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      firefox
      tree
    ];
  };
})
