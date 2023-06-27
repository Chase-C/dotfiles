local utils    = require('utils');
local get_icon = utils.get_icon

local M = {
  component = { },
  colors    = {
    night   = '#1a1b26',
    storm   = '#24283b',
    darkish = '#2f354b',
    termbg  = '#414868',
    termfg  = '#a9b1d6',
    white   = '#c0caf5',
    comment = '#565f89',
    magenta = '#bb9af7',
    blue    = '#7aa2f7',
    cyan    = '#7dcfff',
    cyan2   = '#2ac3de',
    green   = '#9ece6a',
    green2  = '#73daca',
    red     = '#f7768e',
    orange  = '#ff9e64',
    yellow  = '#e0af68',
  },
}

-- ============
--  Components
-- ============

function M.component.vimode(enable_text)
  local provider = function() return '  ' end
  if enable_text then
    provider = function(self)
      local mode = self.mode_text[self.mode]
      return mode and string.format(' %s ', mode) or '  '
    end
  end

  return {
    init = function(self)
      self.mode = vim.fn.mode(1)
    end,
    static = {
      mode_text = {
        n         = 'NORMAL',
        no        = 'PENDING',
        nov       = 'PENDING',
        noV       = 'PENDING',
        ['no\22'] = 'PENDING',
        niI       = 'N-INSERT',
        niR       = 'N-REPLACE',
        niV       = 'N-VIRTUAL',
        nt        = 'N-TERMINAL',
        ntT       = 'N-TERMINAL',
        v         = 'VISUAL',
        vs        = 'VISUAL(S)',
        V         = 'V-LINE',
        Vs        = 'V-LINE(S)',
        ['\22']   = 'V-BLOCK',
        ['\22s']  = 'V-BLOCK(S)',
        s         = 'SELECT',
        S         = 'S-LINE',
        ['\19']   = 'S-BLOCK',
        i         = 'INSERT',
        ic        = 'INSERT(C)',
        ix        = 'INSERT(C)',
        R         = 'REPLACE',
        Rc        = 'REPLACE(C)',
        Rx        = 'REPLACE(C)',
        Rv        = 'R-VIRTUAL',
        Rvc       = 'R-VIRTUAL(C)',
        Rvx       = 'R-VIRTUAL(C)',
        c         = 'COMMAND',
        cv        = 'VIM EX',
        r         = '...',
        rm        = 'MORE',
        ['r?']    = 'CONFIRM',
        ['!']     = 'SHELL',
        t         = 'TERMINAL',
      },
      mode_color = {
        n       = M.colors.blue,
        v       = M.colors.green,
        V       = M.colors.green,
        ['\22'] = M.colors.green,
        c       = M.colors.cyan,
        s       = M.colors.orange,
        S       = M.colors.orange,
        ['\19'] = M.colors.orange,
        i       = M.colors.magenta,
        R       = M.colors.red,
        r       = M.colors.yellow,
        ['!']   = M.colors.cyan2,
        t       = M.colors.green2,
      }
    },
    provider = provider,
    hl = function(self)
      local char  = self.mode:sub(1, 1)
      local color = self.mode_color[char]
      return { fg = M.colors.storm, bg = color or M.colors.blue, bold = true }
    end,
    update = {
      'ModeChanged',
      pattern = '*:*',
      callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
    },
  }
end

M.component.position = {
  -- %l = current line number
  -- %L = number of lines in the buffer
  -- %c = column number
  -- %P = percentage through file of displayed window
  provider = '  %l󰿟%L:%2c %p%%  ',
  hl = { bg = M.colors.darkish },
}

