local utils = require('utils')
local get_icon = utils.get_icon
local ui = require('utils.ui')

local maps = { i = {}, n = {}, v = {}, t = {} }

local sections = {
  a = { desc = get_icon('Action')    .. ' Action' },
  s = { desc = get_icon('Search')    .. ' Search' },
  p = { desc = get_icon('Package')   .. ' Packages' },
  l = { desc = get_icon('ActiveLSP') .. ' LSP' },
  u = { desc = get_icon('Window')    .. ' UI' },
  d = { desc = get_icon('Debugger')  .. ' Debugger' },
  --g = { desc = get_icon('Git')       .. ' Git' },
  S = { desc = get_icon('Session')   .. ' Session' },
  T = { desc = get_icon('Terminal')  .. ' Terminal' },
}

-- =====================
--  Standard Operations
-- =====================

maps.n['j'] = { 'v:count == 0 ? \'gj\' : \'j\'', expr = true, silent = true, desc = 'Move cursor down' }
maps.n['k'] = { 'v:count == 0 ? \'gk\' : \'k\'', expr = true, silent = true, desc = 'Move cursor up' }
maps.n['gx'] = { utils.system_open, desc = 'Open the file under cursor with system app' }

maps.n['H'] = { '^', noremap = false, desc = 'Move to beginning of line' }
maps.n['L'] = { '$', noremap = false, desc = 'Move to end of line' }

maps.n['<leader><cr>'] = { ':noh<cr>', silent = true, desc = 'Clear highlights' }
maps.n['<leader><leader>'] = { '<C-^>', desc = 'Switch between last two buffers' }

maps.n['<leader>b'] = { function() require('telescope.builtin').buffers() end, desc = 'Search buffers' }
maps.n['<leader>f'] = {
  function() require('telescope.builtin').live_grep { grep_open_files = true } end,
  desc = 'Search words in open files',
}

-- Exit
maps.i['<C-f>'] = { '<Esc>', desc = 'Exit insert mode' }
maps.v['<C-f>'] = { '<Esc>', desc = 'Exit visual mode' }
--maps.t['<C-f>'] = { '<C-\\><C-n>', desc = 'Exit terminal mode' }
-- Control-f should do nothing in normal mode
maps.n['<C-f>'] = { function() require('commands').flash_line() end, desc = 'Highlight the current line' }
--vim.keymap.disable('n', '<C-f>')

-- Move around in insert mode
maps.i['<C-h>'] = { '<Left>', desc = 'Move left' }
maps.i['<C-j>'] = { '<Down>', desc = 'Move down' }
maps.i['<C-k>'] = { '<Up>', desc = 'Move up' }
maps.i['<C-l>'] = { '<Right>', desc = 'Move right' }

--  Window Navigation
maps.n['<C-h>'] = { '<C-w>h', desc = 'Move to left split' }
maps.n['<C-j>'] = { '<C-w>j', desc = 'Move to below split' }
maps.n['<C-k>'] = { '<C-w>k', desc = 'Move to above split' }
maps.n['<C-l>'] = { '<C-w>l', desc = 'Move to right split' }

--  Comment/Uncomment lines
maps.n['<C-_>'] = {
  function() require('Comment.api').toggle.linewise.count(vim.v.count > 0 and vim.v.count or 1) end,
  desc = 'Toggle comment line',
}
maps.v['<C-_>'] = {
  '<esc><cmd>lua require(\'Comment.api\').toggle.linewise(vim.fn.visualmode())<cr>',
  desc = 'Toggle comment for selection',
}

-- Indent/Unindent lines in visual mode
maps.v['<S-Tab>'] = { '<gv', desc = 'Unindent line' }
maps.v['<Tab>'] = { '>gv', desc = 'Indent line' }

-- Flash keybindings
maps.n['<leader>t'] = {
  function() require('flash').treesitter({ jump = { pos = 'start' } }) end,
  desc = 'Jump to Treesitter node (start)',
}
maps.n['<leader>e'] = {
  function() require('flash').treesitter({ jump = { pos = 'end' } }) end,
  desc = 'Jump to Treesitter node (end)',
}
maps.n['<leader>r'] = {
  function() require('flash').treesitter_search({ jump = { pos = 'start' } }) end,
  desc = 'Jump to Treesitter search (start)',
}
maps.n['<leader>R'] = {
  function() require('flash').treesitter_search({ jump = { pos = 'end' } }) end,
  desc = 'Jump to Treesitter search (end)',
}

vim.keymap.set('o', 'R', function() require('flash').treesitter() end)

