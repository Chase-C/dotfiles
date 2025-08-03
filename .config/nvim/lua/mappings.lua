local utils = require('utils')
local get_icon = utils.get_icon
local ui = require('utils.ui')

local sections = {
  c = get_icon('Robot')     .. '  Copilot',
  s = get_icon('Search')    .. '  Search',
  p = get_icon('Package')   .. '  Packages',
  l = get_icon('ActiveLSP') .. '  LSP',
  u = get_icon('Window')    .. '  UI',
  d = get_icon('Debugger')  .. '  Debugger',
  S = get_icon('Session')   .. '  Session',
}

-- =====================
--  Standard Operations
-- =====================

local std_map = {
  -- New file
  { '<leader>n', '<cmd>enew<cr>', desc = 'New File' },
  -- Movement
  { 'j',  'v:count == 0 ? \'gj\' : \'j\'', desc = 'Move cursor down', expr = true, silent = true },
  { 'k',  'v:count == 0 ? \'gk\' : \'k\'', desc = 'Move cursor up',   expr = true, silent = true },
  { 'gx', utils.system_open,               desc = 'Open the file under cursor with system app' },
  { 'H',  '^',                             desc = 'Move to beginning of line', noremap = false },
  { 'L',  '$',                             desc = 'Move to end of line',       noremap = false },
  { '<leader><cr>', ':noh<cr>',            desc = 'Clear highlights', silent = true },
  { '<leader><leader>', '<C-^>',           desc = 'Switch between last two buffers' },
  -- Buffer/file search
  { '<leader>b', function() require('telescope.builtin').buffers() end,                            desc = 'Search buffers' },
  { '<leader>f', function() require('telescope.builtin').live_grep { grep_open_files = true } end, desc = 'Search words in open files' },
  -- Escape mappings
  { '<C-f>', '<Esc>',                                         desc = 'Exit insert mode',           mode = 'i' },
  { '<C-f>', '<Esc>',                                         desc = 'Exit visual mode',           mode = 'v' },
  { '<C-f>', function() require('commands').flash_line() end, desc = 'Highlight the current line', mode = 'n' },
  -- Move around in insert mode
  { '<C-h>', '<Left>',  desc = 'Move left',  mode = 'i' },
  { '<C-j>', '<Down>',  desc = 'Move down',  mode = 'i' },
  { '<C-k>', '<Up>',    desc = 'Move up',    mode = 'i' },
  { '<C-l>', '<Right>', desc = 'Move right', mode = 'i' },
  --  Window Navigation
  { '<C-h>', '<C-w>h', desc = 'Move to left split',  mode = 'n' },
  { '<C-j>', '<C-w>j', desc = 'Move to below split', mode = 'n' },
  { '<C-k>', '<C-w>k', desc = 'Move to above split', mode = 'n' },
  { '<C-l>', '<C-w>l', desc = 'Move to right split', mode = 'n' },
  -- Open/Close floating terminal
  { '<C-Space>', '<cmd>ToggleTerm direction=float<cr>', desc = 'ToggleTerm float' },
  { '<C-Space>', '<cmd>ToggleTerm direction=float<cr>', desc = 'ToggleTerm float', mode = 't' },
  --  Comment/Uncomment lines
  {
    '<C-/>',
    function() require('Comment.api').toggle.linewise.count(vim.v.count > 0 and vim.v.count or 1) end,
    desc = 'Toggle comment line',
    mode = 'n',
  },
  {
    '<C-/>',
    --'<esc><cmd>lua require(\'Comment.api\').toggle.linewise(vim.fn.visualmode())<cr>',
    function() require('Comment.api').toggle.linewise(vim.fn.visualmode()) end,
    desc = 'Toggle comment for selection',
    mode = 'v',
  },
  -- Indent/Unindent lines in visual mode
  { '<S-Tab>', '<gv', desc = 'Unindent line', mode = 'v' },
  { '<Tab>',   '>gv', desc = 'Indent line',   mode = 'v' },
  -- Flash keybindings
  { '<leader>t', function() require('flash').treesitter({ jump = { pos = 'start' } }) end, desc = 'Jump to Treesitter node (start)' },
  { '<leader>e', function() require('flash').treesitter({ jump = { pos = 'end' } }) end,   desc = 'Jump to Treesitter node (end)' },
  {
    '<leader>r',
    function() require('flash').treesitter_search({ jump = { pos = 'start' } }) end,
    desc = 'Jump to Treesitter search (start)',
  },
  {
    '<leader>R',
    function() require('flash').treesitter_search({ jump = { pos = 'end' } }) end,
    desc = 'Jump to Treesitter search (end)',
  },
  -- Add LSP mode header before LSP is auto-attached
  { '<leader>l', desc = sections.l },
}

