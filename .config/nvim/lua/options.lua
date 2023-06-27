local options = {
  opt = {
    autoindent = true, -- Enable autoindentation
    autoread = true, -- Automatically read file when changed outside of nvim
    breakindent = true, -- Wrap indent to match  line start
    clipboard = 'unnamedplus', -- Connection to the system clipboard
    cmdheight = 0, -- hide command line unless needed
    completeopt = { 'menu', 'menuone', 'noselect' }, -- Options for insert mode completion
    copyindent = true, -- Copy the previous indentation on autoindenting
    cursorline = true, -- Highlight the text line of the cursor
    expandtab = true, -- Enable the use of space in tab
    fileencoding = 'utf-8', -- File content encoding for the buffer
    fillchars = { eob = ' ' }, -- Disable `~` on nonexistent lines
    foldenable = true, -- enable fold for nvim-ufo
    foldlevel = 99, -- set high foldlevel for nvim-ufo
    foldlevelstart = 99, -- start with all code unfolded
    foldcolumn = '1', -- show foldcolumn in nvim 0.9
    grepprg = 'rg --no-heading --vimgrep',
    grepformat = '%f:%l:%c:%m',
    history = 500, -- Number of commands to remember in a history table
    hlsearch = true, -- Highlight all matches on previous search pattern
    ignorecase = true, -- Case insensitive searching
    infercase = true, -- Infer cases in keyword completion
    laststatus = 3, -- globalstatus
    lazyredraw = true, -- Lazyredraw to make macro faster
    linebreak = true, -- Wrap lines at 'breakat'
    mouse = 'a', -- Enable mouse support
    number = true, -- Show numberline
    preserveindent = true, -- Preserve indent structure as much as possible
    pumheight = 10, -- Height of the pop up menu
    relativenumber = true, -- Show relative numberline
    scrolloff = 8, -- Number of lines to keep above and below the cursor
    shell = '/usr/bin/bash', -- Shell used for open terminals
    shiftwidth = 4, -- Number of space inserted for indentation
    showmode = false, -- Disable showing modes in command line
    showtabline = 0, -- always display tabline
    sidescrolloff = 8, -- Number of columns to keep at the sides of the cursor
    signcolumn = 'no', -- Always show the sign column
    smartcase = true, -- Case sensitivie searching
    smartindent = true, -- Smarter autoindentation
    smarttab = true, -- Insert tab on the start of a line according to shiftwidth
    splitbelow = true, -- Splitting a new window below the current one
    splitright = true, -- Splitting a new window at the right of the current one
    swapfile = false, -- Disable swapfile
    switchbuf = 'useopen,split', -- Switch to open buffer if possible
    tabstop = 4, -- Number of space in a tab
    termguicolors = true, -- Enable 24-bit RGB color in the TUI
    timeoutlen = 500, -- Shorten key timeout length a little bit for which-key
    undofile = true, -- Enable persistent undo
    updatetime = 250, -- Length of time to wait before triggering the plugin
    virtualedit = 'all', -- Allow moving cursor past end of line
    wrap = false, -- Disable wrapping of lines longer than the width of window
    writebackup = false, -- Disable making a backup before overwriting a file
  },
  g = {
    mapleader = ' ', -- set leader key
    maplocalleader = ' ', -- set default local leader key
    autoformat_enabled = false, -- enable or disable auto formatting at start (lsp.formatting.format_on_save must be enabled)
    cmp_enabled = true, -- enable completion at start
    codelens_enabled = true, -- enable or disable automatic codelens refreshing for lsp that support it
    diagnostics_mode = 3, -- set the visibility of diagnostics in the UI (0=off, 1=only show in status line, 2=virtual text off, 3=all on)
    highlighturl_enabled = true, -- highlight URLs by default
    lsp_handlers_enabled = true, -- enable or disable default vim.lsp.handlers (hover and signatureHelp)
    ui_notifications_enabled = true, -- disable notifications when toggling UI elements
  },
}

vim.opt.viewoptions:remove 'curdir' -- disable saving current directory with views
vim.opt.shortmess:append { s = true, I = true } -- disable startup message
vim.opt.backspace:append { 'nostop' } -- Don't stop backspace at insert
vim.opt.diffopt:append 'linematch:60' -- enable linematch diff algorithm

for scope, table in pairs(options) do
  for setting, value in pairs(table) do
    vim[scope][setting] = value
  end
end
