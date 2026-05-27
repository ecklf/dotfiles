{pkgs, ...}: let
  isDarwin = pkgs.stdenv.isDarwin;
in {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraConfig =
      if isDarwin
      then ''
        IgnoreUnknown AddKeysToAgent,UseKeychain
      ''
      else "";
    includes = [
      "~/.orbstack/ssh/config"
      "~/.colima/ssh_config"
    ];
    settings = {
      "*" = {
        ForwardAgent = "no"; # Don't forward SSH agent to remote hosts by default
        Compression = "yes"; # Enable compression for slower connections
        ServerAliveInterval = 60; # Send keep-alive every 60 seconds to prevent timeouts
        ServerAliveCountMax = 3; # Max number of keep-alive messages before disconnecting
        HashKnownHosts = "yes"; # Hash hostnames for privacy (recommended)
        UserKnownHostsFile = "~/.ssh/known_hosts"; # File location for storing known host keys
        ControlMaster = "auto"; # Enable connection multiplexing automatically
        ControlPath = "~/.ssh/master-%r@%h:%p"; # Socket path for shared connections
        ControlPersist = "10m"; # Keep shared connections alive for 10 minutes
        SetEnv = {TERM = "xterm-256color";}; # Set terminal type for better compatibility
      };
      "github.com" =
        {
          AddKeysToAgent = "yes";
          IdentityFile = "~/.ssh/id_ed25519";
        }
        // (
          if isDarwin
          then {UseKeychain = "yes";}
          else {}
        );
    };
  };
}
