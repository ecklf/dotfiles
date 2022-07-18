local colorscheme = "catppuccin"
-- Flavours: latte, frappe, macchiato, mocha
vim.g.catppuccin_flavour = "mocha"

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  return
end