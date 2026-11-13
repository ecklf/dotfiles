-- Rex configuration: https://www.superlogical.com/rex/docs/customize/config
-- Home Manager links this file to ~/.config/rex/init.lua.
-- The server reads this file; reload it on the server's machine after changes.
-- Validate: rex config check
-- Apply:    rex config reload
-- Inspect effective bindings and client-dependent diagnostics: rex keymap

-- Match Herdr/tmux's Ctrl+B prefix while keeping Rex's native Cmd shortcuts.
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

-- Match Herdr's pane resizing, including when Neovim is focused.
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

-- Match Herdr's prefix+g lazygit popup, in the focused terminal's directory.
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
