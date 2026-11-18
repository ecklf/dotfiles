-- Rex configuration: https://www.superlogical.com/rex/docs/customize/config
-- Home Manager links this file to ~/.config/rex/init.lua.
-- The server reads this file; reload it on the server's machine after changes.
-- Validate: rex config check
-- Apply:    rex config reload
-- Inspect effective bindings and client-dependent diagnostics: rex keymap

-- Match tmux's Ctrl+B prefix while keeping Rex's native Cmd shortcuts.
rex.bind("ctrl+b>c", "client.tab.new")
rex.bind("ctrl+b>z", "pane.zoom")
rex.bind("ctrl+b>r", "client.config.reload")
rex.bind("ctrl+b>,", "client.settings")

-- Split below with prefix + quote, or right with prefix + pipe (US layout).
rex.bind("ctrl+b>shift+'", "pane.split", { direction = "down" })
rex.bind("ctrl+b>shift+\\", "pane.split", { direction = "right" })

rex.bind("ctrl+b>h", "pane.focus.left")
rex.bind("ctrl+b>j", "pane.focus.down")
rex.bind("ctrl+b>k", "pane.focus.up")
rex.bind("ctrl+b>l", "pane.focus.right")

-- Match tmux's pane resizing, including when Neovim is focused.
-- Rex's amount is a percentage of the split, not terminal cells.
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+b>shift+" .. key, "pane.resize", { direction = direction, amount = 5 })
  rex.bind("ctrl+shift+" .. key, "pane.resize", { direction = direction, amount = 5 })
end

rex.bind("alt+[", "client.tab.previous")
rex.bind("alt+]", "client.tab.next")
rex.bind("f5", "client.tab.previous")
rex.bind("f6", "client.tab.next")

-- The prefix consumes Ctrl+B; press it twice to send it to the terminal.
rex.bind("ctrl+b>ctrl+b", "pane.send_key", { key = "ctrl+b" })

-- Home Manager installs the pinned backend's Rex module beside this file.
-- Forward Ctrl+H/J/K/L to Neovim; smart-splits hands back to Rex at window edges.
-- In other panes these keys navigate Rex directly, overriding shell bindings.
require("smart-splits-rex").setup({})
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+" .. key, "smart_splits_focus", { direction = direction, key = "ctrl+" .. key })
end

-- Open a prefix+g lazygit popup in the focused terminal's directory.
rex.action({
  name = "lazygit_popup",
  title = "Open Lazygit",
  category = "Git",
  run = function(ctx)
    local proc, process_err = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
    if not proc then
      error(process_err, 0)
    end
    local cwd = (proc.foreground or {}).cwd or (proc.child or {}).cwd
    if not cwd then
      error("Cannot determine the focused terminal's working directory", 0)
    end
    local layer, layer_err = rex.session.new_layer({
      window_id = ctx.window_id,
      bounds = { 0.01, 0.01, 0.98, 0.98 },
      focus = true,
      layout = rex.layout.block({
        flavor = "com.superlogical.terminal.shell",
        label = "lazygit",
        options = {
          command = { "lazygit" },
          cwd = cwd,
          exit = { on_completion = true },
        },
      }),
    })
    if not layer then
      error(layer_err, 0)
    end
    return layer
  end,
})
rex.bind("ctrl+b>g", "lazygit_popup")

