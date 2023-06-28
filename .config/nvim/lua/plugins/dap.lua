return {
  {
    'mfussenegger/nvim-dap',
    event = 'User SushiFile',
  },
  {
    'rcarriga/nvim-dap-ui',
    event = 'User SushiFile',
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
    event = 'User SushiFile',
    dependencies = { 'nvim-cmp' },
    config = function()
      require('cmp').setup.filetype({ 'dap-repl', 'dapui_watches', 'dapui_hover' }, {
        sources = {
          { name = 'dap' },
        },
      })
    end,
  },
  {
    'mxsdev/nvim-dap-vscode-js',
    event = 'User SushiFile',
    dependencies = {
      'microsoft/vscode-js-debug',
      build = 'npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out' 
    },
    config = function()
      require('dap-vscode-js').setup({
        debugger_path = vim.fn.stdpath('data') .. '/lazy/vscode-js-debug',
        adapters = { 'pwa-node' },
      })

      require('dap').configurations['typescript'] = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file',
          runtimeExecutable = 'ts-node',
          program = '${file}',
          cwd = '${workspaceFolder}',
        },
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach',
          processId = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
        },
      }
    end,
  },
}
