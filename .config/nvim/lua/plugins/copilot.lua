return {
  'zbirenbaum/copilot.lua',
  event = 'BufReadPre',
  opts = {
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
}
