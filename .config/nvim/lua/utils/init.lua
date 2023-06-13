--- ### Utilities
--
local M = { }

--- Merge extended options with a default table of options
function M.extend_tbl(default, opts)
  opts = opts or {}
  return default and vim.tbl_deep_extend('force', default, opts) or opts
end

function M.reload()
  local core_modules = { 'bootstrap', 'mappings' }
  local modules = vim.tbl_filter(function(module) return module:find '^user%.' end, vim.tbl_keys(package.loaded))

  vim.tbl_map(require('plenary.reload').reload_module, vim.list_extend(modules, core_modules))

  local success = true
  for _, module in ipairs(core_modules) do
    local status_ok, fault = pcall(require, module)
    if not status_ok then
      vim.api.nvim_err_writeln('Failed to load ' .. module .. '\n\n' .. fault)
      success = false
    end
  end

  if success then
    M.notify('Config successfully reloaded', vim.log.levels.INFO)
  else
    M.notify('Error reloading config...', vim.log.levels.ERROR)
  end
  vim.cmd.doautocmd('ColorScheme')
  return success
end

--- Insert one or more values into a list like table and maintain that you do not insert non-unique values (THIS MODIFIES `lst`)
function M.list_insert_unique(lst, vals)
  if not lst then lst = {} end
  assert(vim.tbl_islist(lst), 'Provided table is not a list like table')
  if not vim.tbl_islist(vals) then vals = { vals } end
  local added = {}
  vim.tbl_map(function(v) added[v] = true end, lst)
  for _, val in ipairs(vals) do
    if not added[val] then
      table.insert(lst, val)
      added[val] = true
    end
  end
  return lst
end

function M.conditional_func(func, condition, ...)
  if condition and type(func) == 'function' then return func(...) end
end

function M.get_icon(kind)
  if not M.icons then
    M.icons = require('icons')
  end

  return M.icons and M.icons[kind]
end

--- Get highlight properties for a given highlight name
function M.get_hlgroup(name, fallback)
  if vim.fn.hlexists(name) == 1 then
    local hl
    if vim.api.nvim_get_hl then -- check for new neovim 0.9 API
      hl = vim.api.nvim_get_hl(0, { name = name, link = false })
      if not hl.fg then hl.fg = 'NONE' end
      if not hl.bg then hl.bg = 'NONE' end
    else
      hl = vim.api.nvim_get_hl_by_name(name, vim.o.termguicolors)
      if not hl.foreground then hl.foreground = 'NONE' end
      if not hl.background then hl.background = 'NONE' end
      hl.fg, hl.bg = hl.foreground, hl.background
      hl.ctermfg, hl.ctermbg = hl.fg, hl.bg
      hl.sp = hl.special
    end
    return hl
  end
  return fallback or {}
end

--- Serve a notification with a title of 'Sushi'
function M.notify(msg, type, opts)
  vim.schedule(function() vim.notify(msg, type, M.extend_tbl({ title = 'Sushi' }, opts)) end)
end

--- Trigger a user event
function M.event(event)
  vim.schedule(function() vim.api.nvim_exec_autocmds('User', { pattern = 'Sushi' .. event }) end)
end

--- Open a URL under the cursor with the current operating system
function M.system_open(path)
  local cmd
  if vim.fn.has('win32') == 1 and vim.fn.executable('explorer') == 1 then
    cmd = { 'cmd.exe', '/K', 'explorer' }
  elseif vim.fn.has('unix') == 1 and vim.fn.executable('xdg-open') == 1 then
    cmd = { 'xdg-open' }
  elseif (vim.fn.has('mac') == 1 or vim.fn.has('unix') == 1) and vim.fn.executable('open') == 1 then
    cmd = { 'open' }
  end
  if not cmd then M.notify('Available system opening tool not found!', vim.log.levels.ERROR) end
  vim.fn.jobstart(vim.fn.extend(cmd, { path or vim.fn.expand '<cfile>' }), { detach = true })
end

--- Toggle a user terminal if it exists, if not then create a new one and save it
function M.toggle_term_cmd(opts)
  local terms = sushi.terminals
  -- if a command string is provided, create a basic table for Terminal:new() options
  if type(opts) == 'string' then opts = { cmd = opts, hidden = true } end
  local num = vim.v.count > 0 and vim.v.count or 1
  -- if terminal doesn't exist yet, create it
  if not terms[opts.cmd] then terms[opts.cmd] = {} end
  if not terms[opts.cmd][num] then
    if not opts.count then opts.count = vim.tbl_count(terms) * 100 + num end
    if not opts.on_exit then opts.on_exit = function() terms[opts.cmd][num] = nil end end
    terms[opts.cmd][num] = require('toggleterm.terminal').Terminal:new(opts)
  end
  -- toggle the terminal
  terms[opts.cmd][num]:toggle()
