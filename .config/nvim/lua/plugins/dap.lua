return {
  'mfussenegger/nvim-dap',
  event = 'User SushiFile',
  dependencies = {
    {
      'rcarriga/nvim-dap-ui',
      opts = { floating = { border = 'rounded' } },
      config = function(_, opts)
        local dap, dapui = require('dap'), require('dapui')
        dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
        dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
        dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end
        dapui.setup(opts)
      end,
    },
    {
      'rcarriga/cmp-dap',
      dependencies = { 'nvim-cmp' },
      config = function()
        require('cmp').setup.filetype({ 'dap-repl', 'dapui_watches', 'dapui_hover' }, {
          sources = {
            { name = 'dap' },
          },
        })
      end,
    },
  },
}
