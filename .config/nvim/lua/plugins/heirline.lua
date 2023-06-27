return {
  'rebelot/heirline.nvim',
  lazy = false,
  dependencies = {
    'mfussenegger/nvim-dap',
  },
  opts = function()
    local status = require('plugins.utils.status')

    local function pattern_match(str, pattern_list)
      for _, pattern in ipairs(pattern_list) do
        if str:find(pattern) then return true end
      end
      return false
    end

    local buf_matchers = {
      filetype = function(pattern_list, bufnr) return pattern_match(vim.bo[bufnr or 0].filetype, pattern_list) end,
      buftype = function(pattern_list, bufnr) return pattern_match(vim.bo[bufnr or 0].buftype, pattern_list) end,
    }

    local function buffer_matches(patterns, bufnr)
      for kind, pattern_list in pairs(patterns) do
        if buf_matchers[kind](pattern_list, bufnr) then return true end
      end
      return false
    end

    return {
      opts = {
        disable_winbar_cb = function(args)
          return not require('utils').buffer_is_valid(args.buf)
            or buffer_matches({
              buftype = { 'terminal', 'prompt', 'nofile', 'help', 'quickfix' },
              filetype = { 'NvimTree', 'neo%-tree', 'dashboard', 'Outline', 'aerial' },
            }, args.buf)
        end,
      },
      statusline = {
        hl = { fg = status.colors.termfg, bg = status.colors.storm },
        status.component.vimode(true),
        status.component.filetype,
        status.component.git,
        status.component.git_diagnostic_separator,
        status.component.diagnostics,
        { provider = '%=' },
        status.component.cmd_info,
        { provider = '%=' },
        status.component.lsp,
        { provider = '  ' },
        status.component.treesitter,
        { provider = '  ' },
        status.component.position,
        status.component.vimode(false),
      },
      winbar = {
        init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        status.component.file_info,
        { provider = ' ' },
        {
          condition = function() return vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin) end,
          status.component.breadcrumbs,
        },
      },
      statuscolumn = {
        status.component.foldcolumn,
        status.component.numbercolumn,
        { provider = ' ' },
      },
    }
  end,
  config = function(_, opts)
    local heirline = require('heirline')
    heirline.setup(opts)
  end
}
