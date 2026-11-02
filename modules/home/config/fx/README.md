# fx configuration

Enabled on macOS with `home.modules.ai`. The package is installed as `vercel-fx`
to avoid colliding with the JSON tool named `fx`; the shell alias is `f`.

Home Manager links the shared `../ai/AGENTS.md` and `commands/` into `~/.fx/`.
Codex and fx discover the same generated skills in `~/.agents/skills/`:

- `$cx`: summarize session context
- `$pr [PR URL]`: create or update a pull request
- `$qanda`: discuss implementation decisions without editing files
- `$review`: review the current branch without editing files
- `$review-prs owner/repo [PR numbers or URLs] [--no-local-tests]`

Browse them with `/skills` or the `$` picker. fx does not support custom slash
commands. The wrappers read `~/.agents/commands/` rather than duplicating the
shared Markdown. Codex enforces explicit-only invocation through `openai.yaml`;
fx does not read that policy, so the wrappers instruct it to wait for a request.

## Managed configuration and writable state

- `~/.fx/mcp.json` is Nix-managed. Edit `mcp.json` here and rebuild to change
  servers. Filesystem and memory are enabled; all other servers are disabled,
matching OpenCode and Codex. fx refuses `/mcp add` and `/mcp remove` on this
  managed symlink. Use `vercel-fx mcp login <name>` for remote OAuth.
- The custom Catppuccin Mocha theme is Nix-managed. `FX_THEME` selects it.
- The package wrapper defaults `FX_AUTO_UPGRADE=0` to leave binary updates to
  Nix and adds `/nix/store` to `FX_SKILL_SYMLINK_AUTHORITIES`, preserving any
  additional authorities. This works even before a new login shell loads Home
  Manager's environment. fx otherwise rejects skill files outside the home or
  workspace directories. The upstream signed binary is left unchanged.
- `~/.fx/settings.json` remains unmanaged and writable. Model/provider selection,
  permission rules, and workspace preferences saved by fx survive rebuilds.
  Credentials and sessions remain outside dotfiles.

If any managed destination already contains a regular file, back it up before
the first activation or use Home Manager's backup-file support. Existing
`settings.json` files are not replaced.

fx keeps its default `auto` permission mode. This is not identical to OpenCode's
tool-specific allow rules, and full access is not enabled to imitate them.
OpenCode plugins, keybindings, sharing, server settings, and Codex-specific TUI
preferences have no direct equivalents here and are not copied as unknown keys.

fx 0.0.16's metadata parser requires an explicit YAML block marker for multiline
skill descriptions. If an installed third-party skill is skipped with
`unsupported_multiline`, change its `description:` to `description: >-`, keeping
the indented description text unchanged. Reinstalling that skill may restore
the incompatible upstream header.

Rebuild Home Manager, open a new login shell to load the environment overrides,
and start `f`. Use `/provider` or `vercel-fx login` to authenticate if needed.
