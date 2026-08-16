-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("c_indentation", { clear = true }),
  pattern = "c",
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
    vim.bo.expandtab = true
  end,
})

local function reset_floaterm_view()
  local state = package.loaded["floaterm.state"]
  if state and vim.api.nvim_get_current_win() == state.win and vim.bo.buftype == "terminal" then
    vim.wo.sidescrolloff = 0
    vim.fn.winrestview({ leftcol = 0 })
  end
end

vim.api.nvim_create_autocmd({ "BufEnter", "TermEnter" }, {
  group = vim.api.nvim_create_augroup("floaterm_no_sidescroll", { clear = true }),
  callback = function()
    reset_floaterm_view()
    vim.schedule(reset_floaterm_view)
  end,
})