-- Open a prefix+o OpenCode tab in the focused terminal's directory.
rex.action({
  name = "opencode_tab",
  title = "Open OpenCode Tab",
  category = "AI",
  run = function(ctx)
    local proc, process_err = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
    if not proc then
      error(process_err, 0)
    end
    local cwd = (proc.foreground or {}).cwd or (proc.child or {}).cwd
    if not cwd then
      error("Cannot determine the focused terminal's working directory", 0)
    end
    local remote = ctx.server and ctx.server ~= ""
    if not ctx.client_id or not ctx.session_id or not ctx.block_id then
      error("OpenCode needs an originating Rex app, session, and terminal", 0)
    end
    -- Only an in-app key/palette action can queue native creation without
    -- external app-control permission. Reject CLI/API calls before reserving.
    if ctx.origin ~= "key" and ctx.origin ~= "palette" then
      error("Use Ctrl+B, O or Open OpenCode Tab in Rex's command palette", 0)
    end
    local client_id, expected_host = ctx.client_id, nil
    if remote then
      -- The app has a different connection ID on each host. Resolve the
      -- remote source pane's owner, not the home-server ctx.client_id.
      local view, view_err = rex.session.view({ session_id = ctx.session_id })
      if not view then
        error(view_err, 0)
      end
      local matches = 0
      for _, window in ipairs(view.windows or {}) do
        for _, layer in ipairs(window.layers or {}) do
          for _, block in ipairs(layer.blocks or {}) do
            if block.block_id == ctx.block_id then
              client_id = block.owner
              matches = matches + 1
            end
          end
        end
      end
      if matches ~= 1 or not client_id or client_id == "" then
        error("The remote source terminal needs a connected Rex app owner", 0)
      end
      local status, status_err = rex.call("server.status", {})
      if not status then
        error(status_err, 0)
      end
      expected_host = status.host_id
      if type(expected_host) ~= "string" or expected_host == "" then
        error("Cannot identify the remote Rex server", 0)
      end
    end
    local caller, caller_err = rex.call("client.inspect", { client_id = client_id })
    if not caller then
      error(caller_err, 0)
    end
    local app = caller.client or {}
    local attached = false
    for _, session_id in ipairs(app.session_ids or {}) do
      attached = attached or session_id == ctx.session_id
    end
    if
      not app.client_id
      or (app.info or {}).kind ~= "app"
      or (app.connection_state or "connected") ~= "connected"
      or not attached
    then
      error("The source terminal needs a connected Rex app in its session", 0)
    end
    -- Snapshot and reserve before the trusted keyboard action creates a tab.
    -- The watcher uses only server APIs; it never sends client-control calls.
    -- Home Manager pins the executable because GUI servers lack shell PATH setup.
    local helper = "@rexOpencodeTab@"
    local command = {
      helper,
      "--prepare",
      "--client",
      app.client_id,
      "--session",
      ctx.session_id,
      "--block",
      ctx.block_id,
      "--cwd",
      cwd,
    }
    if remote then
      table.insert(command, "--server")
      table.insert(command, ctx.server)
      table.insert(command, "--expected-host")
      table.insert(command, expected_host)
    end
    local prepared, prepare_err = rex.exec(command, { timeout = 8 })
    if not prepared then
      error(prepare_err, 0)
    end
    if not prepared.ok then
      error("Cannot prepare OpenCode tab: " .. (prepared.stderr or "helper failed"), 0)
    end
    local decoded, ticket = pcall(rex.json.decode, prepared.stdout)
    if
      not decoded
      or type(ticket) ~= "table"
      or type(ticket.token) ~= "string"
      or #ticket.token ~= 32
      or not ticket.token:match("^[0-9a-f]+$")
    then
      error("OpenCode helper returned an invalid reservation", 0)
    end
    local function cancel()
      rex.exec({ helper, "--cancel", ticket.token, "--client", app.client_id }, { timeout = 2 })
    end
    local job, job_err = rex.exec.start({
      helper,
      "--watch",
      ticket.token,
      "--client",
      app.client_id,
    }, { detach = true })
    if not job then
      cancel()
      error(job_err, 0)
    end
    -- This is performed by Rex as part of the shortcut, not by an external
    -- client.perform request, so Remote Control is not required.
    local queued, queue_err = pcall(rex.client.queue, "client.tab.new")
    if not queued then
      cancel()
      error(queue_err, 0)
    end
    return { opening = true }
  end,
})
rex.bind("ctrl+b>o", "opencode_tab")

-- Account-wide 5-hour and weekly plan limits; q closes and r refreshes.
require("rex-usage").setup({})

-- Native appearance, font, and modifier preferences are set in nix-darwin.

-- One-time theme imports through Rex's supported client action, rather than
-- writing its private custom-theme format. Run these from the command palette
-- on the local Mac server; HOME must refer to the Mac user's home directory.
local function import_kanso(name)
  local home = assert(os.getenv("HOME"), "HOME is required to find Ghostty themes")
  rex.client.queue("client.theme.import", {
    path = home .. "/.config/ghostty/themes/" .. name,
  })
end

rex.action({
  name = "import_kanso_zen",
  title = "Import Kanso Zen (local Mac)",
  category = "Themes",
  run = function()
    import_kanso("kanso-zen")
  end,
})

rex.action({
  name = "import_kanso_pearl",
  title = "Import Kanso Pearl (local Mac)",
  category = "Themes",
  run = function()
    import_kanso("kanso-pearl")
  end,
})
