# Shared AI instructions

`AGENTS.md` and `commands/` are shared by OpenCode, Codex, and fx. Home Manager
symlinks them into `~/.config/opencode/`, `~/.codex/`, and `~/.fx/`.

OpenCode uses the command Markdown directly as `/cx`, `/pr`, `/qanda`, `/review`,
and `/review-prs`. Codex and fx use thin skill wrappers generated in
`../../ai/default.nix` to expose the same workflows as `$cx`, `$pr`, `$qanda`,
`$review`, and `$review-prs`. The wrappers load the shared Markdown through
`~/.agents/commands/` rather than duplicating its content. Codex uses
`openai.yaml` to enforce explicit invocation; fx receives that restriction as
an instruction in the wrapper instead.

Tool-specific configuration stays in `../opencode/`, `../codex/`, and `../fx/`.
