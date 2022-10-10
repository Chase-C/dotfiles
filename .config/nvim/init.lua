-- =========
--  Aliases
-- =========

local opt = vim.opt -- global
local g   = vim.g   -- global for let options
local wo  = vim.wo  -- window local
local bo  = vim.bo  -- buffer local
local fn  = vim.fn  -- access vim functions
local cmd = vim.cmd -- vim commands
local api = vim.api -- vim APIs

-- =========
--  General
-- =========

opt.shell = '/bin/bash'

--Remap space as leader key
g.mapleader = ' '
g.maplocalleader = ' '

-- Reduce default history to 1000 commands
opt.history = 1000

-- New windows open to the right of current one
opt.splitright = true

-- Automatically read a file when it is modified from outside
opt.autoread = true

-- Case insensitive searching UNLESS /C or capital in search
opt.ignorecase = true
opt.smartcase = true

-- Set highlight on search
opt.hlsearch = true

-- Don't show line numbers
wo.number = false

-- Don't redraw while executing macros (performance increase)
opt.lazyredraw = true

-- No backups/swapfiles
opt.backup = false
opt.wb = false
opt.swapfile = false

-- Enable mouse mode
opt.mouse = 'a'

-- Enable break indent
wo.breakindent = true

-- Use spaces instead of tabs
bo.expandtab = true
opt.smarttab = true

-- 1 tab = 4 spaces
bo.shiftwidth = 4
bo.tabstop = 4

-- Save undo history
opt.undodir = '~/.cache/vimdid'
opt.undofile = true

-- Decrease update time
opt.updatetime = 250
wo.signcolumn = 'no'

-- Don't show '-- INSERT --' text in status when in insert mode
opt.showmode = false

-- Buffer switching behavior
opt.switchbuf = 'useopen,split'

-- Cursor can be positioned anywhere
opt.virtualedit = 'all'

-- Set default grep function
if fn.executable('rg') then
  opt.grepprg = 'rg --no-heading --vimgrep'
  opt.grepformat = '%f:%l:%c:%m'
end

-- Highlight on yank
cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]]

-- =========
--  Plugins
-- =========

-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

cmd [[
  augroup Packer
    autocmd!
    autocmd BufWritePost init.lua PackerCompile
  augroup end
]]

local use = require('packer').use
require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- Package manager
  use 'tpope/vim-fugitive' -- Git commands in nvim
  use 'tpope/vim-commentary' -- "gc" to comment visual regions/lines

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  -- UI to select things (files, grep results, open buffers...)
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  use 'arcticicestudio/nord-vim' -- Nord theme

  -- Add indentation guides even on blank lines
  use 'lukas-reineke/indent-blankline.nvim'

  -- Displays function signatures from completions in the command line
  use 'Shougo/echodoc.vim'

  -- Highlight, edit, and navigate code using a fast incremental parsing library
  use 'nvim-treesitter/nvim-treesitter'
  -- Additional textobjects for treesitter
  --use 'nvim-treesitter/nvim-treesitter-textobjects'

  -- Collection of configurations for built-in LSP client
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp'
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip' -- Snippets plugin
end)

-- Set colorscheme (order is important here)
opt.termguicolors = true
g.onedark_terminal_italics = 2
cmd [[colorscheme nord]]

--Map blankline
g.indent_blankline_char = '┊'
g.indent_blankline_filetype_exclude = { 'help', 'packer' }
g.indent_blankline_buftype_exclude = { 'terminal', 'nofile' }
g.indent_blankline_show_trailing_blankline_indent = false

-- ==========
--  Commands
-- ==========

-- Keymap helper
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map('n', '<leader>w', ':w<cr>')

-- Disable highlight (usually from search)
map('', '<leader><cr>', ':noh<cr>', { silent = true })

-- Ctrl+c and Ctrl+f as Esc
map('i', '<C-f>', '<Esc>')
map('v', '<C-f>', '<Esc>')
map('c', '<C-f>', '<Esc>')
map('i', '<C-c>', '<Esc>')
map('v', '<C-c>', '<Esc>')