utils.set_mappings(std_map)

-- =================
--  Session Manager
-- =================

local session_map = {
  { '<leader>S',                                                           desc = sections.S },
  { '<leader>Sl', function() require('resession').load 'Last Session' end, desc = 'Load last session' },
  { '<leader>Ss', function() require('resession').save() end,              desc = 'Save this session' },
  { '<leader>Sd', function() require('resession').delete() end,            desc = 'Delete a session' },
  { '<leader>Sf', function() require('resession').load() end,              desc = 'Load a session' },
}

utils.set_mappings(session_map)

-- ===================
--  Plugin Management
-- ===================

local plug_map = {
  { '<leader>p',                                            desc = sections.p },
  { '<leader>pi', function() require('lazy').install() end, desc = 'Plugins Install' },
  { '<leader>ps', function() require('lazy').home() end,    desc = 'Plugins Status' },
  { '<leader>pS', function() require('lazy').sync() end,    desc = 'Plugins Sync' },
  { '<leader>pu', function() require('lazy').check() end,   desc = 'Plugins Check Updates' },
  { '<leader>pU', function() require('lazy').update() end,  desc = 'Plugins Update' },
  { '<leader>pl', function() require('lazy').plugins() end, desc = 'Plugins List' },
  { '<leader>pc', function() require('lazy').clean() end,   desc = 'Plugins Clean' },
  { '<leader>pr', function() require('lazy').reload() end,  desc = 'Plugins Reload' },
}

utils.set_mappings(plug_map)

-- ==========
--  GitSigns
-- ==========

--maps.n['<leader>g'] = sections.g
--maps.n['<leader>gl'] = { function() require('gitsigns').blame_line() end, desc = 'View Git blame' }
--maps.n['<leader>gL'] = { function() require('gitsigns').blame_line { full = true } end, desc = 'View full Git blame' }
--maps.n['<leader>gp'] = { function() require('gitsigns').preview_hunk() end, desc = 'Preview Git hunk' }
--maps.n['<leader>gh'] = { function() require('gitsigns').reset_hunk() end, desc = 'Reset Git hunk' }
--maps.n['<leader>gr'] = { function() require('gitsigns').reset_buffer() end, desc = 'Reset Git buffer' }
--maps.n['<leader>gs'] = { function() require('gitsigns').stage_hunk() end, desc = 'Stage Git hunk' }
--maps.n['<leader>gS'] = { function() require('gitsigns').stage_buffer() end, desc = 'Stage Git buffer' }
--maps.n['<leader>gu'] = { function() require('gitsigns').undo_stage_hunk() end, desc = 'Unstage Git hunk' }
--maps.n['<leader>gd'] = { function() require('gitsigns').diffthis() end, desc = 'View Git diff' }
--maps.n['<leader>gb'] = { function() require('telescope.builtin').git_branches() end, desc = 'Git branches' }
--maps.n['<leader>gc'] = { function() require('telescope.builtin').git_commits() end, desc = 'Git commits' }
--maps.n['<leader>gt'] = { function() require('telescope.builtin').git_status() end, desc = 'Git status' }

-- ===========
--  Telescope
-- ===========

