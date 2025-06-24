local theme = "catppuccin"
local theme_flavor = vim.fn.getenv("THEME_SCHEME")

-- Flavours: latte, frappe, macchiato, mocha
if theme_flavor == "light" then
	theme = theme .. "-" .. "latte"
elseif theme_flavor == "dark" then
	theme = theme .. "-" .. "mocha"
else
	theme = theme .. "-" .. "mocha"
end

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. theme)
if not status_ok or vim.g.vscode then
	return
end
