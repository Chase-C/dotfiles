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

" Height of the command bar
set cmdheight=2

" Don't show '-- INSERT --' text in status when in insert mode
set noshowmode

" A buffer becomes hidden when it is abandoned
set hidden

" Ignore case when searching (unless a capital letter is in the search string)
set ignorecase
set smartcase

" Highlight search results
set hlsearch

" Don't redraw while executing macros (performance increase)
set lazyredraw

" Allow special character matches in regexes
set magic

" Show matching bracket/brace/paren when cursor is over one
set showmatch

" No annoying sounds/visuals
set noerrorbells
set novisualbell

" Map sequence timeout in ms
set tm=500

" Add small left margin
set foldcolumn=1

" No backups/swapfiles
set nobackup
set nowb
set noswapfile

" Maintain undo list between restarts
set undodir=~/.cache/vimdid
set undofile

" =========
"  Plugins
" =========

call plug#begin('~/.vim/plugged')

" GUI
Plug 'itchyny/lightline.vim'

" Editor enhancements

" Completion/linting

call plug#end()

" ================
"  Plugin Options
" ================

" lightline config
let g:lightline = {
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'readonly', 'filename', 'modified' ] ]
    \ },
    \ 'component_function': {
    \   'filename': 'LightlineFilename',
    \ },
    \ }
    "\ 'component': {
    "\   'helloworld': 'Hello, world!'
    "\ },
function! LightlineFilename()
  return expand('%:t') !=# '' ? @% : '[No Name]'
endfunction

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
"colorscheme base16-gruvbox-dark-hard
hi Normal ctermbg=NONE

" Get syntax
syntax on

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
map <leader>b :buffers<cr>:b<space>

" Move to start and end of line with 'H' and 'L'
map H ^
map L $

" X clipboard integration
noremap <leader>p :read !xsel --clipboard --output<cr>
noremap <leader>y :w !xsel -ib<cr><cr>

" Toggle between most recent buffers
nnoremap <leader><leader> <c-^>

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
