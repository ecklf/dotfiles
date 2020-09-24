if exists('g:vscode')
  " VSCode specific configuration. Utilized by this extension:
  " https://marketplace.visualstudio.com/items?itemName=asvetliakov.vscode-neovim
  xmap gc  <Plug>VSCodeCommentary
  nmap gc  <Plug>VSCodeCommentary
  omap gc  <Plug>VSCodeCommentary
  nmap gcc <Plug>VSCodeCommentaryLine

  " With a map leader it's possible to do extra key combinations
  " like <leader>w saves the current file
  let mapleader = ","
  
  " Fast saving
  nmap <leader>w :w<cr>
  " Replace class= with className= 
  :map <leader>rc :%s/class=/className=/g<CR>
  
  " Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
  map <space> /
  map <c-space> ?

  " Useful mappings for managing tabs
  map <leader>tn :tabnew<cr>
  map <leader>to :tabonly<cr>
  map <leader>tc :tabclose<cr>
  map <leader>tm :tabmove 
  map <leader>t<leader> :tabnext 
  map <leader>m :tabnext<cr>
  map <leader>n :tabprevious<cr>
else
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " AUTOMATIC SETUP 
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Detect nvim installation, else use vim as fallback
  if has('nvim')
      let g:plugInstallPath = '~/.local/share/nvim/site/autoload/plug.vim'
      let g:pluggedPath = '~/.local/share/nvim/plugged'
  else
      let g:plugInstallPath = '~/.vim/autoload/plug.vim'
      let g:pluggedPath = '~/.vim/plugged'
  endif

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " VIMPLUG SETUP
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  if empty(glob(g:plugInstallPath))
      silent execute '!curl -fLo ' . g:plugInstallPath . ' --create-dirs
        \ "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"'
      autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif

  call plug#begin(g:pluggedPath)
      " UI
      Plug 'ayu-theme/ayu-vim'
      Plug 'scrooloose/nerdtree'
      Plug 'ryanoasis/vim-devicons'
      Plug 'itchyny/lightline.vim'
      Plug 'airblade/vim-gitgutter'
      
      " Search helpers
      Plug 'junegunn/fzf'
      Plug 'junegunn/fzf.vim'
      
      " Linting and Visuals
      Plug 'yggdroot/indentline'
      
      " Shell / Documentation Helpers
      Plug 'tpope/vim-fugitive' " GIT
      Plug 'tpope/vim-eunuch'   " UNIX
      "Plug 'sheerun/vim-polyglot' " Lang Pack 
      Plug 'rizzatti/dash.vim'  " Docs 
      
      " Code Helpers
      Plug 'tpope/vim-surround'
      Plug 'terryma/vim-expand-region'
      Plug 'scrooloose/nerdcommenter'
      Plug 'mattn/emmet-vim'
      Plug 'alvan/vim-closetag'
      Plug 'MattesGroeger/vim-bookmarks' 
      Plug 'liuchengxu/vista.vim'

      " Autocompletion
      Plug 'neoclide/coc.nvim', {'branch': 'release'}
      
      " Language Syntax
      Plug 'posva/vim-vue'
      Plug 'pangloss/vim-javascript'
      "Plug 'leafgarland/typescript-vim'
      Plug 'HerringtonDarkholme/yats.vim' " Alternative to typescript-vim
      Plug 'maxmellon/vim-jsx-pretty'
  call plug#end()

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " GENERAL 
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Turn backup off, since most stuff is in SVN, git et.c anyway...
  set nobackup
  set nowb
  set noswapfile
  set history=500

  " Enable Syntax highlighting
  syntax on
  set encoding=utf8
  set ffs=unix,dos,mac

  " Enable true colors support and set mirage theme
  set termguicolors
  let ayucolor="mirage"
  colorscheme ayu

  " Cursor style
  set cursorline

  " Display relative nubers on all lines beside the current
  set number
  set relativenumber

  " Hide foldcolumn
  :setlocal foldcolumn=0

  " Don't show intro message
  set shortmess=I

  " Remove linenumbers from terminal
  :tnoremap <Esc> <C-\><C-n>
  au TermOpen * setlocal nonumber norelativenumber
  " set wildmode=longest,list,full
  " set formatoptions=tcqr

  " Enable filetype plugins
  filetype plugin on
  filetype indent on

  " Auto read when file is changed from the outside
  set autoread

  " With a map leader it's possible to do extra key combinations
  " like <leader>w saves the current file
  let mapleader = ","

  " Fast saving
  nmap <leader>w :w!<cr>

  " :W sudo saves the file 
  " (useful for handling the permission-denied error)
  command! W w !sudo tee % > /dev/null

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " INDENT SETTINGS
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Use spaces instead of tabs
  set expandtab

  " Be smart when using tabs ;)
  set smarttab

  " 1 tab == 4 spaces
  set shiftwidth=2
  set tabstop=2

  " Linebreak on 500 characters
  set lbr
  set tw=500

  set ai "Auto indent
  set si "Smart indent
  set wrap "Wrap lines

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " VIM UI 
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Set 7 lines to the cursor - when moving vertically using j/k
  set so=7

  " Turn on the Wild menu
  set wildmenu

  " Ignore compiled files
  set wildignore=*.o,*~,*.pyc

  if has("win16") || has("win32")
      set wildignore+=.git\*,.hg\*,.svn\*
  else
      set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
  endif

  " Always show current position
  set ruler

  " Height of the command bar
  set cmdheight=2

  " A buffer becomes hidden when it is abandoned
  set hid

  " Configure backspace so it acts as it should act
  set backspace=eol,start,indent
  set whichwrap+=<,>,h,l

  " Ignore case when searching
  set ignorecase

  " When searching try to be smart about cases 
  set smartcase

  " Highlight search results
  set hlsearch

  " Makes search act like search in modern browsers
  set incsearch 

  " Don't redraw while executing macros (good performance config)
  set lazyredraw 

  " For regular expressions turn magic on
  set magic

  " Show matching brackets when text indicator is over them
  set showmatch 

  " How many tenths of a second to blink when matching brackets
  set mat=2

  " No annoying sound on errors
  set noerrorbells
  set novisualbell
  set t_vb=
  set tm=500

  " Properly disable sound on errors on MacVim
  if has("gui_macvim")
      autocmd GUIEnter * set vb t_vb=
  endif

  " Add a bit extra margin to the left
  set foldcolumn=1

  """"""""""""""""""""""""""""""
  " GLOBALS AND NORMAL MODE
  """"""""""""""""""""""""""""""
  " Replace class= with className= 
  :map <leader>rc :%s/class=/className=/g<CR>

  " Clear search highlight 
  nnoremap <Leader><space> :noh<cr>

  """"""""""""""""""""""""""""""
  " VISUAL MODE
  """"""""""""""""""""""""""""""
  " Visual mode pressing * or # searches for the current selection
  " Super useful! From an idea by Michael Naumann
  vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
  vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>

  """"""""""""""""""""""""""""""
  " INSERT MODE
  """"""""""""""""""""""""""""""
  " Cycle through suggestion list with C-j/k
  inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<Down>"
  inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<Up>"

  " Expand body regions 
  inoremap (; (<CR>);<C-c>O
  inoremap (, (<CR>),<C-c>O
  inoremap {; {<CR>};<C-c>O
  inoremap {, {<CR>},<C-c>O
  inoremap [; [<CR>];<C-c>O
  inoremap [, [<CR>],<C-c>O
  inoremap (<CR> (<CR>)<C-c>O
  inoremap (<CR> (<CR>)<C-c>O
  inoremap {<CR> {<CR>}<C-c>O
  inoremap {<CR> {<CR>}<C-c>O
  inoremap [<CR> [<CR>]<C-c>O
  inoremap [<CR> [<CR>]<C-c>O
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " MOVEMENT
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
  map <space> /
  map <c-space> ?

  " Disable highlight when <leader><cr> is pressed
  map <silent> <leader><cr> :noh<cr>

  " Smart way to move between windows
  map <C-j> <C-W>j
  map <C-k> <C-W>k
  map <C-h> <C-W>h
  map <C-l> <C-W>l

  " Close the current buffer
  map <leader>bd :Bclose<cr>:tabclose<cr>gT

  " Close all the buffers
  map <leader>ba :bufdo bd<cr>
  map <leader>l :bnext<cr>
  map <leader>h :bprevious<cr>

  " Useful mappings for managing tabs
  map <leader>tn :tabnew<cr>
  map <leader>to :tabonly<cr>
  map <leader>tc :tabclose<cr>
  map <leader>tm :tabmove 
  map <leader>t<leader> :tabnext 
  map <leader>m :tabnext<cr>
  map <leader>n :tabprevious<cr>

  " Let 'tl' toggle between this and the last accessed tab
  let g:lasttab = 1
  nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
  au TabLeave * let g:lasttab = tabpagenr()

  " Opens a new tab with the current buffer's path
  " Super useful when editing files in the same directory
  map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

  " Switch CWD to the directory of the open buffer
  map <leader>cd :cd %:p:h<cr>:pwd<cr>

  " Specify the behavior when switching between buffers 
  try
    set switchbuf=useopen,usetab,newtab
    set stal=2
  catch
  endtry

  " Return to last edit position when opening files (You want this!)
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " MAPPINGS
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Remap VIM 0 to first non-blank character
  map 0 ^

  " Map copy/paste
  map <leader>c "+y
  map <leader>v "+p

  " Move a line of text using ALT+[jk]
  nmap <M-j> mz:m+<cr>`z
  nmap <M-k> mz:m-2<cr>`z
  vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
  vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

  " Delete trailing white space on save, useful for some filetypes ;)
  fun! CleanExtraSpaces()
      let save_cursor = getpos(".")
      let old_query = getreg('/')
      silent! %s/\s\+$//e
      call setpos('.', save_cursor)
      call setreg('/', old_query)
  endfun

  if has("autocmd")
      autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
  endif

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " COC.NVIM
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Set linting update time
  set updatetime=300
  "hi CocErrorSign guifg=#f07178
  "hi CocErrorHighlight guibg=#f07178 guifg=#212733

  " React specific: auto set filetypes
  "autocmd bufnewfile,bufread *.jsx set filetype=javascript.jsx
  "autocmd bufnewfile,bufread *.tsx set filetype=typescript.tsx

  " Use tab for trigger completion with characters ahead and navigate.
  " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
  function! s:check_back_space() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

  " Use <c-space> to trigger completion.
  inoremap <silent><expr> <c-space> coc#refresh()
  " let g:coc_snippet_next = '<tab>'

  " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
  " Coc only does snippet and additional edit on confirm.
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
  " Or use `complete_info` if your vim support it, like:
  " inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

  " Use `[g` and `]g` to navigate diagnostics
  nmap <silent> [g <Plug>(coc-diagnostic-prev)
  nmap <silent> ]g <Plug>(coc-diagnostic-next)

  " Remap keys for gotos
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)

  " Use K to show documentation in preview window
  nnoremap <silent> K :call <SID>show_documentation()<CR>

  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction

  " Remap for rename current word
  nmap <leader>rn <Plug>(coc-rename)

  " Remap for format selected region
  command! -nargs=0 Prettier :CocCommand prettier.formatFile
  xmap <leader>f  <Plug>(coc-format-selected)
  nmap <leader>f  <Plug>(coc-format-selected)

  " Multiple cursor support
  hi CocCursorRange guibg=#b16286 guifg=#ebdbb2
  nmap <expr> <silent> <C-d> <SID>select_current_word()

  function! s:select_current_word()
    if !get(g:, 'coc_cursors_activated', 0)
      return "\<Plug>(coc-cursors-word)"
    endif
    return "*\<Plug>(coc-cursors-word):nohlsearch\<CR>"
  endfunc

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " CLOSETAG
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " These are the file types where this plugin is enabled.
  let g:closetag_filetypes = 'html,xhtml,phtml,vue,javascriptreact,typescriptreact,javascript.jsx,typescript.tsx'

  " This will make the list of non-closing tags self-closing in the specified files.
  let g:closetag_xhtml_filetypes = 'xhtml,javascriptreact,typescriptreact,javascript.jsx,typescript.tsx'

  " This will make the list of non-closing tags case-sensitive (e.g. `<Link>` will be closed while `<link>` won't.)
  let g:closetag_emptyTags_caseSensitive = 1

  " Disables auto-close if not in a "valid" region (based on filetype)
  let g:closetag_regions = {
      \ 'javascript.jsx': 'jsxRegion',
      \ 'typescript.tsx': 'jsxRegion,tsxRegion',
      \ 'javascriptreact': 'jsxRegion',
      \ 'typescriptreact': 'jsxRegion,tsxRegion',
      \ }

  " Shortcut for closing tags, default is '>'
  let g:closetag_shortcut = '>'

  " Add > at current position without closing the current tag, default is ''
  let g:closetag_close_shortcut = '<leader>>'

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " INDENTLINE
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  let g:indentLine_char_list = ['|', '¦', '┆', '┊']
  " Prevent removing quotes from json
  autocmd Filetype json let g:indentLine_setConceal = 0
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " LIGHTLINE
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  set laststatus=2
  set noshowmode

  function! StatusDiagnostic() abort
    let info = get(b:, 'coc_diagnostic_info', {})
    if empty(info) | return '' | endif
    let msgs = []
    if get(info, 'error', 0)
      call add(msgs, '✖ ' . info['error'])
    endif
    if get(info, 'warning', 0)
      call add(msgs, '⚠ ' . info['warning'])
    endif
    return join(msgs, ' '). ' ' . get(g:, 'coc_status', '')
  endfunction

  let g:lightline = {
      \ 'colorscheme': 'ayu_mirage',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'cocstatus', 'currentfunction', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head',
      \   'cocstatus': 'StatusDiagnostic',
      \   'currentfunction': 'CocCurrentFunction'
      \ },
  \ }

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " NERDTREE
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  map <C-o> :NERDTreeToggle<CR>

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " FZF 
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  map <C-p> :FZF<CR>

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " VISTA
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  let g:vista_default_executive = 'ctags'

  let g:vista_executive_for = {
    \ 'go': 'ctags',
    \ 'javascript': 'coc',
    \ 'typescript': 'coc',
    \ 'javascriptreact': 'coc',
    \ 'typescriptreact': 'coc',
    \ 'python': 'coc',
    \ }

  " Ensure you have installed some decent font to show these pretty symbols, then you can enable icon for the kind.
  let g:vista#renderer#enable_icon = 1

  " The default icons can't be suitable for all the filetypes, you can extend it as you wish.
  let g:vista#renderer#icons = {
  \   "function": "\uf794",
  \   "variable": "\uf71b",
  \  }

  let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]

  if executable('typescript-language-server')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'typescript-language-server',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
        \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tsconfig.json'))},
        \ 'whitelist': ['typescript', 'typescriptreact', 'typescript.tsx'],
        \ })
  endif

endif
