local status_ok, impatient = pcall(require, "impatient")
if not status_ok or vim.g.vscode then
	return
end

impatient.enable_profile()