-- Quick movement between windows
map('', '<C-j>', '<C-W>j')
map('', '<C-k>', '<C-W>k')
map('', '<C-h>', '<C-W>h')
map('', '<C-l>', '<C-W>l')

-- Quick movement in line
map('', 'H', '^', { noremap = false })
map('', 'L', '$', { noremap = false })

-- Easy directional movement in insert/visual modes
map('i', '<C-j>', '<Down>')
map('i', '<C-k>', '<Up>')
map('i', '<C-h>', '<Left>')
map('i', '<C-l>', '<Right>')

map('v', '<C-j>', '<Down>')
map('v', '<C-k>', '<Up>')
map('v', '<C-h>', '<Left>')
map('v', '<C-l>', '<Right>')

--Remap for dealing with word wrap
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Clipboard integration
if fn.executable('wl-copy') then
  map('', '<leader>y', ':w !wl-copy<cr><cr>')
end

if fn.executable('wl-paste') then
  map('', '<leader>p', ':read !wl-paste<cr><cr>')
end

-- Toggle between most recent buffers
map('n', '<leader><leader>', '<C-^>')

-- ===========
--  Statusbar
-- ===========

require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'nord',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = { },
    always_divide_middle = true,
  },
  sections = {
    lualine_a = { 'mode', 'paste' },
    lualine_b = { 'readonly', 'filename', 'modified' },
    lualine_c = { },
    lualine_x = { 'branch', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { '%3l:%-2v', '%2L' }
  },
  inactive_sections = {
    lualine_a = { },
    lualine_b = { },
    lualine_c = { 'filename' },
    lualine_x = { 'progress', '%3l:%-2v', '%2L' },
    lualine_y = { },
    lualine_z = { }
  },
  tabline = { },
  extensions = { }
}

-- ===============
--  Fuzzy Finding
-- ===============

local actions = require("telescope.actions")
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
	[ '<C-f>' ] = actions.close,
	[ '<C-c>' ] = actions.close,
	[ '<Esc>' ] = actions.close,
	[ '<C-j>' ] = actions.move_selection_next,
	[ '<C-k>' ] = actions.move_selection_previous,
      },
    },
  },
}

require('telescope').load_extension('fzf')

--Add leader shortcuts
map('n', '<leader>b', [[<cmd>lua require('telescope.builtin').buffers()<CR>]], { silent = true })
map('n', '<leader>l', [[<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>]], { silent = true })
map('n', '<leader>L', [[<cmd>lua require('telescope.builtin').live_grep{ grep_open_files=true }<CR>]], { silent = true })
map('n', '<leader>T', [[<cmd>lua require('telescope.builtin').tags()<CR>]], { silent = true })
map('n', '<leader>t', [[<cmd>lua require('telescope.builtin').tags{ only_current_buffer = true }<CR>]], { silent = true })
map('n', '<leader>f', [[<cmd>lua require('telescope.builtin').find_files()<CR>]], { silent = true })
map('n', '<leader>h', [[<cmd>lua require('telescope.builtin').help_tags()<CR>]], { silent = true })

-- =====================
--  Syntax Highlighting
-- =====================

vim.cmd[[au BufRead,BufNewFile *.wgsl	set filetype=wgsl]]

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.wgsl = {
    install_info = {
        url = "https://github.com/szebniok/tree-sitter-wgsl",
        files = {"src/parser.c"}
    },
}

-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall
require('nvim-treesitter.configs').setup {
  ensure_installed = {"wgsl"},
  highlight = {
    enable = true, -- false will disable the whole extension
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  indent = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
  },
}

-- ==============
--  LSP Settings
-- ==============

local lspconfig = require 'lspconfig'
local on_attach = function(_, bufnr)
  api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap = true, silent = true }
  api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>so', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts)
  cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
end

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Enable the following language servers
local servers = { 'clangd', 'rust_analyzer', 'tsserver' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- Set completeopt to have a better completion experience
opt.completeopt = 'menuone,noselect'

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
    if cmp.visible() then
        local entry = cmp.get_selected_entry()
	if not entry then
	  cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
	else
	  cmp.confirm()
	end
      else
        fallback()
      end
    end, {"i","s"}),
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}