M.component.lsp = {
  {
    update = {
      'User',
      pattern = { 'LspProgressUpdate', 'LspRequest', 'SushiLspProgressEnd' },
      callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
    },
    provider = function()
      local spinner = utils.get_spinner('LSPLoading')
      local lsp = vim.lsp.util.get_progress_messages()[1]

      return lsp and (
        lsp and (spinner[math.floor(vim.loop.hrtime() / 12e7) % #spinner + 1])
        .. ' ' .. table.concat({
          lsp.title or '',
          lsp.message or '',
          lsp.percentage and '(' .. lsp.percentage .. '%%)' or '',
        }, ' ')
      )
    end,
  },
  { provider = ' ' },
  {
    update = { 'LspAttach', 'LspDetach', 'BufEnter' },
    provider = function(self)
      local names = { }
      for _, server in pairs(vim.lsp.get_active_clients { bufnr = self and self.bufnr or 0 }) do
        table.insert(names, server.name)
      end
      return get_icon('ActiveLSP') .. ' [' .. table.concat(names, ' ') .. ']'
    end,
  },
  condition = function(self)
    return next(vim.lsp.get_active_clients({ bufnr = self and self.bufnr or 0 })) ~= nil
  end,
}

M.component.treesitter = {
  update = { 'OptionSet', pattern = 'syntax' },
  provider = get_icon('ActiveTS') .. ' TS',
  hl = { fg = M.colors.green },
  condition = function(self)
    local parsers = require('nvim-treesitter.parsers')
    return parsers.has_parser(parsers.get_buf_lang(self.bufnr and self.bufnr or vim.api.nvim_get_current_buf()))
  end,
}

M.component.cmd_info = {
  {
    condition = function() return vim.fn.reg_recording() ~= '' end,
    provider = function()
      local register = vim.fn.reg_recording()
      if register ~= '' then register = '@' .. register end
      return get_icon('MacroRecording') .. '  ' .. register
    end,
    update = {
      'RecordingEnter',
      'RecordingLeave',
      callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
    },
    hl = { bold = true },
  },
  {
    condition = function(self)
      local lines = vim.api.nvim_buf_line_count(0)
      if lines > 50000 then return end

      local query = vim.fn.getreg('/')
      if query == '' then return end

      if query:find('@') then return end

      local search_count = vim.fn.searchcount({ recompute = 1, maxcount = -1 })
      local active = false
      if vim.v.hlsearch and vim.v.hlsearch == 1 and search_count.total > 0 then
        active = true
      end
      if not active then return end

      query = query:gsub([[^\V]], '')
      query = query:gsub([[\<]], ''):gsub([[\>]], '')

      self.query = query
      return true
    end,
    {
      provider = function(self)
        local search_ok, search = pcall(vim.fn.searchcount)
        if search_ok and type(search) == 'table' and search.total then
          return string.format(
            ' %s %s 󰄾 %s%d󰿟%s%d ',
            get_icon('Search'),
            self.query,
            search.current > search.maxcount and '>' or '',
            math.min(search.current, search.maxcount),
            search.incomplete == 2 and '>' or '',
            math.min(search.total, search.maxcount)
          )
        end
      end,
      hl = { fg = M.colors.night, bg = M.colors.magenta },
    },
  },
  condition = function() return vim.opt.cmdheight:get() == 0 end,
}

M.component.filetype = {
  hl = { bg = M.colors.darkish },
  { provider = '  ' },
  -- File Icon
  {
    provider = function(self)
      local devicons = require('nvim-web-devicons')
      local ft_icon, _ = devicons.get_icon(
        vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self and self.bufnr or 0), ':t'),
        nil,
        { default = true }
      )
      return ft_icon and ft_icon .. ' ' or ''
    end,
    hl = function(self)
      local devicons = require('nvim-web-devicons')
      local _, color = devicons.get_icon_color(
        vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self and self.bufnr or 0), ':t'),
        nil,
        { default = true }
      )
      return { fg = color }
    end,
  },
  -- Filetype
  {
    provider = function(self)
      local buffer = vim.bo[self and self.bufnr or 0]
      return string.lower(buffer.filetype)
    end
  },
  -- File read only
  {
    provider = function(self)
      local buffer = vim.bo[self and self.bufnr or 0]
      return buffer.readonly and ' ' .. get_icon('FileReadOnly') or ''
    end
  },
  { provider = '  ' },
}

M.component.git_diagnostic_separator = {
  condition = function(self)
    local bufnr = self and self.bufnr and self.bufnr or 0
    local git   = vim.b[bufnr or 0].gitsigns_head or vim.b[bufnr].gitsigns_status_dict
    local diag  = #vim.diagnostic.get(bufnr) > 0

    return git and diag
  end,
  hl = { fg = M.colors.comment },
  provider = '|',
}