-- Terminal Navigation
maps.n['<C-Space>'] = { '<cmd>ToggleTerm direction=float<cr>', desc = 'ToggleTerm float' }
maps.t['<C-Space>'] = { '<cmd>ToggleTerm direction=float<cr>', desc = 'ToggleTerm float' }
maps.t['<C-h>'] = { '<cmd>wincmd h<cr>', desc = 'Terminal left window navigation' }
maps.t['<C-j>'] = { '<cmd>wincmd j<cr>', desc = 'Terminal down window navigation' }
maps.t['<C-k>'] = { '<cmd>wincmd k<cr>', desc = 'Terminal up window navigation' }
maps.t['<C-l>'] = { '<cmd>wincmd l<cr>', desc = 'Terminal right window navigation' }

-- Add LSP mode header before LSP is auto-attached
maps.n['<leader>l'] = sections.l

-- ================
--  Editor Actions
-- ================

maps.n['<leader>a'] = sections.a
maps.n['<leader>an'] = { '<cmd>enew<cr>', desc = 'New File' }
maps.n['<leader>ae'] = { '<cmd>Neotree toggle<cr>', desc = 'Toggle Explorer' }
maps.n['<leader>ao'] = { function() require('aerial').toggle() end, desc = 'Symbols outline' }
maps.n['<leader>af'] = { function() require('resession').load() end, desc = 'Load a session' }
maps.n['<leader>av'] = { '<cmd>vsplit<cr>', desc = 'Vertical Split' }
maps.n['<leader>ah'] = { '<cmd>split<cr>', desc = 'Horizontal Split' }

-- =================
--  Session Manager
-- =================

maps.n['<leader>S'] = sections.S
maps.n['<leader>Sl'] = { function() require('resession').load 'Last Session' end, desc = 'Load last session' }
maps.n['<leader>Ss'] = { function() require('resession').save() end, desc = 'Save this session' }
maps.n['<leader>Sd'] = { function() require('resession').delete() end, desc = 'Delete a session' }
maps.n['<leader>Sf'] = { function() require('resession').load() end, desc = 'Load a session' }

-- ===================
--  Plugin Management
-- ===================

maps.n['<leader>p'] = sections.p
maps.n['<leader>pi'] = { function() require('lazy').install() end, desc = 'Plugins Install' }
maps.n['<leader>ps'] = { function() require('lazy').home() end, desc = 'Plugins Status' }
maps.n['<leader>pS'] = { function() require('lazy').sync() end, desc = 'Plugins Sync' }
maps.n['<leader>pu'] = { function() require('lazy').check() end, desc = 'Plugins Check Updates' }
maps.n['<leader>pU'] = { function() require('lazy').update() end, desc = 'Plugins Update' }

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

maps.n['<leader>s'] = sections.s
maps.n['<leader>s<CR>'] = { function() require('telescope.builtin').resume() end, desc = 'Resume previous search' }
maps.n['<leader>s\''] = { function() require('telescope.builtin').marks() end, desc = 'Search marks' }
maps.n['<leader>sb'] = { function() require('telescope.builtin').buffers() end, desc = 'Search buffers' }
maps.n['<leader>sc'] =
  { function() require('telescope.builtin').grep_string() end, desc = 'Search for word under cursor' }
maps.n['<leader>sC'] = { function() require('telescope.builtin').commands() end, desc = 'Search commands' }
maps.n['<leader>sf'] = { function() require('telescope.builtin').find_files() end, desc = 'Search files' }
maps.n['<leader>sF'] = {
  function() require('telescope.builtin').find_files { hidden = true, no_ignore = true } end,
  desc = 'Search all files',
}
maps.n['<leader>sh'] = { function() require('telescope.builtin').help_tags() end, desc = 'Search help' }
maps.n['<leader>sk'] = { function() require('telescope.builtin').keymaps() end, desc = 'Search keymaps' }
maps.n['<leader>sm'] = { function() require('telescope.builtin').man_pages() end, desc = 'Search man' }
maps.n['<leader>so'] = { function() require('telescope.builtin').oldfiles() end, desc = 'Search history' }
maps.n['<leader>sr'] = { function() require('telescope.builtin').registers() end, desc = 'Search registers' }
maps.n['<leader>sT'] = { function() require('telescope.builtin').tags() end, desc = 'Search tags in current buffer' }
maps.n['<leader>st'] = {
  function() require('telescope.builtin').tags({ only_current_buffer = true }) end,
  desc = 'Search all tags'
}
maps.n['<leader>sw'] = { function() require('telescope.builtin').live_grep() end, desc = 'Search words' }
maps.n['<leader>sW'] = {
  function()
    require('telescope.builtin').live_grep {
      additional_args = function(args) return vim.list_extend(args, { '--hidden', '--no-ignore' }) end,
    }
  end,
  desc = 'Search words in all files',
}
maps.n['<leader>sO'] = {
  function() require('telescope.builtin').live_grep { grep_open_files = true } end,
  desc = 'Search words in open files',
}
maps.n['<leader>ss'] = {
  function()
    local aerial_avail, _ = pcall(require, 'aerial')
    if aerial_avail then
      require('telescope').extensions.aerial.aerial()
    else
      require('telescope.builtin').lsp_document_symbols()
    end
  end,
  desc = 'Search symbols',
}

