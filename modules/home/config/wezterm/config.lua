local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.initial_cols = 120
config.initial_rows = 28
config.font_size = 14
config.font = wezterm.font("JetBrains Mono")
config.color_scheme = "Catppuccin Mocha"
config.window_decorations = "RESIZE"
config.enable_tab_bar = false

return config
