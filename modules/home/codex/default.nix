{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.home.modules.ai && pkgs.stdenv.hostPlatform.isDarwin) {
    home.file = {
      ".codex/AGENTS.md".source = ../config/ai/AGENTS.md;
      ".codex/commands".source = ../config/ai/commands;
    };

    # Codex persists project trust and preferences in this file. Seed it only
    # after Home Manager has removed the previously managed read-only symlink.
    home.activation.seedCodexConfig = lib.hm.dag.entryAfter ["linkGeneration"] ''
      if [ ! -e "$HOME/.codex/config.toml" ]; then
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -Dm600 \
          ${../config/codex/config.toml} "$HOME/.codex/config.toml"
      fi
    '';
  };
}
