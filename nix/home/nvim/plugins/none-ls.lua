local none_ls_status_ok, none_ls = pcall(require, "none-ls")
if not none_ls_status_ok then
	return
end

local formatting = none_ls.builtins.formatting
local diagnostics = none_ls.builtins.diagnostics
local completion = none_ls.builtins.completion

-- https://github.com/prettier-solidity/prettier-plugin-solidity
none_ls.setup({
	debug = false,
	sources = {
		formatting.prettier.with({
			extra_filetypes = { "toml" },
			-- extra_args = { "--single-quote", "--jsx-single-quote" },
		}),
		formatting.black.with({ extra_args = { "--fast" } }),
		formatting.stylua,
		diagnostics.eslint,
		--[[ null_ls.builtins.diagnostics.eslint_d.with({ ]]
		--[[ 	diagnostics_format = "[eslint] #{m}\n(#{c})", ]]
		--[[ }), ]]
		formatting.google_java_format,
		diagnostics.flake8,
		completion.spell,
	},
})