M.component.git = {
  condition = function(self)
    local bufnr = self and self.bufnr and self.bufnr or 0
    return vim.b[bufnr or 0].gitsigns_head or vim.b[bufnr].gitsigns_status_dict
  end,
  { provider = '  ' },
  {
    provider = function(self)
      return get_icon('GitBranch') .. ' ' .. (vim.b[self and self.bufnr or 0].gitsigns_head or '')
    end,
    on_click = {
      name = 'heirline_branch',
      callback = function()
        vim.defer_fn(function() require('telescope.builtin').git_branches() end, 100)
      end,
    },
    update = { 'User', pattern = 'GitSignsUpdate' },
  },
  {
    condition = function(self)
      local git_status = vim.b[self and self.bufnr or 0].gitsigns_status_dict
      return git_status and (git_status.added or 0) + (git_status.removed or 0) + (git_status.changed or 0) > 0
    end,
    on_click = {
      name = 'heirline_git',
      callback = function()
        vim.defer_fn(function() require('telescope.builtin').git_status() end, 100)
      end,
    },
    update = { 'User', pattern = 'GitSignsUpdate' },
    provider = ' '
  },
  { provider = ' ' },
}

local function build_diagnostic_child(severity, icon, color)
  return {
    provider = function(self)
      local bufnr = self and self.bufnr or 0
      local count = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity[severity] })
      if count > 0 then return string.format('%s %s ', icon, count) end
    end,
    hl = { fg = color },
  }
end

M.component.diagnostics = {
  condition = function(self)
    local bufnr = self and self.bufnr or 0
    return #vim.diagnostic.get(bufnr) > 0
  end,
  on_click = {
    name = 'heirline_diagnostic',
    callback = function()
      vim.defer_fn(function() require('telescope.builtin').diagnostics() end, 100)
    end,
  },
  update = { 'DiagnosticChanged', 'BufEnter' },
  { provider = ' ' },
  build_diagnostic_child('ERROR', get_icon('DiagnosticError'), M.colors.red),
  build_diagnostic_child('WARN',  get_icon('DiagnosticWarn'),  M.colors.yellow),
  build_diagnostic_child('INFO',  get_icon('DiagnosticInfo'),  M.colors.green),
  build_diagnostic_child('HINT',  get_icon('DiagnosticHint'),  M.colors.blue),
}

M.component.file_info = {
  hl = { bg = M.colors.storm, bold = false },
  provider = function(self)
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self and self.bufnr or 0), ':t')
    local buffer   = vim.bo[self and self.bufnr or 0]
    return string.format(
      ' %s%s ',
      filename == '' and 'Empty' or filename,
      buffer.modified and get_icon('FileModified') or ''
    )
  end
}

M.component.breadcrumbs = {
  --{
  --  hl = { fg = M.colors.blue },
  --  M.component.file_info,
  --  { provider = '  ' },
  --},
  {
    hl = { bold = false },
    init = function(self)
      local separator = '  '
      local data = require('aerial').get_location(true) or { }
      local children = { }
      local start_idx = 0
      local max_depth = 6

      if max_depth and max_depth > 0 then
        start_idx = #data - max_depth
        if start_idx > 0 then
          table.insert(children, { provider = get_icon('Ellipsis') .. separator })
        end
      end

      -- create a child for each level
      for i, d in ipairs(data) do
        if i > start_idx then
          local name = string.gsub(d.name, '%%', '%%%%'):gsub('%s*->%s*', '')
          local child = {
            provider = string.format('%s %s', d.icon, name),
            on_click = {
              minwid = bit.bor(bit.lshift(d.lnum, 16), bit.lshift(d.col, 6), self.winnr),
              callback = function(_, minwid)
                local lnum  = bit.rshift(minwid, 16)
                local col   = bit.band(bit.rshift(minwid, 6), 1023)
                local winnr = bit.band(minwid, 63)
                vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { lnum, col })
              end,
              name = 'heirline_breadcrumbs',
            },
          }

          if #data > 1 and i < #data then table.insert(child, { provider = separator }) end
          table.insert(children, child)
        end
      end

      -- instantiate the new child
      self[1] = self:new(children, 1)
    end,
  }
}

