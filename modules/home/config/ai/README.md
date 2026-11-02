# Shared AI instructions

`AGENTS.md` and `commands/` are shared by OpenCode and Codex. Home Manager
symlinks them into `~/.config/opencode/` and `~/.codex/`.

OpenCode uses the command Markdown directly as `/cx`, `/pr`, `/qanda`, `/review`,
and `/review-prs`. Codex uses thin skill wrappers generated in `../../codex/default.nix`
to expose the same workflows as `$cx`, `$pr`, `$qanda`, `$review`, and `$review-prs`.
The wrappers load the shared Markdown rather than duplicating its content.

Tool-specific configuration stays in `../opencode/` and `../codex/`.
