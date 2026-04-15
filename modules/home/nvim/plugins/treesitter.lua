if vim.g.vscode then
	return
end

-- Native treesitter highlighting (Neovim 0.12+)
-- Parsers are managed by Nix
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		local ft = vim.bo[args.buf].filetype
		-- Disable for specific filetypes
		if ft == "css" then
			return
		end
		pcall(vim.treesitter.start, args.buf)
	end,
})