local tele_map = {
  { '<leader>s',                                                             desc = sections.s },
  { '<leader>sb', function() require('telescope.builtin').buffers() end,     desc = 'Search buffers' },
  { '<leader>sc', function() require('telescope.builtin').grep_string() end, desc = 'Search for word under cursor' },
  { '<leader>sC', function() require('telescope.builtin').commands() end,    desc = 'Search commands' },
  { '<leader>sf', function() require('telescope.builtin').find_files() end,  desc = 'Search files' },
  { '<leader>sh', function() require('telescope.builtin').help_tags() end,   desc = 'Search help' },
  { '<leader>sk', function() require('telescope.builtin').keymaps() end,     desc = 'Search keymaps' },
  { '<leader>sm', function() require('telescope.builtin').man_pages() end,   desc = 'Search man' },
  { '<leader>so', function() require('telescope.builtin').oldfiles() end,    desc = 'Search history' },
  { '<leader>sr', function() require('telescope.builtin').registers() end,   desc = 'Search registers' },
  { '<leader>sw', function() require('telescope.builtin').live_grep() end,   desc = 'Search words' },
  {
    '<leader>sW',
    function()
      require('telescope.builtin').live_grep {
        additional_args = function(args)
          return vim.list_extend(args, { '--hidden', '--no-ignore' })
        end
      }
    end,
    desc = 'Search words in all files',
  },
  {
    '<leader>sO',
    function()
      require('telescope.builtin').live_grep { grep_open_files = true }
    end,
    desc = 'Search words in open files',
  },
  {
    '<leader>ss',
    function()
      local aerial_avail, _ = pcall(require, 'aerial')
      if aerial_avail then
        require('telescope').extensions.aerial.aerial()
      else
        require('telescope.builtin').lsp_document_symbols()
      end
    end,
    desc = 'Search symbols',
  },
  --{ '<leader>sT', function() require('telescope.builtin').tags() end,        desc = 'Search tags in current buffer' },
  --{ '<leader>st', function() require('telescope.builtin').tags({ only_current_buffer = true }) end, desc = 'Search all tags' },
}

utils.set_mappings(tele_map)

-- ==========
--  Terminal
-- ==========

local term_map = {
  { '<leader>T',                                                desc = sections.T },
  --{ '<leader>Tn', function() utils.toggle_term_cmd('node') end, desc = 'Floaterm node',   cond = vim.fn.executable('node') == 1 },
  --{ '<leader>Tt', function() utils.toggle_term_cmd('btm') end,  desc = 'Floaterm btm',    cond = vim.fn.executable('btm') == 1 },
  --{ '<leader>Tp', function() utils.toggle_term_cmd(python) end, desc = 'Floaterm python', cond = python },
  { '<leader>Tf', '<cmd>FloatermToggle<cr>',                    desc = 'Floaterm Toggle' },
  -- Terminal Navigation
  { '<C-Space>',  '<cmd>FloatermToggle<cr>',                    desc = 'Floaterm Toggle' },
  { '<C-Space>',  '<cmd>FloatermToggle<cr>',                    desc = 'Floaterm Toggle', mode = 't' },
  --{ '<C-h>',      '<cmd>wincmd h<cr>',                          desc = 'Terminal left window navigation',  mode = 't' },
  --{ '<C-j>',      '<cmd>wincmd j<cr>',                          desc = 'Terminal down window navigation',  mode = 't' },
  --{ '<C-k>',      '<cmd>wincmd k<cr>',                          desc = 'Terminal up window navigation',    mode = 't' },
  --{ '<C-l>',      '<cmd>wincmd l<cr>',                          desc = 'Terminal right window navigation', mode = 't' },
}

utils.set_mappings(term_map)

-- ==========
--  Nvim DAP
-- ==========

