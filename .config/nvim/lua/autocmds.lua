local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local utils = require('utils')
local sushievent = utils.event

autocmd({ 'VimEnter', 'FileType', 'BufEnter', 'WinEnter' }, {
  desc = 'URL Highlighting',
  group = augroup('highlighturl', { clear = true }),
  callback = function() utils.set_url_match() end,
})

local view_group = augroup('auto_view', { clear = true })
autocmd({ 'BufWinLeave', 'BufWritePost', 'WinLeave' }, {
  desc = 'Save view with mkview for real files',
  group = view_group,
  callback = function(event)
    if vim.b[event.buf].view_activated then vim.cmd.mkview { mods = { emsg_silent = true } } end
  end,
})

autocmd('BufWinEnter', {
  desc = 'Try to load file view if available and enable view saving for real files',
  group = view_group,
  callback = function(event)
    if not vim.b[event.buf].view_activated then
      local filetype = vim.api.nvim_get_option_value('filetype', { buf = event.buf })
      local buftype = vim.api.nvim_get_option_value('buftype', { buf = event.buf })
      local ignore_filetypes = { 'gitcommit', 'gitrebase', 'svg', 'hgcommit' }
      if buftype == '' and filetype and filetype ~= '' and not vim.tbl_contains(ignore_filetypes, filetype) then
        vim.b[event.buf].view_activated = true
        vim.cmd.loadview { mods = { emsg_silent = true } }
      end
    end
  end,
})

autocmd('BufWinEnter', {
  desc = 'Make q close help, man, quickfix, dap floats',
  group = augroup('q_close_windows', { clear = true }),
  callback = function(event)
    local filetype = vim.api.nvim_get_option_value('filetype', { buf = event.buf })
    local buftype = vim.api.nvim_get_option_value('buftype', { buf = event.buf })
    if buftype == 'nofile' or filetype == 'help' then
      vim.keymap.set('n', 'q', '<cmd>close<cr>', {
        desc = 'Close window',
        buffer = event.buf,
        silent = true,
        nowait = true,
      })
    end
  end,
})

autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  group = augroup('highlightyank', { clear = true }),
  pattern = '*',
  callback = function() vim.highlight.on_yank() end,
})

autocmd('FileType', {
  desc = 'Unlist quickfist buffers',
  group = augroup('unlist_quickfist', { clear = true }),
  pattern = 'qf',
  callback = function() vim.opt_local.buflisted = false end,
})

autocmd('FileType', {
  desc = 'Set tab spaces for certain filetypes',
  group = augroup('tab_spaces', { clear = true }),
  pattern = 'typescript,javascript,json,lua',
  callback = function()
    vim.api.nvim_buf_set_option(0, 'shiftwidth', 2)
    vim.api.nvim_buf_set_option(0, 'tabstop', 2)
  end,
})

autocmd('BufEnter', {
  desc = 'Quit Neovim if more than one window is open and only sidebar windows are list',
  group = augroup('auto_quit', { clear = true }),
  callback = function()
    local wins = vim.api.nvim_tabpage_list_wins(0)
    -- Both neo-tree and aerial will auto-quit if there is only a single window left
    if #wins <= 1 then return end
    local sidebar_fts = { aerial = true, ['neo-tree'] = true }
    for _, winid in ipairs(wins) do
      if vim.api.nvim_win_is_valid(winid) then
        local bufnr = vim.api.nvim_win_get_buf(winid)
        local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
        -- If any visible windows are not sidebars, early return
        if not sidebar_fts[filetype] then
          return
        -- If the visible window is a sidebar
        else
          -- only count filetypes once, so remove a found sidebar from the detection
          sidebar_fts[filetype] = nil
        end
      end
    end
    if #vim.api.nvim_list_tabpages() > 1 then
      vim.cmd.tabclose()
    else
      vim.cmd.qall()
    end
  end,
})

-- ===========
--  Alpha Vim
-- ===========

autocmd({ 'User', 'BufEnter' }, {
  desc = 'Disable status and tablines for alpha',
  group = augroup('alpha_settings', { clear = true }),
  callback = function(event)
    if
      (
        (event.event == 'User' and event.file == 'AlphaReady')
        or (event.event == 'BufEnter' and vim.api.nvim_get_option_value('filetype', { buf = event.buf }) == 'alpha')
      ) and not vim.g.before_alpha
    then
      vim.g.before_alpha = { showtabline = vim.opt.showtabline:get(), laststatus = vim.opt.laststatus:get() }
      vim.opt.showtabline, vim.opt.laststatus = 0, 0
    elseif
      vim.g.before_alpha
      and event.event == 'BufEnter'
      and vim.api.nvim_get_option_value('buftype', { buf = event.buf }) ~= 'nofile'
    then
      vim.opt.laststatus, vim.opt.showtabline = vim.g.before_alpha.laststatus, vim.g.before_alpha.showtabline
      vim.g.before_alpha = nil
    end
  end,
})

autocmd('VimEnter', {
  desc = 'Start Alpha when vim is opened with no arguments',
  group = augroup('alpha_autostart', { clear = true }),
  callback = function()
    local should_skip = false
    if vim.fn.argc() > 0 or vim.fn.line2byte(vim.fn.line '$') ~= -1 or not vim.o.modifiable then
      should_skip = true
    else
      for _, arg in pairs(vim.v.argv) do
        if arg == '-b' or arg == '-c' or vim.startswith(arg, '+') or arg == '-S' then
          should_skip = true
          break
        end
      end
    end
    if not should_skip then require('alpha').start(true, require('alpha').default_config) end
  end,
})

-- ===========
--  Resession
-- ===========

autocmd('VimLeavePre', {
  desc = 'Save session on close',
  group = augroup('resession_auto_save', { clear = true }),
  callback = function(event)
    local filetype = vim.api.nvim_get_option_value('filetype', { buf = event.buf })
    if not vim.tbl_contains({ 'gitcommit', 'gitrebase' }, filetype) then
      local save = require('resession').save
      save 'Last Session'
      save(vim.fn.getcwd(), { dir = 'dirsession', notify = false })
    end
  end,
})

-- =========
--  NeoTree
-- =========

autocmd('BufEnter', {
  desc = 'Open Neo-Tree on startup with directory',
  group = augroup('neotree_start', { clear = true }),
  callback = function()
    if package.loaded['neo-tree'] then
      vim.api.nvim_del_augroup_by_name('neotree_start')
    else
      local stats = vim.loop.fs_stat(vim.api.nvim_buf_get_name(0))
      if stats and stats.type == 'directory' then
        vim.api.nvim_del_augroup_by_name('neotree_start')
        require('neo-tree')
      end
    end
  end,
})

-- ========
--  Others
-- ========

autocmd({ 'BufReadPost', 'BufNewFile' }, {
  desc = 'Neovim user events for file detection (SushiFile and SushiGitFile)',
  group = augroup('file_user_events', { clear = true }),
  callback = function(args)
    if not (vim.fn.expand '%' == '' or vim.api.nvim_get_option_value('buftype', { buf = args.buf }) == 'nofile') then
      sushievent('File')
      if utils.cmd('git -C \'' .. vim.fn.expand '%:p:h' .. '\' rev-parse', false) then sushievent('GitFile') end
    end
  end,
})
