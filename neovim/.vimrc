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
	Plug 'prettier/vim-prettier', { 'do': 'yarn install' }
	Plug 'arcticicestudio/nord-vim'
call plug#end()
" End setup if vplug not installed

" Visuals
set number
colorscheme nord

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
