set hidden

" formatting related
filetype plugin on
filetype indent on
syntax on
set cindent
set expandtab
set shiftwidth=2
"set smarttab

set number
set relativenumber

"set mouse=a
set hlsearch
set incsearch
set nowrapscan
set ruler
" yank to clipboard by default
set clipboard+=unnamedplus

set nobackup
set nowritebackup

"set pastetoggle=<F10>
nnoremap <F5> :buffers<CR>:buffer<Space>
nnoremap gn :bn<CR>
nnoremap gN :bp<CR>
" zz is for centering the view around the cursor
nnoremap <C-d> <C-d>zz
nnoremap <C-f> <C-f>zz
nnoremap <C-u> <C-u>zz
nnoremap <C-b> <C-b>zz
nnoremap <A-S-r> :FZF<CR>
nnoremap <C-A-r> :FZF 
nnoremap n nzzzv
nnoremap N Nzzzv

" write as root using sudo
let $SUDO_ASKPASS = '/usr/libexec/seahorse/ssh-askpass'
cmap w!! w !sudo -A tee 2>/dev/null >/dev/null %

if !has('nvim')
  set maxmem=8000000
  set maxmemtot=8000000
endif

if has('termguicolors')
  set termguicolors
else
  set t_Co=256
endif

set updatetime=2000

let g:python3_host_prog = '/usr/bin/python3'

" Plugins will be downloaded under the specified directory.
call plug#begin('~/.local/share/nvim/plugged')

" Declare the list of plugins.

Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'

" Themes
"Plug 'morhetz/gruvbox'
Plug 'patstockwell/vim-monokai-tasty'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
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

"colorscheme vim-monokai-tasty
"let g:airline_theme = 'monokai_tasty'

colorscheme catppuccin-macchiato " catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
let g:airline_theme = 'catppuccin'


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

" example of fzf initialization on debian/ubuntu
if filereadable("/usr/share/doc/fzf/examples/fzf.vim")
  source /usr/share/doc/fzf/examples/fzf.vim
endif
