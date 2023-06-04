return {
  'b0o/SchemaStore.nvim',
  {
    'folke/neodev.nvim',
    opts = {
      override = function(root_dir, library)
        library.plugins = true
        vim.b.neodev_enabled = library.enabled
      end,
    },
  },
  {
    'williamboman/mason-lspconfig.nvim',
    cmd = { 'LspInstall', 'LspUninstall' },
    opts = function(_, opts)
      if not opts.handlers then opts.handlers = {} end
      opts.handlers[1] = function(server) require('utils.lsp').setup(server) end
      opts.ensure_installed = { 'rust_analyzer' }
    end,
    config = function (_, opts)
      require('mason-lspconfig').setup(opts)
      require('utils').event('MasonLspSetup')
    end,
  },
  {
    'neovim/nvim-lspconfig',
    event = 'User SushiFile',
    config = function(_, _)
      local get_icon = require('utils').get_icon
      local signs = {
        { name = 'DiagnosticSignError', text = get_icon('DiagnosticError'), texthl = 'DiagnosticSignError' },
        { name = 'DiagnosticSignWarn', text = get_icon('DiagnosticWarn'), texthl = 'DiagnosticSignWarn' },
        { name = 'DiagnosticSignHint', text = get_icon('DiagnosticHint'), texthl = 'DiagnosticSignHint' },
        { name = 'DiagnosticSignInfo', text = get_icon('DiagnosticInfo'), texthl = 'DiagnosticSignInfo' },
        { name = 'DapStopped', text = get_icon('DapStopped'), texthl = 'DiagnosticWarn' },
        { name = 'DapBreakpoint', text = get_icon('DapBreakpoint'), texthl = 'DiagnosticInfo' },
        { name = 'DapBreakpointRejected', text = get_icon('DapBreakpointRejected'), texthl = 'DiagnosticError' },
        { name = 'DapBreakpointCondition', text = get_icon('DapBreakpointCondition'), texthl = 'DiagnosticInfo' },
        { name = 'DapLogPoint', text = get_icon('DapLogPoint'), texthl = 'DiagnosticInfo' },
      }

      for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign.name, sign)
      end

      lsp.setup_diagnostics(signs)

      if vim.g.lsp_handlers_enabled then
        vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded', silent = true })
        vim.lsp.handlers['textDocument/signatureHelp'] =
          vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded', silent = true })
      end

      local setup_servers = function()
	    local servers = { }
        vim.tbl_map(lsp.setup, servers)
        vim.api.nvim_exec_autocmds('FileType', {})
        require('utils').event('LspSetup')
      end

      vim.api.nvim_create_autocmd('User', {
        desc = 'set up LSP servers after mason-lspconfig',
        pattern = 'SushiMasonLspSetup',
        once = true,
        callback = setup_servers,
      })
    end,
  },
  {
    'onsails/lspkind.nvim',
    opts = {
      mode = 'symbol',
      symbol_map = {
        Array = '󰅪',
        Boolean = '⊨',
        Class = '󰌗',
        Constructor = '',
        Key = '󰌆',
        Namespace = '󰅪',
        Null = 'NULL',
        Number = '#',
        Object = '󰀚',
        Package = '󰏗',
        Property = '',
        Reference = '',
        Snippet = '',
        String = '󰀬',
        TypeParameter = '󰊄',
        Unit = '',
      },
    },
    enabled = vim.g.icons_enabled,
  },
  --{
  --  'ray-x/lsp_signature.nvim',
  --  event = 'User SushiFile',
  --  opts = {
  --    bind = true,
  --    handler_opts = {
  --      border = 'none',
  --    },
  --    hint_prefix = ' ',
  --    max_height = 12,
  --    max_width = 80,
  --    zindex = 200,
  --  },
  --},
  {
    'simrat39/rust-tools.nvim',
    event = 'User SushiFile',
    opts = {
      tools = {
        executor = require('rust-tools.executors').termopen,
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
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = {
      {
        'jay-babu/mason-null-ls.nvim',
        cmd = { 'NullLsInstall', 'NullLsUninstall' },
        opts = { handlers = {} },
      },
    },
    event = 'User SushiFile',
    opts = function() return { on_attach = require('utils.lsp').on_attach } end,
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
