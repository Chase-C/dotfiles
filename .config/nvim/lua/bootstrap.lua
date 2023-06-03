-- ===========
--- Bootstrap
-- ===========
--
-- Set up the global 'sushi' module

_G.sushi = { }

sushi.install = {
  home = vim.fn.stdpath('config'),
}

local options = sushi.updater.options
if sushi.install.is_stable ~= nil then options.channel = sushi.install.is_stable and 'stable' or 'nightly' end
if options.pin_plugins == nil then options.pin_plugins = options.channel == 'stable' end

--- table of user created terminals
sushi.user_terminals = {}
sushi.lsp = { }
sushi.colorscheme = 'nord'
sushi.shell = '/usr/bin/fish'
