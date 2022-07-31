local status_ok, mason = pcall(require, "mason")
if not status_ok then
	return
end

mason.setup()

require("user.lsp.lsp-config")
require("user.lsp.handlers").setup()
require("user.lsp.null-ls")
