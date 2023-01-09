--[[ vim.g.copilot_filetypes = { ["*"] = false } ]]
vim.cmd([[imap <silent><script><expr> <C-a> copilot#Accept("\CR")]])
vim.g.copilot_no_tab_map = true
vim.cmd([[highlight CopilotSelected guifg=#555555 ctermbg=8]])
