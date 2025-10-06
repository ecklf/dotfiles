

local status_cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_cmp_ok then
	return
end

local setup = function()
	local signs = {
		{ name = "DiagnosticSignError", text = "" },
		{ name = "DiagnosticSignWarn", text = "" },
		{ name = "DiagnosticSignHint", text = "" },
		{ name = "DiagnosticSignInfo", text = "" },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
	end

	local config = {
		virtual_text = false, -- disable virtual text
		signs = {
			active = signs,   -- show signs
		},
		update_in_insert = true,
		underline = true,
		severity_sort = true,
		float = {
			focusable = true,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	}

	vim.diagnostic.config(config)

	-- disables lsp logs to ~./local/state/nvim/lsp.log
	vim.lsp.set_log_level("off")

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = "rounded",
	})

	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = "rounded",
	})
end

local function lsp_keymaps(bufnr)
	local opts = { noremap = true, silent = true }
	local keymap = vim.api.nvim_buf_set_keymap
	keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	keymap(bufnr, "n", "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
	keymap(bufnr, "n", "<leader>h", "<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>", opts)

	-- keymap.set('n', '<leader>e', vim.diagnostic.open_float)
	keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	keymap(bufnr, "n", "<leader>lf", "<cmd>lua vim.lsp.buf.formatting()<cr>", opts)
	keymap(bufnr, "n", "<leader>li", "<cmd>LspInfo<cr>", opts)
	keymap(bufnr, "n", "<leader>lI", "<cmd>LspInstallInfo<cr>", opts)
	keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
	keymap(bufnr, "n", "[d", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", opts)
	keymap(bufnr, "n", "]d", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", opts)
	keymap(bufnr, "n", "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
	keymap(bufnr, "n", "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	-- keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
	keymap(bufnr, "n", "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
	vim.cmd([[ command! Format execute 'lua vim.lsp.buf.formatting()' ]])
end

local on_attach = function(client, bufnr)
	--[[ if client.name == "eslint" then ]]
	--[[ 	vim.api.nvim_create_autocmd("BufWritePre", { ]]
	--[[ 		buffer = bufnr, ]]
	--[[ 		command = "EslintFixAll", ]]
	--[[ 	}) ]]
	--[[ end ]]

	if client.name == "typescript-tools" then
		client.server_capabilities.document_formatting = false
	end

	if client.name == "lua_ls" then
		client.server_capabilities.document_formatting = false
	end

	lsp_keymaps(bufnr)
	local status_ok, illuminate = pcall(require, "illuminate")
	if not status_ok or vim.g.vscode then
		return
	end
	illuminate.on_attach(client)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
setup()

local servers = {
	"bashls",
	"biome",
	"dockerls",
	"eslint",
	"gopls",
	"graphql",
	"html",
	"jsonls",
	"lua_ls",
	"nixd",
	"pyright",
	"rust_analyzer",
	"stylelint_lsp",
	"tailwindcss",
	"terraformls",
	-- "vtsls",
	"yamlls",
	--[[ "cssls", ]]
	--[[ "jsonls", ]]
}

local opts = {}

for _, server in pairs(servers) do
	opts = {
		on_attach = on_attach,
		capabilities = capabilities,
		-- on_attach = require("user.lsp.handlers").on_attach,
		-- capabilities = require("user.lsp.handlers").capabilities,
	}



	if server == "biome" then
		local biome_opts = {
			settings = {
				settings = {
					init_options = {
						timeout = 10000, -- Set the desired timeout in milliseconds
					},
				},
			},
		}
		opts = vim.tbl_deep_extend("force", biome_opts, opts)
	end

	if server == "nixd" then
		local nixd_opts = {
			cmd = { "nixd" },
			settings = {
				nixd = {
					nixpkgs = {
						expr = "import <nixpkgs> { }",
					},
					formatting = {
						command = { "alejandra" },
					},
					--[[ options = { ]]
					--[[ 	nixpkgs = { ]]
					--[[ 		expr = '(builtins.getFlake "/home/ecklf/dotfiles/nix").nixosConfigurations.snowflake.options', ]]
					--[[ 	}, ]]
					--[[ 	home_manager = { ]]
					--[[ 		expr = '(builtins.getFlake "/home/ecklf/dotfiles/nix").nixosConfigurations.snowflake.options', ]]
					--[[ 	}, ]]
					--[[ }, ]]
				},
			},
		}
		opts = vim.tbl_deep_extend("force", nixd_opts, opts)
	end

	if server == "eslint" then
		local eslint_opts = {
			settings = {
				settings = {
					packageManager = "pnpm",
				},
			},
		}
		opts = vim.tbl_deep_extend("force", eslint_opts, opts)
	end

	if server == "lua_ls" then
		local lua_ls_opts = {
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},

					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.stdpath("config") .. "/lua"] = true,
					},
					workspace = { checkThirdParty = false },
					telemetry = { enable = false },
				},
			},
		}
		opts = vim.tbl_deep_extend("force", lua_ls_opts, opts)
	end

	if server == "rust_analyzer" then
		local rust_analyzer_opts = {
			settings = {
				-- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
				["rust-analyzer"] = {
					checkOnSave = {
						command = "clippy",
					},
					procMacro = {
						enable = true,
					},
					files = {
						excludeDirs = {
							"node_modules",
						},
						watcherExclude = {
							"node_modules",
						},
					},
					--[[ cargo = { ]]
					--[[   loadOutDirsFromCheck = true, ]]
					--[[ }, ]]
				},
			},
		}
		opts = vim.tbl_deep_extend("force", rust_analyzer_opts, opts)
	end

	if server == "gopls" then
		local gopls_opts = {
			cmd = { "gopls", "serve" },
			settings = {
				gopls = {
					analyses = {
						unusedparams = true,
					},
					staticcheck = true,
				},
			},
		}

		opts = vim.tbl_deep_extend("force", gopls_opts, opts)
	end

	if server == "pyright" then
		local pyright_opts = {
			settings = {
				python = {
					analysis = {
						typeCheckingMode = "off",
					},
				},
			},
		}

		opts = vim.tbl_deep_extend("force", pyright_opts, opts)
	end

	vim.lsp.config[server] = opts
end

-- TypeScript Tools setup
local typescript_tools_status_ok, typescript_tools = pcall(require, "typescript-tools")
if typescript_tools_status_ok then
	typescript_tools.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		settings = {
			tsserver_max_memory = 8192,
			complete_function_calls = true,
			include_completions_with_insert_text = true,
			tsserver_file_preferences = {
				includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayVariableTypeHints = true,
				includeInlayVariableTypeHintsWhenTypeMatchesName = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayEnumMemberValueHints = true,
			},
		},
	})
end
