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
"set clipboard+=unnamedplus
xnoremap y "+y

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
let $SUDO_ASKPASS = '/usr/bin/ssh-askpass'
cmap w!! w !sudo -A tee 2>/dev/null >/dev/null %

if !has('nvim')
  set maxmem=8000000
  set maxmemtot=8000000
endif

if has('termguicolors')
  set termguicolors
endif

set updatetime=2000

let g:python3_host_prog = '/usr/bin/python3'

" Plugins will be downloaded under the specified directory.
call plug#begin('~/.local/share/nvim/plugged')

" Declare the list of plugins.

"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
Plug 'nvim-lualine/lualine.nvim'
" If you want to have icons in your statusline choose one of these
Plug 'nvim-tree/nvim-web-devicons'

" Themes
"Plug 'morhetz/gruvbox'
"Plug 'patstockwell/vim-monokai-tasty'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
"Plug 'drewtempelmeyer/palenight.vim'
"Plug 'ayu-theme/ayu-vim'
"Plug 'mhartington/oceanic-next'
"Plug 'rakr/vim-one'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

"let g:airline#extensions#tabline#enabled = 1
"let g:airline_powerline_fonts = 1

set background=dark

"let g:gruvbox_italic = 1
"let g:vim_monokai_tasty_italic = 1

"colorscheme gruvbox

"let g:vim_monokai_tasty_machine_tint = 1              " use `machine` color variant
"let g:vim_monokai_tasty_highlight_active_window = 1   " make the active window stand out
"colorscheme vim-monokai-tasty
"let g:airline_theme = 'monokai_tasty'

colorscheme catppuccin-mocha " catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
"let g:airline_theme = 'catppuccin'
" 2. Configure lualine using a Lua block
lua << EOF

local function unmodifiable_color()
  -- Custom colors if the current buffer is readonly or non-modifiable
  if vim.bo.readonly or not vim.bo.modifiable then
    return { fg = '#ffffff', bg = '#e06c75', gui = 'bold' }
  end
  -- Use default theme colors for other cases
  return nil
end

require('lualine').setup {
  options = {
    theme = 'catppuccin-mocha',
    component_separators = '',
    refresh = {
      statusline = 1000,
      tabline = 1000,
    }
  },
  sections = {
    lualine_a = {
      {
        'mode',
        color = unmodifiable_color
      },
    },
    lualine_c = {
      {
        'filename',
        path = 1
      }
    },
    lualine_z = {
      {
        'location',
        color = unmodifiable_color
      }
    }
  },
  tabline = {
    lualine_a = {
      {
        'buffers',
        --show_filename_only = false,  -- Shows shortened relative path when set to false
        show_modified_status = true, -- Shows indicator when the buffer is modified
        mode = 2,                    -- 0: Shows buffer name
                                     -- 1: Shows buffer index
                                     -- 2: Shows buffer name + buffer index
                                     -- 3: Shows buffer number
                                     -- 4: Shows buffer name + buffer number
        -- Automatically updates active buffer color to match color of other components
        use_mode_colors = true,
        buffers_color = {
          active = unmodifiable_color
        },
        max_length = vim.o.columns,  -- Take up the full width of the screen
        symbols = {
          modified = ' ●',           -- Text to show when the buffer is modified
          alternate_file = '#',      -- Text to show to identify the alternate file
          directory = '',           -- Text to show when the buffer is a directory
        },
      }
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
}
EOF


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