-- ==========
--  Terminal
-- ==========

maps.n['<leader>T'] = sections.T
if vim.fn.executable('node') == 1 then
  maps.n['<leader>Tn'] = { function() utils.toggle_term_cmd('node') end, desc = 'ToggleTerm node' }
end
if vim.fn.executable('btm') == 1 then
  maps.n['<leader>Tt'] = { function() utils.toggle_term_cmd('btm') end, desc = 'ToggleTerm btm' }
end
local python = vim.fn.executable('python') == 1 and 'python' or vim.fn.executable('python3') == 1 and 'python3'
if python then
  maps.n['<leader>Tp'] = { function() utils.toggle_term_cmd(python) end, desc = 'ToggleTerm python' }
end
maps.n['<leader>Tf'] = { '<cmd>ToggleTerm direction=float<cr>', desc = 'ToggleTerm float' }

-- ==========
--  Nvim DAP
-- ==========

maps.n['<leader>d'] = sections.d
maps.n['<leader>db'] = { function() require('dap').toggle_breakpoint() end, desc = 'Toggle Breakpoint' }
maps.n['<leader>dB'] = { function() require('dap').clear_breakpoints() end, desc = 'Clear Breakpoints' }
maps.n['<leader>dc'] = { function() require('dap').continue() end, desc = 'Start' }
maps.n['<leader>dC'] = {
  function()
    vim.ui.input({ prompt = 'Condition: ' }, function(condition)
      if condition then require('dap').set_breakpoint(condition) end
    end)
  end,
  desc = 'Conditional Breakpoint (S-F9)',
}
maps.n['<leader>dp'] = { function() require('dap').pause() end, desc = 'Pause' }
maps.n['<leader>di'] = { function() require('dap').step_into() end, desc = 'Step Into' }
maps.n['<leader>do'] = { function() require('dap').step_over() end, desc = 'Step Over' }
maps.n['<leader>dO'] = { function() require('dap').step_out() end, desc = 'Step Out' }
maps.n['<leader>dq'] = { function() require('dap').close() end, desc = 'Close Session' }
maps.n['<leader>dQ'] = { function() require('dap').terminate() end, desc = 'Terminate Session' }
maps.n['<leader>dr'] = { function() require('dap').restart_frame() end, desc = 'Restart' }
maps.n['<leader>dR'] = { function() require('dap').repl.toggle() end, desc = 'Toggle REPL' }
maps.n['<leader>ds'] = { function() require('dap').run_to_cursor() end, desc = 'Run To Cursor' }

maps.n['<leader>dE'] = {
  function()
    vim.ui.input({ prompt = 'Expression: ' }, function(expr)
      if expr then require('dapui').eval(expr) end
    end)
  end,
  desc = 'Evaluate Input',
}
maps.v['<leader>dE'] = { function() require('dapui').eval() end, desc = 'Evaluate Input' }
maps.n['<leader>du'] = { function() require('dapui').toggle() end, desc = 'Toggle Debugger UI' }
maps.n['<leader>dh'] = { function() require('dap.ui.widgets').hover() end, desc = 'Debugger Hover' }

-- ==========
--  UI Stuff
-- ==========

maps.n['<leader>u'] = sections.u
maps.n['<leader>uc'] = { ui.toggle_cmp, desc = 'Toggle autocompletion' }
maps.n['<leader>uC'] = { '<cmd>ColorizerToggle<cr>', desc = 'Toggle color highlight' }
maps.n['<leader>ud'] = { ui.toggle_diagnostics, desc = 'Toggle diagnostics' }
maps.n['<leader>ui'] = { ui.set_indent, desc = 'Change indent setting' }
maps.n['<leader>us'] = { ui.toggle_spell, desc = 'Toggle spellcheck' }
maps.n['<leader>uw'] = { ui.toggle_wrap, desc = 'Toggle wrap' }
maps.n['<leader>uy'] = { ui.toggle_syntax, desc = 'Toggle syntax highlight' }

-- Use which-key to set the mappings
utils.set_mappings(maps)