local function statuscolumn_clickargs(self, minwid, clicks, button, mods)
  local args = {
    minwid = minwid,
    clicks = clicks,
    button = button,
    mods = mods,
    mousepos = vim.fn.getmousepos(),
  }
  if not self.signs then self.signs = {} end
  args.char = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
  if args.char == ' ' then args.char = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol - 1) end
  args.sign = self.signs[args.char]
  if not args.sign then -- update signs if not found on first click
    for _, sign_def in ipairs(vim.fn.sign_getdefined()) do
      if sign_def.text then self.signs[sign_def.text:gsub('%s', '')] = sign_def end
    end
    args.sign = self.signs[args.char]
  end
  vim.api.nvim_set_current_win(args.mousepos.winid)
  vim.api.nvim_win_set_cursor(0, { args.mousepos.line, 0 })
  return args
end

M.component.foldcolumn = {
  condition = function() return vim.opt.foldcolumn:get() ~= '0' end,
  provider = function()
    local ffi   = require('utils.ffi')
    local win   = vim.api.nvim_get_current_win()
    local wp    = ffi.C.find_window_by_handle(win, ffi.new('Error'))
    local width = ffi.C.compute_foldcolumn(wp, 0)
    -- get fold info of current line
    local foldinfo = width > 0 and ffi.C.fold_info(wp, vim.v.lnum) or { start = 0, level = 0, llevel = 0, lines = 0 }

    local foldopen   = get_icon('FoldOpened')
    local foldclosed = get_icon('FoldClosed')
    local foldsep    = get_icon('FoldSeparator')

    local str = ''
    if width ~= 0 then
      str = vim.v.relnum > 0 and '%#FoldColumn#' or '%#CursorLineFold#'
      if foldinfo.level == 0 then
        str = str .. (' '):rep(width)
      else
        local closed = foldinfo.lines > 0
        local first_level = foldinfo.level - width - (closed and 1 or 0) + 1
        if first_level < 1 then first_level = 1 end

        for col = 1, width do
          str = str
            .. (
              (vim.v.virtnum ~= 0 and foldsep)
              or ((closed and (col == foldinfo.level or col == width)) and foldclosed)
              or ((foldinfo.start == vim.v.lnum and first_level + col > foldinfo.llevel) and foldopen)
              or foldsep
            )
          if col == foldinfo.level then
            str = str .. (' '):rep(width - col)
            break
          end
        end
      end
    end
    return str .. ' '
  end,
  on_click = {
    name = 'fold_click',
    callback = function(...)
      local char = statuscolumn_clickargs(...).char
      if char == get_icon('FoldOpened') then
        vim.cmd('norm! zc')
      elseif char == get_icon('FoldClosed') then
        vim.cmd('norm! zo')
      end
    end,
  },
}

M.component.numbercolumn = {
  condition = function() return vim.opt.number:get() or vim.opt.relativenumber:get() end,
  provider = function()
    local lnum, rnum, virtnum = vim.v.lnum, vim.v.relnum, vim.v.virtnum
    local num, relnum = vim.opt.number:get(), vim.opt.relativenumber:get()
    local str

    if not num and not relnum then
      str = ''
    elseif virtnum ~= 0 then
      str = '%='
    else
      local cur = relnum and (rnum > 0 and rnum or (num and lnum or 0)) or lnum
      str = '%=' .. cur
    end
    return str
  end,
  hl = function()
    local breakpoints = require('dap.breakpoints')
    local curbuf      = vim.api.nvim_get_current_buf()
    local bufbrks     = breakpoints.get(curbuf)[curbuf]
    local lines       = { }

    for _, brk in ipairs(bufbrks) do
      lines[brk.line] = true
    end

    return {
      fg   = lines[vim.v.lnum] and M.colors.red or M.colors.comment,
      bold = lines[vim.v.lnum] and true         or false,
    }
  end,
}

return M
