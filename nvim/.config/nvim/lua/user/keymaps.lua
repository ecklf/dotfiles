-- Keymaps for better default experience
-- See `:help vim.keymap.set()`

-- LOCAL --
-- Shorten function name
local keymap = vim.keymap.set
local opts = { silent = true }
local opts_noremap = { noremap = true, silent = true }

-- MODE --
-- normal_mode / insert_mode / visual_mode = "",
-- normal_mode = "n",
-- insert_mode = "i",
-- visual_mode = "v",
-- visual_block_mode = "x",
-- term_mode = "t",
-- command_mode = "c",

-- GLOBAL --
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Map copy/paste
keymap("", "<leader>c", '"+y', opts_noremap)
keymap("", "<leader>v", '"+p', opts_noremap)

-- NORMAL --

-- Copy relative file path to clipboard
keymap("n", "<leader>bf", ':let @+ = expand("%")<CR>', opts)

-- Prevent x from overriding what's in the clipboard.
keymap("n", "x", '"_x', opts_noremap)
keymap("n", "X", '"_x', opts_noremap)

-- TODO
-- Edit vim config file in a new tab.
-- keymap("n", "<leader>ev", ":tabnew $INITVIM<cr>", opts)
-- Source vim config file.
-- keymap("n", "<leader>sv", ":source $INITVIM<cr>", opts)

-- Fast saving
keymap("n", "<leader>w", ":w!<cr>", opts)

-- Remap VIM 0 to first non-blank character
keymap("n", "0", "^", opts)

-- Toggle spell check.
keymap("n", "<F5>", ":setlocal spell!<cr>", opts)

-- Toggle relative line numbers and regular line numbers.
keymap("n", "<F6>", ":set invrelativenumber<cr>", opts)

-- Map <Space> to / and <Ctrl-Space> to ? search
keymap("n", "<space>", "/", opts)
keymap("n", "<C-space>", "?", opts)

-- Clear search highlights
keymap("n", "<leader>h", "<cmd>nohlsearch<cr>", opts)

-- Move a line of text using option+[jk]
keymap("n", "<A-j>", "mz:m+<cr>`z", opts)
keymap("n", "<A-k>", "mz:m-2<cr>`z", opts)
keymap("v", "<A-j>", ":m'>+<cr>`<my`>mzgv`yo`z", opts)
keymap("v", "<A-k>", ":m'<-2<cr>`>my`<mzgv`yo`z", opts)

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<A-Up>", ":resize -2<cr>", opts)
keymap("n", "<A-Down>", ":resize +2<cr>", opts)
keymap("n", "<A-Left>", ":vertical resize -2<cr>", opts)
keymap("n", "<A-Right>", ":vertical resize +2<cr>", opts)

-- Buffer management
-- Close buffers

-- keymap("n", "<leader>bd", ":bd<CR>", opts) -- close current buffer
keymap("n", "<leader>bd", ":Bdelete!<CR>", opts) -- close current buffer
keymap("n", "<leader>ba", ":bufdo bd<CR>", opts) -- close all buffers
-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- " Switch CWD to the directory of the open buffer
-- keymap("", "<leader>cd", "map :cd %:p:h<cr>:pwd<cr>", opts)

-- Tab management (don't need this atm)
-- keymap("n", "<leader>tn", ":tabnew<cr>", opts)
-- keymap("n", "<leader>to", ":tabonly<cr>", opts)
-- keymap("n", "<leader>tc", ":tabclose<cr>", opts)
-- keymap("n", "<leader>tm", ":tabmove<cr>", opts)
-- keymap("n", "<leader>t<leader>", ":tabnext", opts)
-- keymap("n", "<leader>m", ":tabnext<cr>", opts)
-- keymap("n", "<leader>n", ":tabprevious<cr>", opts)

-- TODO
-- " Let 'tl' toggle between this and the last accessed tab
-- let g:lasttab = 1
-- nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
-- au TabLeave * let g:lasttab = tabpagenr()

-- " Opens a new tab with the current buffer's path
--
-- " Super useful when editing files in the same directory
-- map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

-- React - replace class= with classname=
keymap("n", "<leader>rc", ":%s/class=/className=/g<cr>", opts)

-- VISUAL --

-- Handled by illuminate plugin
-- pressing * or # searches for the current selection (idea by Michael Naumann)
-- keymap("v", "*", ":<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>", opts_noremap)
-- keymap("v", "#", ":<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>", opts_noremap)

-- Better paste
keymap("v", "p", '"_dP', opts)

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- INSERT --

-- PLUGINS --

-- NvimTree
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
keymap("n", "<leader>tr", ":NvimTreeRefresh<CR>", opts)

-- null-ls
keymap("n", "<leader>f", ":Format<CR>", opts)

-- Comment
keymap("n", "<leader>/", "<cmd>lua require('Comment.api').toggle_current_linewise()<CR>", opts)
keymap("x", "<leader>/", '<ESC><CMD>lua require("Comment.api").toggle_linewise_op(vim.fn.visualmode())<CR>')

-- Telescope
keymap("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap("n", "<leader>ft", ":Telescope live_grep<CR>", opts)
keymap("n", "<leader>fp", ":Telescope projects<CR>", opts)
keymap("n", "<leader>fb", ":Telescope buffers<CR>", opts)
keymap("n", "<leader>fr", ":Telescope lsp_references<CR>", opts)

-- Git
keymap("n", "<leader>gg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", opts)
keymap("n", "<leader>gb", "<cmd>:Git blame<CR>", opts)
keymap("n", "<leader>gs", "<cmd>:Git status<CR>", opts)

-- Quickfix jumping
keymap("n", "<leader>qn", ":try | cprev | catch | clast | catch | endtry<CR>", opts)
keymap("n", "<leader>qm", ":try | cnext | catch | cfirst | catch | endtry<CR>", opts)
keymap("n", "<leader>qc", ":cclose<CR>", opts)

-- DAP
-- keymap("n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", opts)
-- keymap("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", opts)
-- keymap("n", "<leader>di", "<cmd>lua require'dap'.step_into()<cr>", opts)
-- keymap("n", "<leader>do", "<cmd>lua require'dap'.step_over()<cr>", opts)
-- keymap("n", "<leader>dO", "<cmd>lua require'dap'.step_out()<cr>", opts)
-- keymap("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", opts)
-- keymap("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>", opts)
-- keymap("n", "<leader>du", "<cmd>lua require'dapui'.toggle()<cr>", opts)
-- keymap("n", "<leader>dt", "<cmd>lua require'dap'.terminate()<cr>", opts)

-- TODO
-- " Specify the behavior when switching between buffers
-- try
--   set switchbuf=useopen,usetab,newtab
--   set stal=2
-- catch
-- endtry

-- " Return to last edit position when opening files (You want this!)
-- au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

-- " Delete trailing white space on save, useful for some filetypes ;)
-- fun! CleanExtraSpaces()
--   let save_cursor = getpos(".")
--   let old_query = getreg('/')
--   silent! %s/\s\+$//e
--   call setpos('.', save_cursor)
--   call setreg('/', old_query)
-- endfun

-- if has("autocmd")
--   autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
-- endif

-- TODO
--[[ vim.fn.setreg("q", 'ciw`^R"^[b') ]]
