{
  config,
  lib,
  pkgs,
  ...
}: let
  commandNames = ["cx" "pr" "qanda" "review" "review-prs"];
  commandSource = name: ../config/ai/commands + "/${name}.md";
  skillText = name: let
    sections = lib.splitString "---\n" (builtins.readFile (commandSource name));
    description = lib.removePrefix "description: " (
      lib.findFirst (lib.hasPrefix "description: ") "" (lib.splitString "\n" (builtins.elemAt sections 1))
    );
  in ''
    ---
    name: ${name}
    description: ${description}
    ---

    Read and follow `~/.codex/commands/${name}.md`.
    Treat `$ARGUMENTS` as the text following this skill invocation in the user's message.
    Command examples using `/review-prs` correspond to `$review-prs` in Codex.
    Resolve references to `commands/pr.md` as `~/.codex/commands/pr.md`.
    ${lib.optionalString (builtins.elem name ["review" "qanda"]) "Review and discuss only. Do not edit files or implement fixes unless explicitly asked."}
  '';
in {
  config = lib.mkIf (config.home.modules.ai && pkgs.stdenv.hostPlatform.isDarwin) {
    home.file =
      {
        ".codex/AGENTS.md".source = ../config/ai/AGENTS.md;
        ".codex/commands".source = ../config/ai/commands;
      }
      // lib.listToAttrs (map (name: {
          name = ".agents/skills/${name}/SKILL.md";
          value.text = skillText name;
        })
        commandNames)
      // lib.listToAttrs (map (name: {
          name = ".agents/skills/${name}/agents/openai.yaml";
          value.text = ''
            policy:
              allow_implicit_invocation: false
          '';
        })
        commandNames);

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
