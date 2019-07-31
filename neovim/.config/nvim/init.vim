" Specific setups for neovim / vim
if has('nvim')
	let g:plugInstallPath = '~/.local/share/nvim/site/autoload/plug.vim'
	let g:pluggedPath = '~/.local/share/nvim/plugged'
else
	let g:plugInstallPath = '~/.vim/autoload/plug.vim'
	let g:pluggedPath = '~/.vim/plugged'
endif

" Begin setup if vplug not installed
if empty(glob(g:plugInstallPath))
  silent execute '!curl -fLo ' . g:plugInstallPath . ' --create-dirs
      \ "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(g:pluggedPath)
  Plug 'itchyny/lightline.vim'
	Plug 'terryma/vim-multiple-cursors'
	Plug 'scrooloose/nerdtree'
	Plug 'airblade/vim-gitgutter'
	Plug 'junegunn/fzf'
	Plug 'junegunn/fzf.vim'
	Plug 'mattn/emmet-vim'
	Plug 'tpope/vim-eunuch'
	Plug 'tpope/vim-surround'
	Plug 'w0rp/ale'
  Plug 'terryma/vim-expand-region'
  Plug 'gregsexton/MatchTag'
  Plug 'rizzatti/dash.vim'
  Plug 'prettier/vim-prettier', { 'do': 'yarn install' }
	Plug 'arcticicestudio/nord-vim'
  Plug 'yggdroot/indentline'
call plug#end()
" End setup if vplug not installed

" Basic config
syntax on
colorscheme nord
set number
set cursorline
set history=500
" set wildmode=longest,list,full
" set formatoptions=tcqr

"Indent
set expandtab
set tabstop=2
set shiftwidth=2

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
command W w !sudo tee % > /dev/null

" Indentline
let g:indentLine_char_list = ['|', '¦', '┆', '┊']

" Lightline
set laststatus=2
set noshowmode

let g:lightline = {
      \ 'colorscheme': 'nord',
      \ }

" NerdTree
map <C-o> :NERDTreeToggle<CR>

" Prettier
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync

