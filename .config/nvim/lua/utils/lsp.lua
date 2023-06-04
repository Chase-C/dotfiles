-- LSP related utility functions

local M = { }
local utils = require('utils')

M.diagnostics = { [0] = {}, {}, {}, {} }

M.setup_diagnostics = function(signs)
  local default_diagnostics = {
    virtual_text = true,
    signs = { active = signs },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focused = false,
      style = 'minimal',
      border = 'rounded',
      source = 'always',
      header = '',
      prefix = '',
    },
  }

  M.diagnostics = {
    -- diagnostics off
    [0] = extend_tbl(
      default_diagnostics,
      { underline = false, virtual_text = false, signs = false, update_in_insert = false }
    ),
    -- status only
    extend_tbl(default_diagnostics, { virtual_text = false, signs = false }),
    -- virtual text off, signs on
    extend_tbl(default_diagnostics, { virtual_text = false }),
    -- all diagnostics on
    default_diagnostics,
  }

  vim.diagnostic.config(M.diagnostics[vim.g.diagnostics_mode])
end

M.formatting = { format_on_save = { enabled = true }, disabled = {} }
if type(M.formatting.format_on_save) == 'boolean' then
  M.formatting.format_on_save = { enabled = M.formatting.format_on_save }
end

M.format_opts = vim.deepcopy(M.formatting)
M.format_opts.disabled = nil
M.format_opts.format_on_save = nil
M.format_opts.filter = function(client)
  local filter = M.formatting.filter
  local disabled = M.formatting.disabled or {}
  -- check if client is fully disabled or filtered by function
  return not (vim.tbl_contains(disabled, client.name) or (type(filter) == 'function' and not filter(client)))
end

--- Helper function to set up a given server with the Neovim LSP client
---@param server string The name of the server to be setup
M.setup = function(server)
  local opts = M.config(server)
  require('lspconfig')[server].setup(opts)
end

function M.has_capability(capability, filter)
  local clients = vim.lsp.get_active_clients(filter)
  return not tbl_isempty(vim.tbl_map(function(client) return client.supports_method(capability) end, clients))
end

local function add_buffer_autocmd(augroup, bufnr, autocmds)
  if not vim.tbl_islist(autocmds) then autocmds = { autocmds } end
  local cmds_found, cmds = pcall(vim.api.nvim_get_autocmds, { group = augroup, buffer = bufnr })
  if not cmds_found or vim.tbl_isempty(cmds) then
    vim.api.nvim_create_augroup(augroup, { clear = false })
    for _, autocmd in ipairs(autocmds) do
      local events = autocmd.events
      autocmd.events = nil
      autocmd.group = augroup
      autocmd.buffer = bufnr
      vim.api.nvim_create_autocmd(events, autocmd)
    end
  end
end

local function del_buffer_autocmd(augroup, bufnr)
  local cmds_found, cmds = pcall(vim.api.nvim_get_autocmds, { group = augroup, buffer = bufnr })
  if cmds_found then vim.tbl_map(function(cmd) vim.api.nvim_del_autocmd(cmd.id) end, cmds) end
end

--- The `on_attach` function
M.on_attach = function(client, bufnr)
  local lsp_mappings = {
    n = {
      ['<leader>ld'] = {
        function() vim.diagnostic.open_float() end,
        desc = 'Hover diagnostics',
      },
      ['<leader>['] = {
        function() vim.diagnostic.goto_prev() end,
        desc = 'Previous diagnostic',
      },
      ['<leader>]'] = {
        function() vim.diagnostic.goto_next() end,
        desc = 'Next diagnostic',
      },
      ['gl'] = {
        function() vim.diagnostic.open_float() end,
        desc = 'Hover diagnostics',
      },
      ['[d'] = {
        function() vim.diagnostic.goto_prev() end,
        desc = 'Previous diagnostic',
      },
      [']d'] = {
        function() vim.diagnostic.goto_next() end,
        desc = 'Next diagnostic',
      },
    },
    v = {},
  }

  lsp_mappings.n['<leader>lD'] = {
    function() require('telescope.builtin').diagnostics() end,
    desc = 'Search diagnostics'
  }

  lsp_mappings.n['<leader>li'] = { '<cmd>LspInfo<cr>', desc = 'LSP information' }
  lsp_mappings.n['<leader>lI'] = { '<cmd>NullLsInfo<cr>', desc = 'Null-ls information' }

  if client.supports_method 'textDocument/codeAction' then
    lsp_mappings.n['<leader>la'] = {
      function() vim.lsp.buf.code_action() end,
      desc = 'LSP code action',
    }
    lsp_mappings.v['<leader>la'] = lsp_mappings.n['<leader>la']
  end

  if client.supports_method 'textDocument/codeLens' then
    add_buffer_autocmd('lsp_codelens_refresh', bufnr, {
      events = { 'InsertLeave', 'BufEnter' },
      desc = 'Refresh codelens',
      callback = function()
        if not M.has_capability('textDocument/codeLens', { bufnr = bufnr }) then
          del_buffer_autocmd('lsp_codelens_refresh', bufnr)
          return
        end
        if vim.g.codelens_enabled then vim.lsp.codelens.refresh() end
      end,
    })
    if vim.g.codelens_enabled then vim.lsp.codelens.refresh() end
    lsp_mappings.n['<leader>ll'] = {
      function() vim.lsp.codelens.refresh() end,
      desc = 'LSP CodeLens refresh',
    }
    lsp_mappings.n['<leader>lL'] = {
      function() vim.lsp.codelens.run() end,
      desc = 'LSP CodeLens run',
    }
  end

  if client.supports_method 'textDocument/declaration' then
    lsp_mappings.n['gD'] = {
      function() vim.lsp.buf.declaration() end,
      desc = 'Declaration of current symbol',
    }
  end

  if client.supports_method 'textDocument/definition' then
    lsp_mappings.n['gd'] = {
      function() vim.lsp.buf.definition() end,
      desc = 'Show the definition of current symbol',
    }
  end

  if client.supports_method 'textDocument/formatting' and not tbl_contains(M.formatting.disabled, client.name) then
    lsp_mappings.n['<leader>lf'] = {
      function() vim.lsp.buf.format(M.format_opts) end,
      desc = 'Format buffer',
    }
    lsp_mappings.v['<leader>lf'] = lsp_mappings.n['<leader>lf']

    vim.api.nvim_buf_create_user_command(
      bufnr,
      'Format',
      function() vim.lsp.buf.format(M.format_opts) end,
      { desc = 'Format file with LSP' }
    )
    local autoformat = M.formatting.format_on_save
    local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
    if
      autoformat.enabled
      and (tbl_isempty(autoformat.allow_filetypes or {}) or tbl_contains(autoformat.allow_filetypes, filetype))
      and (tbl_isempty(autoformat.ignore_filetypes or {}) or not tbl_contains(autoformat.ignore_filetypes, filetype))
    then
      add_buffer_autocmd('lsp_auto_format', bufnr, {
        events = 'BufWritePre',
        desc = 'autoformat on save',
        callback = function()
          if not M.has_capability('textDocument/formatting', { bufnr = bufnr }) then
            del_buffer_autocmd('lsp_auto_format', bufnr)
            return
          end
          local autoformat_enabled = vim.b.autoformat_enabled
          if autoformat_enabled == nil then autoformat_enabled = vim.g.autoformat_enabled end
          if autoformat_enabled and ((not autoformat.filter) or autoformat.filter(bufnr)) then
            vim.lsp.buf.format(extend_tbl(M.format_opts, { bufnr = bufnr }))
          end
        end,
      })
      lsp_mappings.n['<leader>uf'] = {
        function() require('utils.ui').toggle_buffer_autoformat() end,
        desc = 'Toggle autoformatting (buffer)',
      }
      lsp_mappings.n['<leader>uF'] = {
        function() require('utils.ui').toggle_autoformat() end,
        desc = 'Toggle autoformatting (global)',
      }
    end
  end

  if client.supports_method 'textDocument/documentHighlight' then
    add_buffer_autocmd('lsp_document_highlight', bufnr, {
      {
        events = { 'CursorHold', 'CursorHoldI' },
        desc = 'highlight references when cursor holds',
        callback = function()
          if not M.has_capability('textDocument/documentHighlight', { bufnr = bufnr }) then
            del_buffer_autocmd('lsp_document_highlight', bufnr)
            return
          end
          vim.lsp.buf.document_highlight()
        end,
      },
      {
        events = { 'CursorMoved', 'CursorMovedI' },
        desc = 'clear references when cursor moves',
        callback = function() vim.lsp.buf.clear_references() end,
      },
    })
  end

  if client.supports_method 'textDocument/hover' then
    lsp_mappings.n['K'] = {
      function() vim.lsp.buf.hover() end,
      desc = 'Hover symbol details',
    }
  end

  if client.supports_method 'textDocument/implementation' then
    lsp_mappings.n['gI'] = {
      function() vim.lsp.buf.implementation() end,
      desc = 'Implementation of current symbol',
    }
  end

  if client.supports_method 'textDocument/references' then
    lsp_mappings.n['gr'] = {
      function() vim.lsp.buf.references() end,
      desc = 'References of current symbol',
    }
    lsp_mappings.n['<leader>lR'] = {
      function() vim.lsp.buf.references() end,
      desc = 'Search references',
    }
  end

  if client.supports_method 'textDocument/rename' then
    lsp_mappings.n['<leader>lr'] = {
      function() vim.lsp.buf.rename() end,
      desc = 'Rename current symbol',
    }
  end

  if client.supports_method 'textDocument/signatureHelp' then
    lsp_mappings.n['<leader>lh'] = {
      function() vim.lsp.buf.signature_help() end,
      desc = 'Signature help',
    }
  end

  if client.supports_method 'textDocument/typeDefinition' then
    lsp_mappings.n['gT'] = {
      function() vim.lsp.buf.type_definition() end,
      desc = 'Definition of current type',
    }
  end

  if client.supports_method 'workspace/symbol' then
    lsp_mappings.n['<leader>lG'] = { function() vim.lsp.buf.workspace_symbol() end, desc = 'Search workspace symbols' }
  end

  if client.supports_method 'textDocument/semanticTokens' and vim.lsp.semantic_tokens then
    lsp_mappings.n['<leader>uY'] = {
      function() require('utils.ui').toggle_buffer_semantic_tokens(bufnr) end,
      desc = 'Toggle LSP semantic highlight (buffer)',
    }
  end

  if lsp_mappings.n.gd then lsp_mappings.n.gd[1] = function() require('telescope.builtin').lsp_definitions() end end
  if lsp_mappings.n.gI then
    lsp_mappings.n.gI[1] = function() require('telescope.builtin').lsp_implementations() end
  end
  if lsp_mappings.n.gr then lsp_mappings.n.gr[1] = function() require('telescope.builtin').lsp_references() end end
  if lsp_mappings.n['<leader>lR'] then
    lsp_mappings.n['<leader>lR'][1] = function() require('telescope.builtin').lsp_references() end
  end
  if lsp_mappings.n.gT then
    lsp_mappings.n.gT[1] = function() require('telescope.builtin').lsp_type_definitions() end
  end
  if lsp_mappings.n['<leader>lG'] then
    lsp_mappings.n['<leader>lG'][1] = function()
      vim.ui.input({ prompt = 'Symbol Query: ' }, function(query)
        if query then require('telescope.builtin').lsp_workspace_symbols { query = query } end
      end)
    end
  end

  if not vim.tbl_isempty(lsp_mappings.v) then
    lsp_mappings.v['<leader>l'] = { desc = (vim.g.icons_enabled and ' ' or '') .. 'LSP' }
  end
  utils.set_mappings(lsp_mappings, { buffer = bufnr })
