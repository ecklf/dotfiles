local nvim_lint_status_ok, nvim_lint = pcall(require, "lint")
if not nvim_lint_status_ok then
	return
end

local function has_config(bufnr, names)
	return vim.fs.find(names, {
		upward = true,
		stop = vim.loop.os_homedir(),
		path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
	})[1] ~= nil
end

local function get_linters_by_ft(bufnr)
	local linters = {
		markdown = { "vale" },
		python = { "pylint" },
	}

	-- biome for projects configured with it, oxlint otherwise
	local js_linter = "oxlint"
	if has_config(bufnr, { "biome.json", "biome.jsonc" }) then
		js_linter = "biomejs"
	end

	linters.javascript = { js_linter }
	linters.javascriptreact = { js_linter }
	linters.svelte = { js_linter }
	linters.typescript = { js_linter }
	linters.typescriptreact = { js_linter }

	return linters
end

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		nvim_lint.linters_by_ft = get_linters_by_ft(bufnr)
		nvim_lint.try_lint()
	end,
})

vim.keymap.set("n", "<leader>l", function()
	nvim_lint.try_lint()
end, { desc = "Trigger linting for current file" })
