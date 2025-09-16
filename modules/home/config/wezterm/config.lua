local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.initial_cols = 120
config.initial_rows = 28
config.font_size = 16
config.font = wezterm.font("GeistMono Nerd Font Mono")
config.color_scheme = "Catppuccin Mocha"
config.window_decorations = "RESIZE"
config.enable_tab_bar = false

return config
