local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
	return
end

configs.setup({
	ensure_installed = "all", -- One of "all" or a list of languages
	-- ensure_installed = { 'lua', 'typescript', 'rust', 'go', 'python' },
	ignore_install = { "phpdoc" }, -- List of parsers to ignore installing
	highlight = {
		enable = true, -- False will disable the whole extension
		disable = { "css" }, -- List of language that will be disabled
	},
	autopairs = {
		enable = true,
	},
	indent = { enable = true, disable = { "python", "css" } },
})
