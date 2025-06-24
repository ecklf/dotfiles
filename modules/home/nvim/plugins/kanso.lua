local status_ok, kanso = pcall(require, "kanso")
if not status_ok or vim.g.vscode then
	return
end

kanso.setup({
	compile = false, -- enable compiling the colorscheme
	undercurl = true, -- enable undercurls
	commentStyle = { italic = true },
	functionStyle = {},
	keywordStyle = { italic = true },
	statementStyle = {},
	typeStyle = {},
	disableItalics = false,
	transparent = false,  -- do not set background color
	dimInactive = false,  -- dim inactive window `:h hl-NormalNC`
	terminalColors = true, -- define vim.g.terminal_color_{0,17}
	colors = {            -- add/modify theme and palette colors
		palette = {},
		theme = { zen = {}, pearl = {}, ink = {}, all = {} },
	},
	overrides = function(colors) -- add/modify highlights
		return {}
	end,
	theme = "zen", -- Load "zen" theme
	background = { -- map the value of 'background' option to a theme
		dark = "zen", -- try "ink" !
		light = "pearl",
	},
})
