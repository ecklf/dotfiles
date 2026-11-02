# Codex configuration

Enabled on macOS with `home.modules.ai`. OpenCode remains unchanged.

Home Manager seeds `~/.codex/config.toml` from `config.toml` only when the file is
missing. The copy is writable and owned by Codex, so project trust, model choices,
desktop settings, and other preferences persist across Home Manager activations.
Run `codex` normally. There is no merge script or profile.

Existing regular configuration files are left untouched. When migrating from the
previous Home Manager symlink, activation removes that link and seeds a writable
copy from the template. Authentication and session files are not affected.
The template leaves model, sandbox, and approvals at Codex defaults. Initial MCP
enablement matches OpenCode: filesystem and memory enabled, all others disabled.
Secrets are inherited from environment variables, never copied into dotfiles.

Edit preferences in Codex, its desktop app, or `~/.codex/config.toml` directly.
Changes to the dotfiles template affect new configurations only; apply desired
changes to an existing configuration manually.

OpenCode commands are exposed as explicit-only Codex skills:

- `$cx`: summarize session context
- `$pr [PR URL]`: create or update a pull request
- `$qanda`: discuss implementation decisions without editing files
- `$review`: review the current branch without editing files
- `$review-prs owner/repo [PR numbers or URLs] [--no-local-tests]`

Shared instructions and commands live in `../ai/`. Home Manager links the same
`AGENTS.md` and `commands/` directory into `~/.config/opencode/`, `~/.codex/`, and
`~/.fx/`.
Codex and fx skills are thin metadata wrappers generated in `../../ai/default.nix`
that read those shared command files through `~/.agents/commands/`,
interpret command arguments, and preserve review-only behavior. Edit the shared
Markdown once to update all three tools.
Skills live in `~/.agents/skills/`, Codex's supported user skills directory, alongside
the existing Vercel skills. Custom `/prompts:*` commands are deprecated and aren't
installed. Other agents using this shared directory may also discover the skills.

OpenCode-specific plugins, provider caching, sharing, server port, message
navigation bindings, sidebar, tabs, and scroll acceleration aren't copied as
unsupported Codex configuration. The theme, animations, hidden reasoning,
instructions, workflows, and MCP definitions have Codex equivalents.

Rebuild Home Manager and start a new Codex session to use the configuration.
