for _, source in ipairs {
  'global',
  'options',
  'autocmds',
  'mappings',
} do
  local status_ok, fault = pcall(require, source)
  if not status_ok then vim.api.nvim_err_writeln('Failed to load ' .. source .. '\n\n' .. fault) end
end

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local output = vim.fn.system { 'git', 'clone', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath }
  if vim.api.nvim_get_vvar('shell_error') ~= 0 then
    vim.api.nvim_err_writeln('Error cloning lazy.nvim repository...\n\n' .. output)
  end
  local oldcmdheight = vim.opt.cmdheight:get()
  vim.opt.cmdheight = 1
  vim.notify 'Please wait while plugins are installed...'
  vim.api.nvim_create_autocmd('User', {
    desc = 'Load Mason and Treesitter after Lazy installs plugins',
    once = true,
    pattern = 'LazyInstall',
    callback = function()
      vim.cmd.bw()
      vim.opt.cmdheight = oldcmdheight
      vim.tbl_map(function(module) pcall(require, module) end, { 'nvim-treesitter', 'mason' })
      require('utils').notify('Mason is installing packages if configured, check status with :Mason')
    end,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = { { import = 'plugins' } },
  defaults = { lazy = true },
  install = { colorscheme = { sushi.colorscheme } },
  performance = {
    rtp = {
      disabled_plugins = { 'tohtml', 'gzip', 'zipPlugin', 'netrwPlugin', 'tarPlugin' },
    },
  },
  lockfile = vim.fn.stdpath 'data' .. '/lazy-lock.json',
})

if not pcall(vim.cmd.colorscheme, sushi.colorscheme) then
  require("utils").notify(
    "Error setting up colorscheme: " .. sushi.colorscheme,
    vim.log.levels.ERROR
  )
end
