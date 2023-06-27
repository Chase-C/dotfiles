local M = { }

local ns = vim.api.nvim_create_namespace('sushi-flash-line')
vim.api.nvim_set_hl(ns, 'SushiFlash', { fg = '#24283b', bg = '#bb9af7' })
vim.api.nvim_set_hl_ns(ns)

-- Highlight the current line for an instant
function M.flash_line()
  local window = vim.api.nvim_get_current_win()
  local buffer = vim.api.nvim_win_get_buf(window)
  local line   = vim.api.nvim_win_get_cursor(window)[1] - 1

  vim.api.nvim_buf_add_highlight(buffer, ns, 'SushiFlash', line, 0, -1)
  vim.defer_fn(function() vim.api.nvim_buf_clear_namespace(buffer, ns, 0, -1) end, 150)
end

return M
