--return {
--  'zbirenbaum/copilot.lua',
--  event = 'BufReadPre',
--  opts = {
--    panel = {
--      enabled = false,
--    },
--    suggestion = {
--      enabled = true,
--      auto_trigger = true,
--      debounce = 100,
--      keymap = {
--        accept = '<C-g>',
--        accept_word = false,
--        accept_line = false,
--        next = '<C-r>',
--        prev = false,
--        dismiss = '<C-e>',
--      },
--    },
--    filetypes = {
--      help = false,
--      gitcommit = false,
--      gitrebase = false,
--      hgcommit = false,
--      svn = false,
--      cvs = false,
--      ['.'] = false,
--    },
--    copilot_node_command = 'node',
--    server_opts_overrides = { },
--  },
--}

return {
  'supermaven-inc/supermaven-nvim',
  event = 'BufReadPre',
  opts = {
    keymaps = {
      accept_suggestion = '<C-g>',
      clear_suggestion = '<C-e>',
      accept_word = '<C-w>',
    },
    disable_inline_completion = false,
    disable_keymaps = false,
    log_level = 'off',
  },
}
