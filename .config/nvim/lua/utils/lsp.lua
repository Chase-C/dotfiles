-- LSP related utility functions

local M = { }

local utils     = require('utils')
local ui        = require('utils.ui')
local telescope = require('telescope.builtin')

M.diagnostics = { [0] = {}, {}, {}, {} }

function M.setup_diagnostics(signs)
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
    [0] = utils.extend_tbl(
      default_diagnostics,
      { underline = false, virtual_text = false, signs = false, update_in_insert = false }
    ),
    -- status only
    utils.extend_tbl(default_diagnostics, { virtual_text = false, signs = false }),
    -- virtual text off, signs on
    utils.extend_tbl(default_diagnostics, { virtual_text = false }),
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

function M.setup(server, default_opts)
  local opts = vim.tbl_deep_extend('force',
    {
      on_attach    = M.on_attach,
      capabilities = M.capabilities,
      flags        = M.flags,
    },
    default_opts or { }
  )

  if server == 'jsonls' then -- by default add json schemas
    local schemastore_avail, schemastore = pcall(require, 'schemastore')
    if schemastore_avail then
      opts.settings = { json = { schemas = schemastore.json.schemas(), validate = { enable = true } } }
    end
  end
  if server == 'yamlls' then -- by default add yaml schemas
    local schemastore_avail, schemastore = pcall(require, 'schemastore')
    if schemastore_avail then opts.settings = { yaml = { schemas = schemastore.yaml.schemas() } } end
  end
  if server == 'lua_ls' then -- by default initialize neodev and disable third party checking
    pcall(require, 'neodev')
    opts.before_init = function(_, config)
      if vim.b.neodev_enabled then
        table.insert(config.settings.Lua.workspace.library, vim.fn.stdpath('config') .. '/lua')
      end
    end
    opts.settings = { Lua = { workspace = { checkThirdParty = false } } }
  end

  require('lspconfig')[server].setup(opts)
end

--- The `on_attach` function
M.on_attach = function(client, bufnr)
  local sup_lens      = client.supports_method('textDocument/codeLens') and vim.g.codelens_enabled
  local sup_decl      = client.supports_method('textDocument/declaration')
  local sup_def       = client.supports_method('textDocument/definition')
  local sup_format    = client.supports_method('textDocument/formatting') and not vim.tbl_contains(M.formatting.disabled, client.name)
  local sup_highlight = client.supports_method('textDocument/documentHighlight')
  local sup_hover     = client.supports_method('textDocument/hover')
  local sup_impl      = client.supports_method('textDocument/implementation')
  local sup_ref       = client.supports_method('textDocument/references')
  local sup_rename    = client.supports_method('textDocument/rename')
  local sup_sighelp   = client.supports_method('textDocument/signatureHelp')
  local sup_typedef   = client.supports_method('textDocument/typeDefinition')
  local sup_workspace = client.supports_method('workspace/symbol')
  local sup_semantic  = client.supports_method('textDocument/semanticTokens') and vim.lsp.semantic_tokens

  if sup_lens then
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
      buffer = bufnr,
      callback = vim.lsp.codelens.refresh,
    })
  end

  if sup_format then
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
      and (vim.tbl_isempty(autoformat.allow_filetypes or {}) or vim.tbl_contains(autoformat.allow_filetypes, filetype))
      and (vim.tbl_isempty(autoformat.ignore_filetypes or {}) or not vim.tbl_contains(autoformat.ignore_filetypes, filetype))
    then
      vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        buffer = bufnr,
        callback = function()
          local autoformat_enabled = vim.b.autoformat_enabled
          if autoformat_enabled == nil then autoformat_enabled = vim.g.autoformat_enabled end
          if autoformat_enabled and ((not autoformat.filter) or autoformat.filter(bufnr)) then
            vim.lsp.buf.format(utils.extend_tbl(M.format_opts, { bufnr = bufnr }))
          end
        end,
      })
    end
  end

  if sup_highlight then
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })

    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end

  local lsp_map = {
    -- LSP group mappings
    { '<leader>ld', function() vim.diagnostic.open_float() end,       desc = 'Hover diagnostics' },
    { '<leader>l[', function() vim.diagnostic.goto_prev() end,        desc = 'Previous diagnostic' },
    { '<leader>l]', function() vim.diagnostic.goto_next() end,        desc = 'Next diagnostic' },
    { '<leader>lD', function() telescope.diagnostics() end,           desc = 'Search diagnostics' },
    { '<leader>lI', '<cmd>LspInfo<cr>',                               desc = 'LSP information' },
    { '<leader>la', function() vim.lsp.buf.code_action() end,         desc = 'LSP code action',                  mode = { 'n', 'v' } },
    { '<leader>ll', function() vim.lsp.codelens.refresh() end,        desc = 'LSP CodeLens refresh',             cond = sup_lens },
    { '<leader>lL', function() vim.lsp.codelens.run() end,            desc = 'LSP CodeLens run',                 cond = sup_lens },
    { '<leader>lf', function() vim.lsp.buf.format(M.format_opts) end, desc = 'Format buffer',                    cond = sup_format, mode = { 'n', 'v' } },
    { '<leader>lH', function() vim.lsp.buf.hover() end,               desc = 'Hover symbol details',             cond = sup_hover },
    { '<leader>li', function() vim.lsp.buf.implementation() end,      desc = 'Implementation of current symbol', cond = sup_impl },
    { '<leader>lr', function() telescope.lsp_references() end,        desc = 'Search references',                cond = sup_ref },
    { '<leader>lR', function() vim.lsp.buf.rename() end,              desc = 'Rename current symbol',            cond = sup_rename },
    { '<leader>lh', function() vim.lsp.buf.signature_help() end,      desc = 'Signature help',                   cond = sup_sighelp },
    { '<leader>lt', function() telescope.lsp_type_definitions() end,  desc = 'Definition of current type',       cond = sup_typedef },
    {
      '<leader>lW',
      function()
        vim.ui.input({ prompt = 'Symbol Query: ' }, function(query)
          if query then telescope.lsp_workspace_symbols { query = query } end
        end)
      end,
      desc = 'Search workspace symbols',
      cond = sup_workspace,
    },
    -- Top-level bindings
    { 'gD', function() vim.lsp.buf.declaration() end,        desc = 'Declaration of current symbol',         cond = sup_decl },
    { 'gd', function() telescope.lsp_definitions() end,      desc = 'Show the definition of current symbol', cond = sup_def },
    { 'K',  function() vim.lsp.buf.hover() end,              desc = 'Hover symbol details',                  cond = sup_hover },
    { 'gI', function() telescope.lsp_implementations() end,  desc = 'Implementation of current symbol',      cond = sup_impl },
    { 'gr', function() telescope.lsp_references() end,       desc = 'Search references',                     cond = sup_ref },
    { 'gT', function() telescope.lsp_type_definitions() end, desc = 'Definition of current type',            cond = sup_typedef },
    -- UI group mappings
    { '<leader>uof', function() ui.toggle_buffer_autoformat() end,           desc = 'Toggle autoformatting (buffer)',         cond = sup_format },
    { '<leader>uoF', function() ui.toggle_autoformat() end,                  desc = 'Toggle autoformatting (global)',         cond = sup_format },
    { '<leader>uoY', function() ui.toggle_buffer_semantic_tokens(bufnr) end, desc = 'Toggle LSP semantic highlight (buffer)', cond = sup_semantic },
  }

  utils.set_mappings(lsp_map, { buffer = bufnr })
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
M.capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { 'documentation', 'detail', 'additionalTextEdits' }
}
M.capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }

return M
