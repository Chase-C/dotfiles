local M = {}

local ns = vim.api.nvim_create_namespace("flash-line")
vim.api.nvim_set_hl(ns, "FlashCmd", { fg = "#24283b", bg = "#bb9af7" })
vim.api.nvim_set_hl_ns(ns)

-- Highlight the current line for an instant
function M.flash_line()
  local window = vim.api.nvim_get_current_win()
  local buffer = vim.api.nvim_win_get_buf(window)
  local line = vim.api.nvim_win_get_cursor(window)[1] - 1
  local end_col = #vim.api.nvim_buf_get_lines(buffer, line, line + 1, false)[1]

  local extid = vim.api.nvim_buf_set_extmark(buffer, ns, line, 0, { end_col = end_col, hl_group = "FlashCmd" })
  vim.defer_fn(function()
    vim.api.nvim_buf_del_extmark(buffer, ns, extid)
  end, 150)
end

return M
