return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    { 'nvim-telescope/telescope-fzf-native.nvim', enabled = vim.fn.executable 'make' == 1, build = 'make' },
  },
  cmd = 'Telescope',
  opts = function()
    local actions = require 'telescope.actions'
    local get_icon = require('utils').get_icon
    return {
      defaults = {
        prompt_prefix = get_icon('Selected') .. ' ',
        selection_caret = get_icon('Selected') .. ' ',
        path_display = { 'truncate' },
        sorting_strategy = 'ascending',
        layout_config = {
          horizontal = { prompt_position = 'top', preview_width = 0.55 },
          vertical = { mirror = false },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        mappings = {
          i = {
            ['<C-f>'] = actions.close,
            ['<C-c>'] = actions.close,
            ['<Esc>'] = actions.close,
            ['<C-j>'] = actions.move_selection_next,
            ['<C-k>'] = actions.move_selection_previous,
            ['<C-n>'] = actions.cycle_history_next,
            ['<C-p>'] = actions.cycle_history_prev,
          },
          n = {
	    q = actions.close,
            ['<C-f>'] = actions.close,
            ['<C-c>'] = actions.close,
            ['<Esc>'] = actions.close,
    	  },
        },
      },
    }
  end,
  config = function(_, opts)
    local telescope = require('telescope')
    telescope.setup(opts)

    telescope.load_extension('fzf')
    telescope.load_extension('aerial')
  end
}