end

--- Create a button entity to use with the alpha dashboard
function M.alpha_button(sc, txt)
  -- replace <leader> in shortcut text with LDR for nicer printing
  local sc_ = sc:gsub('%s', ''):gsub('LDR', '<leader>')
  -- if the leader is set, replace the text with the actual leader key for nicer printing
  if vim.g.mapleader then sc = sc:gsub('LDR', vim.g.mapleader == ' ' and 'SPC' or vim.g.mapleader) end
  -- return the button entity to display the correct text and send the correct keybinding on press
  return {
    type = 'button',
    val = txt,
    on_press = function()
      local key = vim.api.nvim_replace_termcodes(sc_, true, false, true)
      vim.api.nvim_feedkeys(key, 'normal', false)
    end,
    opts = {
      position = 'center',
      text = txt,
      shortcut = sc,
      cursor = 5,
      width = 36,
      align_shortcut = 'right',
      hl = 'DashboardCenter',
      hl_shortcut = 'DashboardShortcut',
    },
  }
end

--- Check if a plugin is defined in lazy. Useful with lazy loading when a plugin is not necessarily loaded yet
function M.is_available(plugin)
  local lazy_config_avail, lazy_config = pcall(require, 'lazy.core.config')
  return lazy_config_avail and lazy_config.plugins[plugin] ~= nil
end

--- Resolve the options table for a given plugin with lazy
function M.plugin_opts(plugin)
  local lazy_config_avail, lazy_config = pcall(require, 'lazy.core.config')
  local lazy_plugin_avail, lazy_plugin = pcall(require, 'lazy.core.plugin')
  local opts = {}
  if lazy_config_avail and lazy_plugin_avail then
    local spec = lazy_config.plugins[plugin]
    if spec then opts = lazy_plugin.values(spec, 'opts') end
  end
  return opts
end

--- A helper function to wrap a module function to require a plugin before running
function M.load_plugin_with_func(plugin, module, func_names)
  if type(func_names) == 'string' then func_names = { func_names } end
  for _, func in ipairs(func_names) do
    local old_func = module[func]
    module[func] = function(...)
      module[func] = old_func
      require('lazy').load { plugins = { plugin } }
      module[func](...)
    end
  end
end

--- Register queued which-key mappings
function M.which_key_register()
  if M.which_key_queue then
    local wk_avail, wk = pcall(require, 'which-key')
    if wk_avail then
      for mode, registration in pairs(M.which_key_queue) do
        wk.register(registration, { mode = mode })
      end
      M.which_key_queue = nil
    end
  end
end

--- Table based API for setting keybindings
function M.set_mappings(map_table, base)
  -- iterate over the first keys for each mode
  base = base or {}
  for mode, maps in pairs(map_table) do
    -- iterate over each keybinding set in the current mode
    for keymap, options in pairs(maps) do
      -- build the options for the command accordingly
      if options then
        local cmd = options
        local keymap_opts = base

        if type(options) == 'table' then
          cmd = options[1]
          keymap_opts = vim.tbl_deep_extend('force', keymap_opts, options)
          keymap_opts[1] = nil
        end

        if not cmd or keymap_opts.name then -- if which-key mapping, queue it
          if not M.which_key_queue then M.which_key_queue = {} end
          if not M.which_key_queue[mode] then M.which_key_queue[mode] = {} end
          M.which_key_queue[mode][keymap] = keymap_opts
        else -- if not which-key mapping, set it
          vim.keymap.set(mode, keymap, cmd, keymap_opts)
        end
      end
    end
  end
  if package.loaded['which-key'] then M.which_key_register() end -- if which-key is loaded already, register
end

--- regex used for matching a valid URL/URI string
M.url_matcher =
  '\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+'

--- Delete the syntax matching rules for URLs/URIs if set
function M.delete_url_match()
  for _, match in ipairs(vim.fn.getmatches()) do
    if match.group == 'HighlightURL' then vim.fn.matchdelete(match.id) end
  end
end

--- Add syntax matching rules for highlighting URLs/URIs
function M.set_url_match()
  M.delete_url_match()
  if vim.g.highlighturl_enabled then vim.fn.matchadd('HighlightURL', M.url_matcher, 15) end
end

--- Run a shell command and capture the output and if the command succeeded or failed
function M.cmd(cmd, show_error)
  local wind32_cmd
  if vim.fn.has('win32') == 1 then wind32_cmd = { 'cmd.exe', '/C', cmd } end
  local result = vim.fn.system(wind32_cmd or cmd)
  local success = vim.api.nvim_get_vvar('shell_error') == 0
  if not success and (show_error == nil or show_error) then
    vim.api.nvim_err_writeln('Error running command: ' .. cmd .. '\nError message:\n' .. result)
  end
  return success and result:gsub('[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]', '') or nil
end

return M
