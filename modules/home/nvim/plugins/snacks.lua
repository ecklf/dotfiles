local status_ok, snacks = pcall(require, "snacks")
if not status_ok or vim.g.vscode then
	print("Failed to load snacks-nvim")
	return
end

snacks.setup({
	input = { enabled = true },
	picker = { enabled = true },
	terminal = { enabled = true },
})
