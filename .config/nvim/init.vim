" ===================
"  Table of Contents
" ===================
"  -> General
"  -> Plugins
"  -> Plugin Options
"  -> UI & Colors
"  -> Whitespace
"  -> Commands
"  -> Moving/Windows/Buffers

" =========
"  General
" =========

set shell=/bin/bash
map <space> <leader>

set history=1000
set splitright

" Automatically read a file when it is modified from outside
set autoread

" A buffer becomes hidden when it is abandoned
set hidden

" Ignore case when searching (unless a capital letter is in the search string)
set ignorecase
set smartcase

" Don't redraw while executing macros (performance increase)
set lazyredraw

" Allow special character matches in regexes
set magic
" Map sequence timeout in ms
set tm=500

" No backups/swapfiles
set nobackup
set nowb
set noswapfile

" Some autocompletion options
set completeopt+=preview

" Maintain undo list between restarts
set undodir=~/.cache/vimdid
set undofile

if executable('rg')
	set grepprg=rg\ --no-heading\ --vimgrep
	set grepformat=%f:%l:%c:%m
endif

" =========
"  Plugins
" =========

call plug#begin('~/.local/share/nvim/plugged')

" UI
Plug 'itchyny/lightline.vim'
Plug 'arcticicestudio/nord-vim'

" Editor enhancements
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf.vim'
Plug 'godlygeek/tabular'

" Completion/linting
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'neoclide/coc-tsserver', { 'do': 'yarn install --frozen-lockfile' }
Plug 'Shougo/echodoc.vim'

" Languages
Plug 'cespare/vim-toml'
Plug 'dag/vim-fish'
Plug 'HerringtonDarkholme/yats.vim' " Typescript
Plug 'plasticboy/vim-markdown'
Plug 'rust-lang/rust.vim'
Plug 'stephpy/vim-yaml'
Plug 'tikhomirov/vim-glsl'

call plug#end()

" ================
"  Plugin Options
" ================

" -------------------------
"  lightline configuration
" -------------------------

let g:lightline = {
    \ 'colorscheme': 'nord',
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'readonly', 'filename', 'modified' ] ],
    \   'right': [ [ 'lineposition' ],
    \              [ 'percent' ],
    \              [ 'gitbranch', 'filetype' ] ]
    \ },
    \ 'component': {
    \   'lineposition': '%3l:%-2v | %2L'
    \ },
    \ 'component_function': {
    \   'filename': 'LightlineFilename',
    \   'gitbranch': 'fugitive#head',
    \ },
    \ }

let g:lightline.separator = { 'left': '', 'right': '' }
let g:lightline.subseparator = { 'left': '', 'right': '' }

function! LightlineFilename()
  return expand('%:t') !=# '' ? @% : '[No Name]'
endfunction

" -----------------------
"  fzf.vim configuration
" -----------------------

" fzf window may take up to 80% of the screen
let g:fzf_layout = { 'down': '~80%' }

" Fuzzy-find and open files
nmap <leader>f :GFiles<cr>
nmap <leader>F :Files<cr>

" Buffer selection
map <leader>b :Buffers<cr>

" Line/Tag/Mark searching
map <leader>l :BLines<cr>
map <leader>L :Lines<cr>
map <leader>t :BTags<cr>
map <leader>T :Tags<cr>
map <leader>m :Marks<cr>

" -------------------
"  Coc configuration
" -------------------

inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h"

function s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1] =~# '\s'
endfunction

inoremap <silent><expr> <c-space> coc#refresh()
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
        
" Navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" -----------------------
"  EchoDoc configuration
" -----------------------

let g:echodoc#enable_at_startup = 1
"let g:echodoc#type = "virtual"

" ----------------------------
"  vim-markdown configuration
" ----------------------------

let g:vim_markdown_folding_disabled = 1

" =============
"  UI & Colors
" =============

if has('nvim')
    set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor
    set inccommand=nosplit
    noremap <C-q> :confirm qall<CR>
end

" deal with colors
if !has('gui_running')
  set t_Co=256
endif
if (match($TERM, "-256color") != -1) && (match($TERM, "screen-256color") == -1)
  " screen does not (yet) support truecolor
  set termguicolors
endif

" Color scheme
set background=dark
colorscheme nord
hi Normal ctermbg=NONE

" Get syntax
syntax on

" Line numbers
"set number

" Height of the command bar
set cmdheight=2

" Don't show '-- INSERT --' text in status when in insert mode
set noshowmode

" Show matching bracket/brace/paren when cursor is over one
set showmatch

" No annoying sounds/visuals
set noerrorbells
set novisualbell

" Enable mouse support
set mouse=a

" Show hidden characters
" Verbose: set listchars=nbsp:¬,eol:¶,extends:»,precedes:«,trail:•
set nolist
set listchars=nbsp:¬,extends:»,precedes:«,trail:•

" Highlight search results
set hlsearch

" ============
"  Whitespace
" ============

" Use spaces instead of tabs
set expandtab
set smarttab

" 1 tab = 4 spaces
set shiftwidth=4
set tabstop=4

" Copy indent from current line when starting new line
set autoindent

" Do some indenting based on C-style language semantics
set smartindent

" Wrap lines
set wrap

" ==========
"  Commands
" ==========

nmap <leader>w :w!<cr>

" Pressing '*' or '#' in visual searches for the current selection
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>

" Disable highlight (usually from search)
map <silent> <leader><cr> :noh<cr>

" Center search results
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz

" Ctrl+c and Ctrl+f as Esc
inoremap <C-f> <Esc>
vnoremap <C-f> <Esc>
cnoremap <C-f> <Esc>
inoremap <C-c> <Esc>
vnoremap <C-c> <Esc>

" ========================
"  Moving/Windows/Buffers
" ========================

" Up and down movement respects line wraps
map j gj
map k gk

" Quick movement between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Splits
map <leader>v :vsplit<space>
map <leader>s :split<space>

" Open new file
map <leader>e :e<space>

" Show/Select open buffers
map <leader>ls :ls<cr>

" Move to start and end of line with 'H' and 'L'
map H ^
map L $

" Ctrl-Backspace should act like a normal backspace
inoremap <C-BS> <BS>

" Use <C-h/j/k/l> for directional movement in insert/visual modes
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>

vnoremap <C-j> <Down>
vnoremap <C-k> <Up>
vnoremap <C-h> <Left>
vnoremap <C-l> <Right>

" clipboard integration
if executable('wl-copy')
    noremap <leader>y :w !wl-copy<cr><cr>
elseif executable('xsel')
endif

if executable('wl-paste')
    noremap <leader>p :read !wl-paste<cr>
elseif executable('xsel')
endif

" Toggle between most recent buffers
nnoremap <leader><leader> <c-^>

" Buffer switching behavior
set switchbuf=useopen,usetab

" Cursor can be positioned anywhere
set virtualedit=all

" ==================
"  Helper functions
" ==================

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'gv'
        call CmdLine("Ag \"" . l:pattern . "\" " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction
