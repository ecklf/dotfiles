local status_ok, indent_blankline = pcall(require, "ibl")
if not status_ok or vim.g.vscode then
	return
end

indent_blankline.setup({
	scope = {
		enabled = true,
	},
	indent = {
		char = "▏",
	},
	exclude = {
		filetypes = {
			"help",
			"packer",
			"NvimTree",
		},
		buftypes = {
			"terminal",
			"nofile",
		},
	},
})
