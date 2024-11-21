({ config, username, hostname, lib, pkgs, ... }: {
  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.
  networking.wireless.networks = {
    "placeholderssid".psk = "placeholderpassword";
  };
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  users.users."${username}" = {
    isNormalUser = true;
    initialPassword = "init123"; # Post install: set a new password with ‘passwd’.
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
      tree
    ];
  };
})
