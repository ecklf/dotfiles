local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

return packer.startup(function(use)
	-- Core
	use("wbthomason/packer.nvim") -- Packer self-manage
	use("nvim-lua/plenary.nvim") -- Useful lua functions used ny lots of plugins
	use("lewis6991/impatient.nvim") -- Improves loading times

	-- Colorschemes
	use("cocopon/iceberg.vim")
	use("ayu-theme/ayu-vim")
	use("arcticicestudio/nord-vim")
	use("folke/tokyonight.nvim")
	use("lunarvim/darkplus.nvim")
	use({
		"catppuccin/nvim",
		as = "catppuccin",
	})

	-- UI
	use("goolord/alpha-nvim") -- Greeter UI
	-- Tree plugin
	use({
		"kyazdani42/nvim-tree.lua",
		requires = { "kyazdani42/nvim-web-devicons" },
	})
	-- Bottom line
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons" },
	})
	use("akinsho/bufferline.nvim") -- Tab-like buffers

	-- Utils
	use("moll/vim-bbye") -- Allows to delete buffers without closing windows
	use("lukas-reineke/indent-blankline.nvim") -- Shows indentation marks
	use("akinsho/toggleterm.nvim") -- Easily manage multiple terminal windows

	-- Plug 'norcalli/nvim-colorizer.lua'
	-- https://github.com/windwp/nvim-ts-autotag

	-- Add/change/delete surrounding delimiter pairs with ease
	use({
		"kylechui/nvim-surround",
		tag = "*", -- Use for stability; omit to use `main` branch for the latest features
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
	})
	-- use 'tpope/vim-sleuth' -- Detect tabstop and shiftwidth automatically

	-- Commenting
	use({ "numToStr/Comment.nvim" })

	-- Highlight, list and search todo comments in your projects
	-- use {
	-- "folke/todo-comments.nvim",
	-- requires = "nvim-lua/plenary.nvim",
	-- config = function()
	-- require("todo-comments").setup {
	-- your configuration comes here
	-- or leave it empty to use the default settings
	-- refer to the configuration section below
	-- }
	-- end
	-- }

	-- nvim-cmp and plugins
	use({ "hrsh7th/nvim-cmp" })
	use({ "hrsh7th/cmp-buffer" }) -- Buffer completions
	use({ "hrsh7th/cmp-path" }) -- Path completions
	use({ "saadparwaiz1/cmp_luasnip" }) -- Snippet completions
	use({ "hrsh7th/cmp-nvim-lsp" }) -- Completion for lsp
	use({ "hrsh7th/cmp-nvim-lua" }) -- Completion for lua
	-- Completion - Cargo.toml
	use({
		"saecki/crates.nvim",
		tag = "v0.2.1",
		requires = { "nvim-lua/plenary.nvim" },
	})

	-- Snippets
	use({ "L3MON4D3/LuaSnip" }) -- Snippet engine
	use({ "rafamadriz/friendly-snippets" }) -- Snippet collection

	-- LSP
	use({ "neovim/nvim-lspconfig" }) -- Enable LSP
	use({ "williamboman/mason.nvim" }) -- Portable package manager for Neovim
	use({ "williamboman/mason-lspconfig" }) -- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim
	use({ "jose-elias-alvarez/null-ls.nvim" }) -- For formatters and linters
	use({ "RRethy/vim-illuminate" }) -- Highlighting other uses of the word under the cursor
	use({ "j-hui/fidget.nvim" }) -- Standalone UI for nvim-lsp progress
	use({ "github/copilot.vim" }) -- GitHub Copilot

	-- Telescope

	-- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
	use({
		"nvim-telescope/telescope-fzf-native.nvim",
		run = "make",
	})

	-- Fuzzy Finder (files, lsp, etc)
	use({
		"nvim-telescope/telescope.nvim",
		requires = { "nvim-lua/plenary.nvim" },
	})

	-- Treesitter
	use({ "nvim-treesitter/nvim-treesitter" })
	use({ "nvim-treesitter/nvim-treesitter-context", requires = { "nvim-treesitter/nvim-treesitter" } }) -- Show code context
	use({ "nvim-treesitter/nvim-treesitter-textobjects", requires = { "nvim-treesitter/nvim-treesitter" } }) -- Additional textobjects for treesitter
	use({ "JoosepAlviste/nvim-ts-context-commentstring", requires = { "nvim-treesitter/nvim-treesitter" } }) -- JSX commenting
	use({ "windwp/nvim-autopairs" }) -- Auto ()/{}/[] pairs - integrates with both cmp and treesitter
	-- use { "p00f/nvim-ts-rainbows" } -- Rainbow parentheses - integrates with treesitter

	-- Git
	use("lewis6991/gitsigns.nvim")
	use("tpope/vim-fugitive") -- Git commands in nvim
	use("tpope/vim-rhubarb") -- Fugitive-companion to interact with GitHub

	-- Debug Adapter Protocol
	--   use { "mfussenegger/nvim-dap" }
	--   use { "rcarriga/nvim-dap-ui" }
	--   use { "ravenxrz/DAPInstall.nvim" }

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
