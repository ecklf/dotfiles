# OpenCode tab shortcut

Press **Ctrl+B, O** in a local or configured remote Rex terminal. Home Manager installs the
`rex-opencode-tab` helper; rebuild/switch the host configuration after changes,
then run `rex config check && rex config reload`.

Home Manager renders the helper's absolute Nix-store executable path into
`~/.config/rex/init.lua`. The checked-in `init.lua` is a template; do not execute
its unrendered action directly. This avoids relying on the GUI server's PATH,
which does not necessarily include the Home Manager profile.

Use the keyboard shortcut or **Open OpenCode Tab** in Rex's command palette.
External CLI/API/script invocations are intentionally rejected: forwarding a
native app action from a CLI would require Remote Control. Normal `opencode`
commands in your shell are unaffected.

## Why use a helper?

Rex's queued `session.select` can run before the app knows about a window
created by `session.new_window`, causing it to keep the old tab selected.
The shortcut uses a prepared watcher:

1. Reserve one request for the originating app and snapshot existing sessions/tabs.
2. Start a short-lived watcher with that reservation.
3. Queue native **New Tab** inside the trusted keyboard/palette action itself.
4. Identify the newly owned tab and verify its single shell is idle and ready for input.
5. Clear partial input in that new shell, then run a quoted `cd` and `exec opencode` in place.

The shell process becomes OpenCode in the same pane/PTY. The helper never
creates a split, closes a pane, or resizes the terminal, so OpenCode starts at
the new tab's full size instead of briefly rendering at half width.

Rex can create a new session or add a window to the source session depending on
the native UI context. The watcher handles both. Only newly created sessions
are relabeled; preexisting panes are never replacement targets.

The source terminal never receives input. Only the verified, newly created
shell receives Ctrl-C followed by the shell-quoted startup command; do not type
into that new tab until OpenCode appears. The helper waits for the shell's
redraw before submitting the command and rejects control characters in paths.
A brief shell prompt/command can still be visible, but no split is created.

This requires a POSIX-style interactive shell with line editing, such as zsh or
bash. Unsupported shells are left untouched with an error. Per-app reservations
reject a second shortcut while a tab is opening. Avoid creating unrelated tabs
during the handoff; ambiguous creation or a busy/changed shell fails closed.
Failed startup leaves the new tab available for inspection, without changing
preexisting panes.

**Remote Control can remain disabled.** The helper's API allowlist excludes
client-control methods. Only Rex itself performs New Tab in response to the
user's key/palette action. No listener or authentication setting is changed.

The watcher runs only for the duration of opening a tab; there is no background
service. Preparation happens before native creation, so the watcher cannot miss
the creation event merely because its process starts later. Cancelled/expired
reservations fail closed. To inspect the last result and background errors:

```sh
rex-opencode-tab --status
```

## Remote hosts

The watcher runs on the home server (normally the Mac), not on the remote host.
For remote panes, the Lua action resolves the owning app's **remote connection
ID** and records the remote server's `host_id`. The watcher passes an explicit
`--server` on every RPC and verifies that identity both during preparation and
before completing the tab. A wrong/missing host mapping fails before changing
terminals; it does not silently fall back to the local server.

The GUI's remote host label must also resolve through `rex hosts` on the home
machine. For example, `rex -S yun ls` should reach yun. Remote project paths are
passed unchanged to that host, not checked against the Mac's filesystem. There
is no need to install or run this watcher on yun; OpenCode itself must be
installed there, as with ordinary remote terminal use.

Use the shortcut while that remote terminal is selected. Native tab selection
still happens inside Rex; the helper never calls the remote app-control API.

## Focused checks

```sh
python3 -B -m unittest discover -s modules/home/config/rex -p 'test_rex_opencode*.py' -v
lua modules/home/config/rex/test_opencode_tab.lua
stylua --check --indent-type Spaces --indent-width 2 modules/home/config/rex/init.lua modules/home/config/rex/test_opencode_tab.lua
alejandra --check modules/home/default.nix
```

Tests do not start a live Rex app or real OpenCode, contact a network, or read
credentials. PTY integration tests run isolated bash/zsh shells with startup
files disabled and a dummy OpenCode executable to verify input clearing, quoted
paths, in-place execution, and unchanged terminal size. Native UI focus still
requires a real keyboard/palette check.
