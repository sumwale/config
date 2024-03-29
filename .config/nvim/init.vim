set hidden

" formatting related
filetype plugin on
filetype indent on
syntax on
set cindent
set expandtab
set shiftwidth=2
"set smarttab

"set mouse=a
set hlsearch
set incsearch
set nowrapscan
set ruler
" yank to clipboard by default
set clipboard+=unnamedplus

set nobackup
set nowritebackup

set pastetoggle=<F10>
nnoremap <F5> :buffers<CR>:buffer<Space>
nnoremap gn :bn<CR>
nnoremap gN :bp<CR>

" write as root using sudo
cmap w!! w !sudo tee > /dev/null %

if !has('nvim')
  set maxmem=8000000
  set maxmemtot=8000000
endif

if has('termguicolors')
  set termguicolors
else
  set t_Co=256
endif

set updatetime=750

" Plugins will be downloaded under the specified directory.
call plug#begin('~/.local/share/nvim/plugged')

" Declare the list of plugins.

Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'

" Themes
Plug 'morhetz/gruvbox'
Plug 'patstockwell/vim-monokai-tasty'
"Plug 'drewtempelmeyer/palenight.vim'
"Plug 'ayu-theme/ayu-vim'
"Plug 'mhartington/oceanic-next'
"Plug 'rakr/vim-one'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

set background=dark

"let g:gruvbox_italic = 1
"let g:vim_monokai_tasty_italic = 1

"colorscheme gruvbox

colorscheme vim-monokai-tasty
let g:airline_theme='monokai_tasty'

" Protect large files from sourcing and other overhead.
" Files become read only
if !exists('my_auto_commands_loaded')
  let my_auto_commands_loaded = 1
  " Large files are > 1G
  " Set options:
  " eventignore+=FileType (no syntax highlighting etc
  " assumes FileType always on)
  " noswapfile (save copy of file)
  " bufhidden=unload (save memory when other file is viewed)
  " buftype=nowritefile (is read-only)
  " undolevels=-1 (no undo possible)
  let g:LargeFile = 1024 * 1024 * 1024
  " disable syntax highlight for files > 100M
  let g:MediumFile = 100 * 1024 * 1024
  augroup LargeFile
    autocmd BufReadPre * let f=expand("<afile>") | if getfsize(f) > g:LargeFile | set eventignore+=FileType | setlocal noswapfile nohlsearch bufhidden=unload undolevels=-1 | elseif getfsize(f) > g:MediumFile | set eventignore+=FileType | setlocal nohlsearch | else | set eventignore-=FileType | endif
  augroup END
endif
