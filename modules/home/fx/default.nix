{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.home.modules.ai && pkgs.stdenv.hostPlatform.isDarwin) {
    home.file = {
      ".fx/AGENTS.md".source = ../config/ai/AGENTS.md;
      ".fx/commands".source = ../config/ai/commands;
      ".fx/mcp.json".source = ../config/fx/mcp.json;
      ".fx/themes/catppuccin-mocha.json".source = ../config/fx/catppuccin-mocha.json;
    };

    # Keep settings.json writable for fx's saved models, permissions, and
    # workspace preferences. These supported process overrides stay declarative.
    home.sessionVariables = {
      FX_THEME = "catppuccin-mocha";
    };
  };
}