local dap_map = {
  { '<leader>d',                                                     desc = sections.d },
  { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Toggle Breakpoint' },
  { '<leader>dB', function() require('dap').clear_breakpoints() end, desc = 'Clear Breakpoints' },
  { '<leader>dc', function() require('dap').continue() end,          desc = 'Start' },
  { '<leader>dp', function() require('dap').pause() end,             desc = 'Pause' },
  { '<leader>di', function() require('dap').step_into() end,         desc = 'Step Into' },
  { '<leader>do', function() require('dap').step_over() end,         desc = 'Step Over' },
  { '<leader>dO', function() require('dap').step_out() end,          desc = 'Step Out' },
  { '<leader>dq', function() require('dap').close() end,             desc = 'Close Session' },
  { '<leader>dQ', function() require('dap').terminate() end,         desc = 'Terminate Session' },
  { '<leader>dr', function() require('dap').restart_frame() end,     desc = 'Restart' },
  { '<leader>dR', function() require('dap').repl.toggle() end,       desc = 'Toggle REPL' },
  { '<leader>ds', function() require('dap').run_to_cursor() end,     desc = 'Run To Cursor' },
  { '<leader>du', function() require('dapui').toggle() end,          desc = 'Toggle Debugger UI' },
  { '<leader>dh', function() require('dap.ui.widgets').hover() end,  desc = 'Debugger Hover' },
  { '<leader>dE', function() require('dapui').eval() end,            desc = 'Evaluate Input', mode = 'v' },
  {
    '<leader>dC',
    function()
      vim.ui.input({ prompt = 'Condition: ' }, function(condition)
        if condition then require('dap').set_breakpoint(condition) end
      end)
    end,
    desc = 'Conditional Breakpoint (S-F9)',
  },
  {
    '<leader>dE',
    function()
      vim.ui.input({ prompt = 'Expression: ' }, function(expr)
        if expr then require('dapui').eval(expr) end
      end)
    end,
    desc = 'Evaluate Input',
  },
}

utils.set_mappings(dap_map)

-- ==========
--  UI Stuff
-- ==========

local ui_map = {
  { '<leader>u', desc = sections.u },
  { '<leader>ue', '<cmd>Neotree toggle<cr>',                  desc = 'Toggle Explorer' },
  { '<leader>us', function() require('aerial').toggle() end,  desc = 'Symbols outline' },
  { '<leader>uv', '<cmd>vsplit<cr>',                          desc = 'Vertical Split' },
  { '<leader>uh', '<cmd>split<cr>',                           desc = 'Horizontal Split' },
  -- Deep options that are rarely changed
  { '<leader>uo',                         desc = 'Options' },
  { '<leader>uoc', ui.toggle_cmp,         desc = 'Toggle autocompletion' },
  { '<leader>uoC', ui.toggle_cmp,         desc = 'Toggle color highlight' },
  { '<leader>uod', ui.toggle_diagnostics, desc = 'Toggle diagnostics' },
  { '<leader>uoi', ui.set_indent,         desc = 'Change indent setting' },
  { '<leader>uos', ui.toggle_spell,       desc = 'Toggle spellcheck' },
  { '<leader>uow', ui.toggle_wrap,        desc = 'Toggle wrap' },
  { '<leader>uoy', ui.toggle_syntax,      desc = 'Toggle syntax highlight' },
}

utils.set_mappings(ui_map)

-- =========
--  Copilot
-- =========

local copilot_map = {
  { '<leader>c',                                   desc = sections.c },
  { '<leader>ca', '<cmd>CodeCompanionActions<cr>', desc = 'Open Copilot actions' },
  -- Visual mode mappings
  { '<leader>c',                                    desc = sections.c,                          mode = 'v' },
  { '<leader>ca', '<cmd>CodeCompanionActions<cr>',  desc = 'Open Copilot actions',              mode = 'v' },
  { '<leader>cb', '<cmd>CodeCompanionChat Add<cr>', desc = 'Add selected text to Copilot chat', mode = 'v' },
  -- Toggle chat window
  { '<C-g>', '<cmd>CodeCompanionChat Toggle<cr>', desc = 'Toggle Copilot chat window' },
}

utils.set_mappings(copilot_map)