end

--- The default LSP capabilities
M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem.documentationFormat = { 'markdown', 'plaintext' }
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities.textDocument.completion.completionItem.preselectSupport = true
M.capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
M.capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
M.capabilities.textDocument.completion.completionItem.deprecatedSupport = true
M.capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
M.capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
M.capabilities.textDocument.completion.completionItem.resolveSupport =
  { properties = { 'documentation', 'detail', 'additionalTextEdits' } }
M.capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }

--- Get the server configuration for a given language server to be provided to the server's `setup()` call
---@param server_name string The name of the server
---@return table # The table of LSP options used when setting up the given language server
function M.config(server_name)
  local server = require('lspconfig')[server_name]
  local lsp_opts = extend_tbl(
    extend_tbl(server.document_config.default_config, server),
    { capabilities = M.capabilities, flags = M.flags }
  )
  if server_name == 'jsonls' then -- by default add json schemas
    local schemastore_avail, schemastore = pcall(require, 'schemastore')
    if schemastore_avail then
      lsp_opts.settings = { json = { schemas = schemastore.json.schemas(), validate = { enable = true } } }
    end
  end
  if server_name == 'yamlls' then -- by default add yaml schemas
    local schemastore_avail, schemastore = pcall(require, 'schemastore')
    if schemastore_avail then lsp_opts.settings = { yaml = { schemas = schemastore.yaml.schemas() } } end
  end
  if server_name == 'lua_ls' then -- by default initialize neodev and disable third party checking
    pcall(require, 'neodev')
    lsp_opts.before_init = function(param, config)
      if vim.b.neodev_enabled then
        table.insert(config.settings.Lua.workspace.library, vim.fn.stdpath('config') .. '/lua')
      end
    end
    lsp_opts.settings = { Lua = { workspace = { checkThirdParty = false } } }
  end

  lsp_opts.on_attach = function(client, bufnr)
    conditional_func(server.on_attach, true, client, bufnr)
    M.on_attach(client, bufnr)
    conditional_func(lsp_opts.on_attach, true, client, bufnr)
  end

  return lsp_opts
end

return M
