return {
  'nvim-lua/plenary.nvim',
  'MunifTanjim/nui.nvim',
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    'norcalli/nvim-colorizer.lua',
    lazy = false,
  },
  {
    'NMAC427/guess-indent.nvim',
    event = 'User SushiFile',
    config = function(_, opts)
      require('guess-indent').setup(opts)
      vim.cmd.lua({
	    args = { 'require(\'guess-indent\').set_from_buffer(\'auto_cmd\')' },
	    mods = { silent = true },
      })
    end
  },
  {
    'stevearc/resession.nvim',
    opts = {
      buf_filter = function(bufnr) return require('utils').buffer_is_valid(bufnr) end,
      tab_buf_filter = function(tabpage, bufnr) return vim.tbl_contains(vim.t[tabpage].bufs, bufnr) end,
    },
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      icons = { group = '', separator = '' },
      disable = { filetypes = { 'TelescopePrompt' } },
      layout = {
        align = 'center',
      },
    },
    config = function(_, opts)
      require('which-key').setup(opts)
      require('utils').which_key_register()
    end
  },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      modes = {
        char = {
          highlight = { backdrop = false },
        },
      },
    },
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'BufEnter',
    main = 'ibl',
    opts = {
      debounce = 100,
      indent = { char = "┊" },
      whitespace = { highlight = { "Whitespace", "NonText" } },
      exclude = {
        filetypes = { 'help' },
        buftypes = { 'terminal', 'nofile' },
      },
    },
  },
  {
    'mehalter/nvim-window-picker',
    version = '2.*',
    opts = {
      show_prompt = false,
      prompt_message = '',
      hint = 'floating-big-letter',
      selection_chars = 'FJDKSLA;CMRUEIWOQP',
      picker_config = {
        floating_big_letter = {
          font = 'ansi-shadow',
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
    }
  },
  {
    'numToStr/Comment.nvim',
    keys = {
      { 'gc', mode = { 'n', 'v' }, desc = 'Comment toggle linewise' },
      { 'gb', mode = { 'n', 'v' }, desc = 'Comment toggle blockwise' },
    },
    opts = function()
      local commentstring_avail, commentstring = pcall(require, 'ts_context_commentstring.integrations.comment_nvim')
      return commentstring_avail and commentstring and { pre_hook = commentstring.create_pre_hook() } or {}
    end,
  },
  {
    'akinsho/toggleterm.nvim',
    cmd = { 'ToggleTerm', 'TermExec' },
    opts = {
      shell = '/usr/bin/fish',
      size = 10,
      on_create = function()
        vim.opt.foldcolumn = '0'
        vim.opt.signcolumn = 'no'
      end,
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
    },
  },
}
