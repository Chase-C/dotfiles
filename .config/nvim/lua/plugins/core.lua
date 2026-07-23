return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
  {
    "nvzone/floaterm",
    name = "floaterm",
    dependencies = "nvzone/volt",
    opts = {
      border = true,
      size = { h = 85, w = 90 },

      -- to use, make this func(buf)
      mappings = { sidebar = nil, term = nil },

      -- Default sets of terminals you'd like to open
      terminals = {
        { name = "General" },
        { name = "Build" },
        { name = "Copilot" },
      },
    },
    cmd = "FloatermToggle",
  },
  {
    "numToStr/Comment.nvim",
    opts = function()
      local commentstring_avail, commentstring = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
      return commentstring_avail and commentstring and { pre_hook = commentstring.create_pre_hook() } or {}
    end,
  },
}
