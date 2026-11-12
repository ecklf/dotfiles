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

rex.bind("alt+[", "client.tab.previous")
rex.bind("alt+]", "client.tab.next")
rex.bind("f5", "client.tab.previous")
rex.bind("f6", "client.tab.next")

-- The prefix consumes Ctrl+B; press it twice to send it to the terminal.
rex.bind("ctrl+b>ctrl+b", "pane.send_key", { key = "ctrl+b" })

-- Do not bind plain Ctrl+H/J/K/L: leave Neovim/readline navigation intact.
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
