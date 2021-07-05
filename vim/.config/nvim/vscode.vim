  " VSCode specific configuration. Utilized by this extension:
  " https://marketplace.visualstudio.com/items?itemName=asvetliakov.vscode-neovim
  " Workbench Navigation
  nnoremap <silent> <C-j> :call VSCodeNotify('workbench.action.navigateDown')<CR>
  xnoremap <silent> <C-j> :call VSCodeNotify('workbench.action.navigateDown')<CR>
  nnoremap <silent> <C-k> :call VSCodeNotify('workbench.action.navigateUp')<CR>
  xnoremap <silent> <C-k> :call VSCodeNotify('workbench.action.navigateUp')<CR>
  nnoremap <silent> <C-h> :call VSCodeNotify('workbench.action.navigateLeft')<CR>
  xnoremap <silent> <C-h> :call VSCodeNotify('workbench.action.navigateLeft')<CR>
  nnoremap <silent> <C-l> :call VSCodeNotify('workbench.action.navigateRight')<CR>
  xnoremap <silent> <C-l> :call VSCodeNotify('workbench.action.navigateRight')<CR>
  nnoremap <silent> <C-r> :call VSCodeNotify('workbench.action.tasks.reRunTask')<CR>
  xnoremap <silent> <C-r> :call VSCodeNotify('workbench.action.tasks.reRunTask')<CR>

  nnoremap gr <Cmd>call VSCodeNotify('editor.action.goToReferences')<CR>

  " Bind C-/ to vscode commentary since calling from vscode produces double comments due to multiple cursors
  xnoremap <expr> <C-/> <SID>vscodeCommentary()
  nnoremap <expr> <C-/> <SID>vscodeCommentary() . '_'

  xmap gc  <Plug>VSCodeCommentary
  nmap gc  <Plug>VSCodeCommentary
  omap gc  <Plug>VSCodeCommentary
  nmap gcc <Plug>VSCodeCommentaryLine

  " With a map leader it's possible to do extra key combinations
  " like <leader>w saves the current file
  let mapleader = ","

  " Map copy/paste
  map <leader>c "+y
  map <leader>v "+p
  
  " Fast saving
  nmap <leader>w :w<cr>
  " Replace class= with className= 
  :map <leader>rc :%s/class=/className=/g<CR>
  
  " Prevent x from overriding what's in the clipboard.
  noremap x "_x
  noremap X "_x
  
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