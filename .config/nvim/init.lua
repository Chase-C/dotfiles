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

opt.shell = '/usr/bin/fish'

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
    autocmd TextYankPost * silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=700})
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

  -- Utilities
  use 'MunifTanjim/nui.nvim' -- UI toolkit
  use 'nvim-lua/plenary.nvim' -- Lua functions used by other plugins

  -- Greeter
  use 'goolord/alpha-nvim'

  -- Misc
  use 'tpope/vim-fugitive' -- Git commands in nvim
  use 'tpope/vim-commentary' -- 'gc' to comment visual regions/lines
  use { 'akinsho/toggleterm.nvim', tag = '*' } -- Flexible terminal
  use 'arcticicestudio/nord-vim' -- Nord theme
  use 'lukas-reineke/indent-blankline.nvim' -- Add indentation guides even on blank lines

  -- Status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  -- File system manager
  use {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v2.x',
    requires = { 
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
  }

  use { 'mehalter/nvim-window-picker', tag = 'v2.*' }
  use {
    'mrbjarksen/neo-tree-diagnostics.nvim',
    requires = 'nvim-neo-tree/neo-tree.nvim',
  }

  -- UI to select things (files, grep results, open buffers...)
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  -- 3rd party Github Copilot plugin
  use 'zbirenbaum/copilot.lua'

  -- Highlight, edit, and navigate code using a fast incremental parsing library
  use 'nvim-treesitter/nvim-treesitter'
  -- Additional textobjects for treesitter
  --use 'nvim-treesitter/nvim-treesitter-textobjects'

  -- LSP configuration
  use 'neovim/nvim-lspconfig'
  use 'onsails/lspkind.nvim'
  use 'simrat39/rust-tools.nvim'

  -- Autocompletion
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'chrisgrieser/cmp-nerdfont'
  use 'hrsh7th/nvim-cmp'

  -- Snippets
  use 'saadparwaiz1/cmp_luasnip'
  use 'rafamadriz/friendly-snippets'
  use {
      'L3MON4D3/LuaSnip',
      run = 'make install_jsregexp',
      requires = 'rafamadriz/friendly-snippets',
  }

  -- Display function signatures from completions
  use 'ray-x/lsp_signature.nvim'

  -- Debugger
  use 'mfussenegger/nvim-dap'
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

map('i', '<C-f>', '<Esc>')
map('v', '<C-f>', '<Esc>')
map('c', '<C-f>', '<Esc>')

-- Quick movement between windows
map('', '<C-j>', '<C-W>j')
map('', '<C-k>', '<C-W>k')
map('', '<C-h>', '<C-W>h')
map('', '<C-l>', '<C-W>l')

-- Quick movement in line
map('', 'H', '^', { noremap = false })
map('', 'L', '$', { noremap = false })

-- Easy directional movement in insert/visual modes
--map('i', '<C-j>', '<Down>')
--map('i', '<C-k>', '<Up>')
--map('i', '<C-h>', '<Left>')
--map('i', '<C-l>', '<Right>')

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

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'nord',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = { 'packer', 'neo-tree', 'terminal' },
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

-- =====================
--  File system manager
-- =====================

-- Remove the deprecated commands from v1.x
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

-- Icons for diagnostic errors
vim.fn.sign_define('DiagnosticSignError', { text = ' ', texthl = 'DiagnosticSignError' })
vim.fn.sign_define('DiagnosticSignWarn',  { text = ' ', texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define('DiagnosticSignInfo',  { text = ' ', texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define('DiagnosticSignHint',  { text = ' ', texthl = 'DiagnosticSignHint' })

require('neo-tree').setup({
  close_if_last_window = false,
  popup_border_style = 'rounded',
  enable_git_status = true,
  git_status_async = false,
  enable_diagnostics = true,
  open_files_do_not_replace_types = { 'terminal', 'trouble', 'qf' },
  sort_case_insensitive = false,
  sort_function = nil,
  sources = {
    'filesystem',
    'document_symbols',
    'diagnostics',
  },
  source_selector = {
    winbar = true,
    sources = {
      { source = 'filesystem', display_name = ' 󰉓  Files ' },
      { source = 'diagnostics', display_name = '   Errors ' },
    },
  },
  default_component_configs = {
    container = {
      enable_character_fade = true
    },
    indent = {
      indent_size = 2,
      padding = 1,
      -- indent guides
      with_markers = true,
      indent_marker = '│',
      last_indent_marker = '└',
      highlight = 'NeoTreeIndentMarker',
      -- expander config, needed for nesting files
      with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = '',
      expander_expanded = '',
      expander_highlight = 'NeoTreeExpander',
    },
    icon = {
      folder_closed = '',
      folder_open = '',
      folder_empty = '', 
      -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
      -- then these will never be used.
      default = '',
      highlight = 'NeoTreeFileIcon'
    },
    modified = {
      symbol = '[+]',
      highlight = 'NeoTreeModified',
    },
    name = {
      trailing_slash = false,
      use_git_status_colors = true,
      highlight = 'NeoTreeFileName',
    },
    git_status = {
      symbols = {
        -- Change type
        added     = '', -- or '✚', but this is redundant info if you use git_status_colors on the name
        modified  = '', -- or '', but this is redundant info if you use git_status_colors on the name
        deleted   = '✖',-- this can only be used in the git_status source
        renamed   = '',-- this can only be used in the git_status source
        -- Status type
        untracked = '',
        ignored   = '',
        unstaged  = '',
        staged    = '',
        conflict  = '',
      }
    },
  },
  -- A list of functions, each representing a global custom command
  -- that will be available in all sources (if not overridden in `opts[source_name].commands`)
  -- see `:h neo-tree-global-custom-commands`
  commands = { },
  window = {
    position = 'left',
    width = 40,
    mapping_options = {
      noremap = true,
      nowait = true,
    },
    mappings = {
      ['<C-Space>'] = 'toggle_node',
      ['<2-LeftMouse>'] = 'open',
      ['<CR>'] = 'open_with_window_picker',
      ['<Esc>'] = 'revert_preview',
      ['p'] = { 'toggle_preview', config = { use_float = true } },
      ['s'] = 'split_with_window_picker',
      ['v'] = 'vsplit_with_window_picker',
      ['z'] = 'close_all_nodes',
      ['Z'] = 'expand_all_nodes',
      ['a'] = { 
        'add',
        -- this command supports BASH style brace expansion ('x{a,b,c}' -> xa,xb,xc). see `:h neo-tree-file-actions` for details
        -- some commands may take optional config options, see `:h neo-tree-mappings` for details
        config = {
          show_path = 'none' -- 'none', 'relative', 'absolute'
        }
      },
      ['R'] = 'rename',
      ['r'] = 'refresh',
      ['?'] = 'show_help',
      ['<'] = 'prev_source',
      ['>'] = 'next_source',
      ['e'] = function() vim.api.nvim_exec('Neotree focus filesystem left', true) end,
      ['d'] = function() vim.api.nvim_exec('Neotree focus diagnostics left', true) end,
      ['<Space>'] = 'noop',
      ['<BS>'] = 'noop',
      ['#'] = 'noop',
      ['A'] = 'noop',
      ['c'] = 'noop',
      ['C'] = 'noop',
      ['D'] = 'noop',
      ['f'] = 'noop',
      ['l'] = 'noop',
      ['m'] = 'noop',
      ['P'] = 'noop',
      ['q'] = 'noop',
      ['S'] = 'noop',
      ['t'] = 'noop',
      ['x'] = 'noop',
      ['y'] = 'noop',
    }
  },
  nesting_rules = { },
  filesystem = {
    async_directory_scan = 'never',
    filtered_items = {
      visible = false, -- when true, they will just be displayed differently than normal items
      hide_dotfiles = true,
      hide_gitignored = true,
      hide_hidden = true, -- only works on Windows for hidden files/directories
      hide_by_name = {
        'node_modules',
      },
      hide_by_pattern = {
        '*.lock',
      },
      always_show = {
        '.gitignore',
      },
      never_show = { },
      never_show_by_pattern = { },
    },
    follow_current_file = true,
    group_empty_dirs = false,
    hijack_netrw_behavior = 'open_default',
    use_libuv_file_watcher = true,
    window = {
      mappings = {
        ['-'] = 'navigate_up',
        ['.'] = 'set_root',
        ['H'] = 'toggle_hidden',
        ['/'] = 'filter_on_submit',
        ['<c-x>'] = 'clear_filter',
        ['[g'] = 'prev_git_modified',
        [']g'] = 'next_git_modified',
      },
      fuzzy_finder_mappings = {
        ['<down>'] = 'move_cursor_down',
        ['<C-j>'] = 'move_cursor_down',
        ['<up>'] = 'move_cursor_up',
        ['<C-k>'] = 'move_cursor_up',
      },
    },
    commands = { }
  },
  diagnostics = {
    auto_preview = {
      enabled = false,
    },
    bind_to_cwd = true,
    diag_sort_function = "severity",
    follow_behavior = {
      always_focus_file = false,
      expand_followed = true,
      collapse_others = true,
    },
    follow_current_file = true,
    group_dirs_and_files = true,
    group_empty_dirs = true,
    show_unloaded = true,
    refresh = {
      delay = 250,
      event = "vim_diagnostic_changed",
      max_items = false,
    },
  },
  document_symbols = {
    follow_cursor = true,
    window = {
      mappings = {
        ['<CR>'] = 'open',
        ['<Esc>'] = function() vim.api.nvim_exec('Neotree action=close source=document_symbols', true) end,
        ['<C-f>'] = function() vim.api.nvim_exec('Neotree action=close source=document_symbols', true) end,
      },
    },
  },
  event_handlers = {
    {
      event = "neo_tree_window_after_open",
      handler = function(args)
        if args.position == "left" or args.position == "right" then
          vim.cmd("wincmd =")
        end
      end
    },
    {
      event = "neo_tree_window_after_close",
      handler = function(args)
        if args.position == "left" or args.position == "right" then
          vim.cmd("wincmd =")
        end
      end
    }
  },
})

vim.keymap.set('n', '\\', ':Neotree reveal<CR>', { noremap = true, silent = true })
--map('', '<leader>e', ':Neotree left reveal filesystem<cr>')
--map('', '<leader>d', ':Neotree left reveal diagnostics<cr>')
--map('', '<leader>s', ':Neotree float focus document_symbols<cr>')

-- ======================
--  Window Picker Config
-- ======================

require('window-picker').setup({
  show_prompt = false,
  prompt_message = '',
  hint = 'floating-big-letter',
  selection_chars = 'FJDKSLA;CMRUEIWOQP',
  picker_config = {
    floating_big_letter = {
      font = 'ansi-shadow', -- ansi-shadow |
    },
  },
  filter_rules = {
    autoselect_one = true,
    include_current_win = false,
    bo = {
      filetype = { 'NvimTree', 'neo-tree', 'notify' },
      buftype = { 'terminal' },
    },
  },
})

-- ===============
--  Fuzzy Finding
-- ===============

local actions = require('telescope.actions')
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

-- ================
--  Terminal Setup
-- ================

require('toggleterm').setup {
  open_mapping = '<C-\\>',
  shade_terminals = true,
  start_in_insert = true,
  insert_mappings = false,
  terminal_mappings = true,
  persist_size = true,
  direction = 'float',
  float_opts = {
    border = 'curved',
    winblend = 0,
    highlights = {
      border = 'Normal',
      background = 'Normal',
    },
  },
  close_on_exit = true,
  shell = '/usr/bin/fish',
}

-- =====================
--  Syntax Highlighting
-- =====================

vim.cmd[[au BufRead,BufNewFile *.wgsl	set filetype=wgsl]]

local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
parser_config.wgsl = {
  install_info = {
    url = 'https://github.com/szebniok/tree-sitter-wgsl',
    files = {'src/parser.c'}
  },
}

-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall
require('nvim-treesitter.configs').setup {
  ensure_installed = {
      'wgsl',
      'rust',
      'json',
  },
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
    enable = false,
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

local lspconfig = require('lspconfig')
local on_attach = function(_, bufnr)
  api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  local opts = { noremap = true, silent = true }

  -- Move based on item under cursor
  api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)

  -- Diagnostics
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>[', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>]', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  --api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

  -- Information
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>i', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>o', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts)

  -- Advanced actions
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)

  cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
end

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Enable the following language servers
local servers = { 'clangd', 'tsserver' }
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
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

-- ========================
--  Extra LSP Funtionality
-- ========================

local rt = require('rust-tools')
rt.setup({
  tools = {
    -- how to execute terminal commands
    -- options right now: termopen / quickfix
    executor = require('rust-tools.executors').termopen,

    -- automatically call RustReloadWorkspace when writing to a Cargo.toml file.
    reload_workspace_from_cargo_toml = true,

    inlay_hints = {
      auto = true,
      only_current_line = false,
      show_parameter_hints = true,

      -- prefix for parameter hints
      parameter_hints_prefix = ' ',

      -- prefix for all the other hints (type, chaining)
      other_hints_prefix = '󰧂 ',
    },

    -- options same as lsp hover / vim.lsp.util.open_floating_preview()
    hover_actions = {
      border = 'none',
      max_width = nil,
      max_height = nil,
      auto_focus = true,
    },
  },
  server = {
    on_attach = function(_, bufnr)
      -- Setup base LSP keybindings
      on_attach(_, bufnr)

      -- Hover actions
      vim.keymap.set('n', '<C-space>', rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set('n', '<Leader>a', rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  }, -- rust-analyzer options

  -- debugging stuff
  dap = {
    adapter = {
      type = 'executable',
      command = 'lldb-vscode',
      name = 'rt_lldb',
    },
  },
})

-- =================
--  Completion Menu
-- =================

local cmp = require('cmp')
local cmp_buffer = require('cmp_buffer')
local lspkind = require('lspkind')
local luasnip = require('luasnip')

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
    ['<C-e>'] = cmp.mapping(function(fallback)
      cmp.close()
      fallback()
    end, {'i','s'}),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        if cmp.get_active_entry() then
          cmp.select_next_item()
        else
          cmp.select_next_item({ count = 0 })
        end
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
      
    end, {'i','s'}),
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
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    {
      name = 'buffer',
      option = {
        -- Get completions from visible buffers, not just the current one
        get_bufnrs = function()
          local bufs = {}
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            bufs[vim.api.nvim_win_get_buf(win)] = true
          end
          return vim.tbl_keys(bufs)
        end
      },
    },
    { name = 'path' },
    { name = 'nerdfont' },
  }),
  sorting = {
    comparators = {
      -- Sort completion results by distance from cursor
      function(...) return cmp_buffer:compare_locality(...) end,
    }
  },
  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol_text",
      maxwidth = 48,
      ellipsis_char = '...',
      menu = ({
        nvim_lsp = "[LSP]",
        luasnip = "[Snippet]",
        buffer = "[Buffer]",
        path = "[Path]",
        nerdfont = "[Icon]",
      })
    }),
  },
  expirimental = {
    ghost_text = false -- This conflicts with Copilot's preview
  },
}

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  },
  sorting = {
    comparators = {
      -- Sort completion results by distance from cursor
      function(...) return cmp_buffer:compare_locality(...) end,
    }
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- ===============
--  Load Snippets
-- ===============

require('luasnip.loaders.from_vscode').lazy_load()

-- ===============
--  LSP Signature
-- ===============

local lsp_signature = require('lsp_signature')
lsp_signature.setup({
  bind = true,
  handler_opts = {
    border = 'none',
  },
  hint_prefix = ' ',
  max_height = 12,
  max_width = 80,
  zindex = 200,
})

-- ==================
--  Copilot Settings
-- ==================

require('copilot').setup({
  panel = {
    enabled = false,
  },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    debounce = 250,
    keymap = {
      accept = '<C-g>',
      accept_word = false,
      accept_line = false,
      next = '<C-r>',
      prev = false,
      dismiss = '<C-e>',
    },
  },
  filetypes = {
    yaml = false,
    markdown = false,
    help = false,
    gitcommit = false,
    gitrebase = false,
    hgcommit = false,
    svn = false,
    cvs = false,
    ['.'] = false,
  },
  copilot_node_command = 'node', -- Node.js version must be > 16.x
  server_opts_overrides = {},
})
