local nvim_lint_status_ok, nvim_lint = pcall(require, "lint")
if not nvim_lint_status_ok then
	return
end

local function get_linters_by_ft(bufnr)
	local biome_json = vim.fs.find({ "biome.json", "biome.jsonc" }, {
		upward = true,
		stop = vim.loop.os_homedir(),
		path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
	})[1]

	local linters = {
		markdown = { "vale" },
		python = { "pylint" },
	}

	if biome_json then
		linters.javascript = { "biomejs" }
		linters.javascriptreact = { "biomejs" }
		linters.svelte = { "biomejs" }
		linters.typescript = { "biomejs" }
		linters.typescriptreact = { "biomejs" }
	else
		linters.javascript = { "eslint" }
		linters.javascriptreact = { "eslint" }
		linters.svelte = { "eslint" }
		linters.typescript = { "eslint" }
		linters.typescriptreact = { "eslint" }
	end

	return linters
end

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		local linters = get_linters_by_ft(bufnr)
		nvim_lint.linters_by_ft = linters
		nvim_lint.try_lint()
	end,
})

vim.keymap.set("n", "<leader>l", function()
	nvim_lint.try_lint()
end, { desc = "Trigger linting for current file" })
