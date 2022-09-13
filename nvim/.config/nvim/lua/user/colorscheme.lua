local colorscheme = "catppuccin"
-- Flavours: latte, frappe, macchiato, mocha

local theme_scheme = vim.fn.getenv("THEME_SCHEME")

if theme_scheme == "light" then
	vim.g.catppuccin_flavour = "latte"
elseif theme_scheme == "dark" then
	vim.g.catppuccin_flavour = "mocha"
else
	vim.g.catppuccin_flavour = "mocha"
end

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
	return
end
