{
  config,
  username,
  ...
}: {
  # Use the host's Headscale-enrolled tailscaled for identity and encryption.
  # No Tailscale Serve/ts.net certificates or separate Rex enrollment needed.
  services.rex.loginServer = {
    enable = true;
    extraListen = ["tailnet://:7297"];
    accounts.${username}.principals = ["tailscale:ecklf"];
    defaults."tailscale:ecklf" = username;
  };

  # Never expose Rex on the public WAN or ordinary LAN interface.
  networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [7297];
}
