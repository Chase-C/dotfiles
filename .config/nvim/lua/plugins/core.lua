return {
  "nvim-lua/plenary.nvim",
  'MunifTanjim/nui.nvim',
  {
    "AstroNvim/astrotheme",
    opts = {
      plugins = { ["dashboard-nvim"] = true }
    }
  },
  {
    "NMAC427/guess-indent.nvim",
    event = "User AstroFile",
    config = function(_, opts)
      require("guess-indent").setup(opts)
      vim.cmd.lua({
	args = { "require('guess-indent').set_from_buffer('auto_cmd')" },
	mods = { silent = true },
      })
    end
  },
  {
    "stevearc/resession.nvim",
    enabled = vim.g.resession_enabled == true,
    opts = {
      buf_filter = function(bufnr) return require("utils.buffer").is_valid(bufnr) end,
      tab_buf_filter = function(tabpage, bufnr) return vim.tbl_contains(vim.t[tabpage].bufs, bufnr) end,
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      icons = { group = vim.g.icons_enabled and "" or "+", separator = "" },
      disable = { filetypes = { "TelescopePrompt" } },
    },
    config = function(_, opts)
      require("which-key").setup(opts)
      require("utils").which_key_register()
    end
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    opts = function()
      g.indent_blankline_char = '┊'
      g.indent_blankline_filetype_exclude = { 'help', 'packer' }
      g.indent_blankline_buftype_exclude = { 'terminal', 'nofile' }
      g.indent_blankline_show_trailing_blankline_indent = false

      return {
        space_char_blankline = " ",
        show_current_context = true,
        show_current_context_start = true,
      }
    end,
  },
  {
    'mehalter/nvim-window-picker',
    version = '2.*'
    opts = {
      show_prompt = false,
      prompt_message = '',
      hint = 'floating-big-letter',
      selection_chars = 'FJDKSLA;CMRUEIWOQP',
      picker_config = {
        floating_big_letter = {
          font = 'ansi-shadow', -- ansi-shadow |
        },
      },
      filter_rules = {
        autoselect_one = true,
        include_current_win = false,
        bo = {
          filetype = { 'NvimTree', 'neo-tree', 'notify' },
          buftype = { 'terminal' },
        },
      },
    }
  },
  {
    "kevinhwang91/nvim-ufo",
    event = { "User AstroFile", "InsertEnter" },
    dependencies = { "kevinhwang91/promise-async" },
    opts = {
      preview = {
        mappings = {
          scrollB = "<C-b>",
          scrollF = "<C-f>",
          scrollU = "<C-u>",
          scrollD = "<C-d>",
        },
      },
      provider_selector = function(_, filetype, buftype)
        local function handleFallbackException(bufnr, err, providerName)
          if type(err) == "string" and err:match "UfoFallbackException" then
            return require("ufo").getFolds(bufnr, providerName)
          else
            return require("promise").reject(err)
          end
        end

        return (filetype == "" or buftype == "nofile") and "indent" -- only use indent until a file is opened
          or function(bufnr)
            return require("ufo")
              .getFolds(bufnr, "lsp")
              :catch(function(err) return handleFallbackException(bufnr, err, "treesitter") end)
              :catch(function(err) return handleFallbackException(bufnr, err, "indent") end)
          end
      end,
    },
  },
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    opts = function()
      local commentstring_avail, commentstring = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
      return commentstring_avail and commentstring and { pre_hook = commentstring.create_pre_hook() } or {}
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      size = 10,
      on_create = function()
        vim.opt.foldcolumn = "0"
        vim.opt.signcolumn = "no"
      end,
      open_mapping = '<C-\\>',
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = false,
      terminal_mappings = true,
      persist_size = true,
      direction = 'float',
      float_opts = {
        border = 'curved',
        winblend = 0,
        highlights = {
          border = 'Normal',
          background = 'Normal',
        },
      },
      close_on_exit = true,
      shell = sushi.shell,
    },
  },
}
