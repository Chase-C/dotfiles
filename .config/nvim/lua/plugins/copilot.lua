return {
  {
    'zbirenbaum/copilot.lua',
    event = 'BufReadPre',
    opts = {
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        debounce = 100,
        trigger_on_accept = true,
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
        help = false,
        gitcommit = false,
        gitrebase = false,
        hgcommit = false,
        svn = false,
        cvs = false,
        ['.'] = false,
      },
      copilot_node_command = 'node',
      server_opts_overrides = { },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    event = 'User SushiFile',
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      strategies = {
        chat = {
          adapter = "copilot",
        },
        inline = {
          adapter = "copilot",
        },
        cmd = {
          adapter = "copilot",
        },
      },
      display = {
        chat = {
          window = {
            layout = 'float',
            border = 'rounded',
            title = ' Copilot Chat ',
            width = 0.60,
          },
        },
      },
      opts = {
        -- Set debug logging
        log_level = "DEBUG",
      },
    },
  },
}

--return {
--  'supermaven-inc/supermaven-nvim',
--  event = 'BufReadPre',
--  opts = {
--    log_level = 'off',
--    keymaps = {
--      accept_suggestion = '<C-g>',
--      clear_suggestion = '<C-e>',
--      accept_word = '<C-w>',
--    },
--    disable_inline_completion = false,
--    disable_keymaps = false,
--    log_level = 'off',
--  },
--}
