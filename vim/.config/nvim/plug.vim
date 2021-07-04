if has('nvim')
  let g:plugInstallPath = '~/.local/share/nvim/site/autoload/plug.vim'
  let g:pluggedPath = '~/.local/share/nvim/plugged'

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
endif
