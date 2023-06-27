return {
  'b0o/SchemaStore.nvim',
  {
    'neovim/nvim-lspconfig',
    --lazy = false,
    event = 'BufReadPre',
    dependencies = {
      {
        'folke/neodev.nvim',
        opts = {
          override = function(_, library)
            library.enabled = true
            library.plugins = true
          end
        }
      }
    },
    config = function(_, _)
      local lsp = require('utils.lsp')
      local get_icon = require('utils').get_icon
      local signs = {
        { name = 'DiagnosticSignError',    text = get_icon('DiagnosticError'),        texthl = 'DiagnosticSignError' },
        { name = 'DiagnosticSignWarn',     text = get_icon('DiagnosticWarn'),         texthl = 'DiagnosticSignWarn' },
        { name = 'DiagnosticSignHint',     text = get_icon('DiagnosticHint'),         texthl = 'DiagnosticSignHint' },
        { name = 'DiagnosticSignInfo',     text = get_icon('DiagnosticInfo'),         texthl = 'DiagnosticSignInfo' },
        { name = 'DapStopped',             text = get_icon('DapStopped'),             texthl = 'DiagnosticWarn' },
        { name = 'DapBreakpoint',          text = get_icon('DapBreakpoint'),          texthl = 'DiagnosticInfo' },
        { name = 'DapBreakpointRejected',  text = get_icon('DapBreakpointRejected'),  texthl = 'DiagnosticError' },
        { name = 'DapBreakpointCondition', text = get_icon('DapBreakpointCondition'), texthl = 'DiagnosticInfo' },
        { name = 'DapLogPoint',            text = get_icon('DapLogPoint'),            texthl = 'DiagnosticInfo' },
      }

      for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign.name, sign)
      end

      lsp.setup_diagnostics(signs)

      local orig_handler = vim.lsp.handlers['$/progress']
      vim.lsp.handlers['$/progress'] = function(_, msg, info)
        if msg.value.kind == 'end' then
          vim.defer_fn(function()
            require('utils').event('LspProgressEnd')
          end, 100)
        end
        orig_handler(_, msg, info)
      end

      if vim.g.lsp_handlers_enabled then
        vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded', silent = true })
        vim.lsp.handlers['textDocument/signatureHelp'] =
          vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded', silent = true })
      end

      local servers = {
        { server = 'clangd' },
        { server = 'glslls' },
        {
          server = 'lua_ls',
          opts = {
            settings = {
              Lua = {
                completion = {
                  callSnippet = 'Replace'
                }
              }
            }
          },
        },
        -- Taken care of by rust-tools plugin
        --{ server = 'rust_analyzer' },
        { server = 'tsserver' },
      }

      for _, server in ipairs(servers) do
        lsp.setup(server.server, server.opts)
      end

      require('utils').event('LspSetup')
    end,
  },
  {
    'simrat39/rust-tools.nvim',
    --lazy = false,
    event = 'BufReadPre',
    opts = {
      server = {
        on_attach    = require('utils.lsp').on_attach,
        capabilities = require('utils.lsp').capabilities,
        flags        = require('utils.lsp').flags,
      },
      tools = {
        reload_workspace_from_cargo_toml = true,
        inlay_hints = {
          auto = true,
          only_current_line = false,
          show_parameter_hints = true,
          parameter_hints_prefix = ' ',
          other_hints_prefix = '󰧂 ',
        },
        --hover_actions = {
        --  border = 'none',
        --  max_width = nil,
        --  max_height = nil,
        --  auto_focus = true,
        --},
      },
      dap = {
        adapter = {
          type = 'executable',
          command = 'lldb-vscode',
          name = 'rt_lldb',
        },
      },
    },
  },
  {
    'onsails/lspkind.nvim',
    opts = {
      mode = 'symbol',
      symbol_map = {
        Array = '󰅪',
        Boolean = '⊨',
        Class = '󰌗',
        Color = '󰏘',
        Constant = '󰏿',
        Constructor = '',
        Enum = '',
        EnumMember = '',
        Event = '',
        Field = '󰜢',
        File = '󰈙',
        Folder = '󰉋',
        Function = '󰊕',
        Interface = '',
        Key = '󰌆',
        Keyword = '󰌋',
        Method = '󰆧',
        Module = '',
        Namespace = '',
        Null = 'NULL',
        Number = '#',
        Object = '󰀚',
        Operator = '󰆕',
        Package = '󰏗',
        Property = '',
        Reference = '',
        Snippet = '',
        String = '󰀬',
        Struct = '󰙅',
        Text = '󰉿',
        TypeParameter = '󰊄',
        Value = '󰎠',
        Variable = '󰀫',
        Unit = '',
      },
    },
    enabled = vim.g.icons_enabled,
    config = function(_, opts)
      require('lspkind').init(opts)
    end,
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    event = 'User SushiFile',
    opts = function()
      --local null_ls = require('null-ls')
      return {
        sources = {
          --null_ls.builtins.diagnostics.selene
        },
        --on_attach = require('utils.lsp').on_attach
      }
    end,
  },
  {
    'stevearc/aerial.nvim',
    event = 'User SushiFile',
    opts = {
      attach_mode = 'global',
      backends = { 'lsp', 'treesitter', 'markdown', 'man' },
      layout = { min_width = 28 },
      show_guides = true,
      filter_kind = false,
      guides = {
        mid_item = '├ ',
        last_item = '└ ',
        nested_top = '│ ',
        whitespace = '  ',
      },
      keymaps = {
        ['[y'] = 'actions.prev',
        [']y'] = 'actions.next',
        ['[Y'] = 'actions.prev_up',
        [']Y'] = 'actions.next_up',
        ['{'] = false,
        ['}'] = false,
        ['[['] = false,
        [']]'] = false,
      },
    },
  },
}
