local status_ok, fidget = pcall(require, "fidget")
if not status_ok or vim.g.vscode then
	return
end

fidget.setup({})
