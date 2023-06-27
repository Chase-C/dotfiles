local M = { }

local function bool2str(bool) return bool and 'on' or 'off' end

local function ui_notify(str)
  if vim.g.ui_notifications_enabled then require('utils').notify(str) end
end

--- Toggle diagnostics
function M.toggle_diagnostics()
  vim.g.diagnostics_mode = (vim.g.diagnostics_mode - 1) % 4
  vim.diagnostic.config(require('utils.lsp').diagnostics[vim.g.diagnostics_mode])
  if vim.g.diagnostics_mode == 0 then
    ui_notify('diagnostics off')
  elseif vim.g.diagnostics_mode == 1 then
    ui_notify('only status diagnostics')
  elseif vim.g.diagnostics_mode == 2 then
    ui_notify('virtual text off')
  else
    ui_notify('all diagnostics on')
  end
end

--- Toggle cmp entrirely
function M.toggle_cmp()
  vim.g.cmp_enabled = not vim.g.cmp_enabled
  local ok, _ = pcall(require, 'cmp')
  ui_notify(ok and string.format('completion %s', bool2str(vim.g.cmp_enabled)) or 'completion not available')
end

--- Toggle auto format
function M.toggle_autoformat()
  vim.g.autoformat_enabled = not vim.g.autoformat_enabled
  ui_notify(string.format('Global autoformatting %s', bool2str(vim.g.autoformat_enabled)))
end

--- Toggle buffer local auto format
function M.toggle_buffer_autoformat()
  local old_val = vim.b.autoformat_enabled
  if old_val == nil then old_val = vim.g.autoformat_enabled end
  vim.b.autoformat_enabled = not old_val
  ui_notify(string.format('Buffer autoformatting %s', bool2str(vim.b.autoformat_enabled)))
end

--- Toggle buffer semantic token highlighting for all language servers that support it
function M.toggle_buffer_semantic_tokens(bufnr)
  vim.b.semantic_tokens_enabled = vim.b.semantic_tokens_enabled == false

  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client.server_capabilities.semanticTokensProvider then
      vim.lsp.semantic_tokens[vim.b.semantic_tokens_enabled and 'start' or 'stop'](bufnr or 0, client.id)
      ui_notify(string.format('Buffer lsp semantic highlighting %s', bool2str(vim.b.semantic_tokens_enabled)))
    end
  end
end

--- Set the indent and tab related numbers
function M.set_indent()
  local input_avail, input = pcall(vim.fn.input, 'Set indent value (>0 expandtab, <=0 noexpandtab): ')
  if input_avail then
    local indent = tonumber(input)
    if not indent or indent == 0 then return end
    vim.bo.expandtab = (indent > 0) -- local to buffer
    indent = math.abs(indent)
    vim.bo.tabstop = indent -- local to buffer
    vim.bo.softtabstop = indent -- local to buffer
    vim.bo.shiftwidth = indent -- local to buffer
    ui_notify(string.format('indent=%d %s', indent, vim.bo.expandtab and 'expandtab' or 'noexpandtab'))
  end
end

--- Toggle spell
function M.toggle_spell()
  vim.wo.spell = not vim.wo.spell -- local to window
  ui_notify(string.format('spell %s', bool2str(vim.wo.spell)))
end

--- Toggle wrap
function M.toggle_wrap()
  vim.wo.wrap = not vim.wo.wrap -- local to window
  ui_notify(string.format('wrap %s', bool2str(vim.wo.wrap)))
end

--- Toggle syntax highlighting and treesitter
function M.toggle_syntax()
  local ts_avail, parsers = pcall(require, 'nvim-treesitter.parsers')
  if vim.g.syntax_on then -- global var for on//off
    if ts_avail and parsers.has_parser() then vim.cmd.TSBufDisable 'highlight' end
    vim.cmd.syntax 'off' -- set vim.g.syntax_on = false
  else
    if ts_avail and parsers.has_parser() then vim.cmd.TSBufEnable 'highlight' end
    vim.cmd.syntax 'on' -- set vim.g.syntax_on = true
  end
  ui_notify(string.format('syntax %s', bool2str(vim.g.syntax_on)))
end

return M
