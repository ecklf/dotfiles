local conform_status_ok, conform = pcall(require, "conform")
if not conform_status_ok then
	return
end

local function has_config(bufnr, names)
	return vim.fs.find(names, {
		upward = true,
		stop = vim.loop.os_homedir(),
		path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
	})[1] ~= nil
end

-- biome for projects configured with it, oxfmt otherwise
local function biome_or_oxfmt(bufnr)
	if has_config(bufnr, { "biome.json", "biome.jsonc" }) then
		return { "biome" }
	end
	return { "oxfmt" }
end

local formatters = {
	astro = { "biome" },
	css = biome_or_oxfmt,
	go = { "goimports", "gofmt" },
	html = biome_or_oxfmt,
	javascript = biome_or_oxfmt,
	javascriptreact = biome_or_oxfmt,
	json = biome_or_oxfmt,
	jsonc = biome_or_oxfmt,
	lua = { "stylua" },
	nix = { "alejandra" },
	python = { "isort", "black" },
	rust = { "rustfmt" },
	sh = { "shfmt" },
	svelte = { "biome" },
	terraform = { "terraform_fmt" },
	toml = { "oxfmt" },
	typescript = biome_or_oxfmt,
	typescriptreact = biome_or_oxfmt,
	vue = biome_or_oxfmt,
}

conform.setup({
	lsp_fallback = true,
	formatters_by_ft = formatters,
	formatters = {
		[formatters.lua[1]] = {
			---@diagnostic disable-next-line: unused-local
			condition = function(self, ctx)
				if string.match(ctx.dirname, "vercel/proxy") then
					return false
				end

				return true
			end,
		},
	},
	format_after_save = function(bufnr)
		-- Disable with a global or buffer-local variable
		if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
			return
		end
		return { timeout_ms = 1000, lsp_fallback = true, async = true, formatters_by_ft = formatters }
	end,
})

vim.api.nvim_create_user_command("Format", function(args)
	local range = nil
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, end_line:len() },
		}
	end
	conform.format({ async = true, lsp_fallback = true, range = range })
end, { range = true })
vim.api.nvim_create_user_command("FormatDisable", function(args)
	if args.bang then
		-- FormatDisable! will disable formatting just for this buffer
		vim.b.disable_autoformat = true
	else
		vim.g.disable_autoformat = true
	end
end, {
	desc = "Disable autoformat-on-save",
	bang = true,
})
vim.api.nvim_create_user_command("FormatEnable", function()
	vim.b.disable_autoformat = false
	vim.g.disable_autoformat = false
end, {
	desc = "Re-enable autoformat-on-save",
})
