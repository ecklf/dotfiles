local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
	return
end

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
			active = signs, -- show signs
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
	if client.name == "tsserver" then
		client.server_capabilities.document_formatting = false
	end

	if client.name == "lua_ls" then
		client.server_capabilities.document_formatting = false
	end

	lsp_keymaps(bufnr)
	local status_ok, illuminate = pcall(require, "illuminate")
	if not status_ok then
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
	--[[ "cssls", ]]
	"stylelint_lsp",
	"dockerls",
	"eslint",
	"gopls",
	"graphql",
	--[[ "jsonls", ]]
	"html",
	"jsonls",
	"pyright",
	"rust_analyzer",
	"lua_ls",
	"tailwindcss",
	"terraformls",
	"tsserver",
	"yamlls",
}

local opts = {}

for _, server in pairs(servers) do
	opts = {
		on_attach = on_attach,
		capabilities = capabilities,
		-- on_attach = require("user.lsp.handlers").on_attach,
		-- capabilities = require("user.lsp.handlers").capabilities,
	}

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

	lspconfig[server].setup(opts)
end
