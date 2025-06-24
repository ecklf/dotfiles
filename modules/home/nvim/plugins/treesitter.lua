local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok or vim.g.vscode then
	return
end

configs.setup({
	-- Do not use this for nix
	-- ensure_installed = "all", -- One of "all" or a list of languages
	-- ensure_installed = { 'lua', 'typescript', 'rust', 'go', 'python' },
	-- ignore_install = { "phpdoc" }, -- List of parsers to ignore installing
	highlight = {
		enable = true, -- False will disable the whole extension
		disable = { "css" }, -- List of language that will be disabled
	},
	autotag = {
		enable = true,
	},
	autopairs = {
		enable = true,
	},
	indent = { enable = true, disable = { "python", "css" } },
})
