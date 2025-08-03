return {
  {
    'mfussenegger/nvim-dap',
    event = 'User SushiFile',
    dependencies = {
      "rcarriga/nvim-dap-ui",
      -- virtual text for the debugger
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
    },

    config = function()
      local dap = require("dap")
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = { "/usr/bin/js-debug-dap", "${port}" },
        },
      }

      dap.defaults.fallback.external_terminal = {
        command = "/usr/bin/alacritty",
        args = { "-e" },
      }
      dap.defaults.fallback.force_external_terminal = true
      dap.defaults.fallback.terminal_win_cmd = "50vsplit new"
      dap.defaults.fallback.focus_terminal = true
      dap.set_log_level("INFO")

      local js_filetypes = { "typescript", "javascript" }
      for _, language in ipairs(js_filetypes) do
        if not dap.configurations[language] then
          dap.configurations[language] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              cwd = "${workspaceFolder}",
              sourceMaps = true,


              runtimeArgs = { "-r", "ts-node/register" },
              runtimeExecutable = "node",
              args = { "--inspect", "${file}" },
              skipFiles = { "node_modules/**" },
              console = "integratedTerminal",

            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
            },
            {
              name = 'Compile & Launch',
              type = 'pwa-node',
              request = 'launch',
              preLaunchTask = 'npm build',
              program = '${workspaceFolder}/node_modules/.bin/electron',
              args = {
                '${workspaceFolder}/dist/index.js',
              },
              outFiles = {
                '${workspaceFolder}/dist/*.js',
              },
              resolveSourceMapLocations = {
                '${workspaceFolder}/dist/**/*.js',
                '${workspaceFolder}/dist/*.js',
              },
              rootPath = '${workspaceFolder}',
              cwd = '${workspaceFolder}',
              sourceMaps = true,
              skipFiles = { '<node_internals>/**' },
              protocol = 'inspector',
              console = 'integratedTerminal',
            },
          }
        end
      end
    end,
  },
  { 'nvim-neotest/nvim-nio' },
  {
    'rcarriga/nvim-dap-ui',
    requires = { 'nvim-neotest/nvim-nio' },
    event = 'User SushiFile',
    dependencies = { 'nvim-neotest/nvim-nio' },
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
}
