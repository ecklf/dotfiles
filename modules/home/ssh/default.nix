{...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [
      "~/.orbstack/ssh/config"
      "~/.colima/ssh_config"
    ];
    matchBlocks = {
      "*" = {
        forwardAgent = false; # Don't forward SSH agent to remote hosts by default
        compression = true; # Enable compression for slower connections
        serverAliveInterval = 60; # Send keep-alive every 60 seconds to prevent timeouts
        serverAliveCountMax = 3; # Max number of keep-alive messages before disconnecting
        hashKnownHosts = true; # Hash hostnames for privacy (recommended)
        userKnownHostsFile = "~/.ssh/known_hosts"; # File location for storing known host keys
        controlMaster = "auto"; # Enable connection multiplexing automatically
        controlPath = "~/.ssh/master-%r@%h:%p"; # Socket path for shared connections
        controlPersist = "10m"; # Keep shared connections alive for 10 minutes
        setEnv = {TERM = "xterm-256color";}; # Set terminal type for better compatibility
        # addKeysToAgent = "yes"; # Automatically add keys to SSH agent (commented - can be annoying)
        # identitiesOnly = true; # Only use explicitly configured keys (commented - can break some setups)
        # strictHostKeyChecking = "ask"; # Default behavior (commented - already default)
      };
      "github.com" = {
        extraOptions = {
          IgnoreUnknown = "AddKeysToAgent,UseKeychain";
          AddKeysToAgent = "yes";
          UseKeychain = "yes";
        };
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };
}
