local nvim_lint_status_ok, nvim_lint = pcall(require, "lint")
if not nvim_lint_status_ok then
	return
end

nvim_lint.linters_by_ft = {
	markdown = { "vale" },
	javascript = { "eslint" },
	typescript = { "eslint" },
	javascriptreact = { "eslint" },
	typescriptreact = { "eslint" },
	svelte = { "eslint" },
	python = { "pylint" },
	--[[ nix = { "statix" }, ]]
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		nvim_lint.try_lint()
	end,
})

vim.keymap.set("n", "<leader>l", function()
	nvim_lint.try_lint()
end, { desc = "Trigger linting for current file" })
