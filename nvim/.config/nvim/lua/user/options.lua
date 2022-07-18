-- Turn backup off, since most stuff is in SVN, git et.c anyway...
vim.opt.backup = false                          -- Creates a backup file
vim.opt.writebackup = false                     -- If a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
vim.opt.swapfile = false                        -- Creates a swapfile
vim.opt.history = 500                           -- Limits history (default: 10000)

vim.opt.showmode = false                        -- Disable showing which mode we are in because we handle it in lualine

vim.opt.fileencoding = "utf-8"                  -- The encoding written to a file
vim.opt.ffs = "unix,dos,mac"                    -- End-of-line (<EOL>) formats that will be tried when starting to edit a new buffer and when reading a file into an existing buffer

-- Enable true colors support and set mirage theme
vim.opt.termguicolors = true                    -- Set term gui colors (most terminals support this)

vim.opt.number = true                           -- Set numbered lines
vim.opt.relativenumber = true                   -- Set relative line numbers 
vim.opt.cursorline = true                       -- Highlight the current line
vim.opt.mouse = "a"                             -- Allow the mouse to be used in neovim
vim.opt.clipboard = "unnamedplus"               -- Allows neovim to access the system clipboard

vim.opt.autoread = true                         -- Auto read when file is changed from the outside

-- Indentation
vim.opt.expandtab = true                        -- Convert tabs to spaces

vim.opt.shiftwidth = 2                          -- The number of spaces inserted for each indentation
vim.opt.tabstop = 2                             -- Insert 2 spaces for a tab

-- TODO
-- vim.opt.foldcolumn = 1                          -- Hide foldcolumn
-- vim.opt.smarttab = true                         -- <Tab> in front of a line inserts blanks
-- vim.opt.linebreak = true                        -- Linebreak
-- vim.opt.textwidth = 500                         -- 500 characters (linebreak)
-- vim.opt.autoindent = true
vim.opt.wrap = false                             -- Wrap lines

vim.opt.smartindent = true                      -- Make indenting smarter again
vim.opt.smartcase = true                        -- Smart case
vim.opt.ignorecase = true                       -- Ignore case in search patterns
vim.opt.hlsearch = true                         -- Highlight all matches on previous search pattern
-- vim.opt.incsearch = true                         -- Makes search act like search in modern browsers

-- vim.opt.magic = true                             -- Changes the special characters that can be used in search patterns
-- vim.opt.showmatch = true                         -- When a bracket is inserted, briefly jump to the matching one
-- vim.opt.lazyredraw = true                        -- Don't redraw while executing macros (good performance config)

vim.opt.scrolloff = 8                           -- Minimal number of screen lines to keep above and below the cursor
vim.opt.sidescrolloff = 8                       -- Same setting for horizontal scrolling

vim.opt.cmdheight = 1                           -- More space in the neovim command line for displaying messages - also try 2
vim.opt.ruler = false                           -- Show the line and column number of the cursor position

-- no sounds on errors
vim.opt.errorbells = false
vim.opt.visualbell = false

-- TODO
-- vim.opt.wildmenu = true                          -- Enables "enhanced mode" of command-line completion
-- " Ignore compiled files
-- set wildignore=*.o,*~,*.pyc
-- 
-- if has("win16") || has("win32")
    -- set wildignore+=.git\*,.hg\*,.svn\*
-- else
    -- set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
-- endif
-- vim.opt.hidden = true                            -- A buffer becomes hidden when it is abandone

vim.opt.completeopt = { "menuone", "noselect" } -- Mostly just for cmp
vim.opt.conceallevel = 0                        -- So that `` is visible in markdown files
vim.opt.pumheight = 10                          -- Pop up menu height
vim.opt.showtabline = 0                         -- Always show/hide tabs
vim.opt.splitbelow = true                       -- Force all horizontal splits to go below current window
vim.opt.splitright = true                       -- Force all vertical splits to go to the right of current window
vim.opt.timeoutlen = 1000                       -- Time to wait for a mapped sequence to complete (in milliseconds)
vim.opt.undofile = true                         -- Enable persistent undo
vim.opt.updatetime = 300                        -- Faster completion (4000ms default)
vim.opt.laststatus = 3
vim.opt.showcmd = false
vim.opt.numberwidth = 4                         -- Set number column width to 2 {default 4}
vim.opt.signcolumn = "yes"                      -- Always show the sign column, otherwise it would shift the text each time
vim.opt.guifont = "monospace:h17"               -- The font used in graphical neovim applications
vim.opt.fillchars.eob=" "

-- set shortmess=I -- Do not show intro message - not needed since we use nvim-alpha
vim.opt.shortmess:append "c"
-- set backspace=eol,start,indent
-- set whichwrap+=<,>,h,l
vim.opt.whichwrap:append("<,>,[,],h,l")
vim.opt.iskeyword:append("-")