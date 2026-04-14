return {
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
      picker = {
        win = {
          input = {
            keys = {
              ["<C-f>"] = { "close", mode = { "i", "n" } },
              ["<C-b>"] = nil,
              ["<C-n>"] = { "preview_scroll_down", mode = { "i", "n" } },
              ["<C-p>"] = { "preview_scroll_up", mode = { "i", "n" } },
            },
          },
        },
      },
      styles = {
        input = {
          keys = {
            close = { "<C-f>", { "cmp_close", "cancel" }, mode = { "n", "i" }, expr = true },
          },
        },
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      for i, item in ipairs(opts.spec[1]) do
        if item[1] == "<leader>b" then
          table.remove(opts.spec[1], i)
          break
        end
      end

      table.insert(opts.spec[1], {
        "<leader>B",
        group = "buffer",
        expand = function()
          return require("which-key.extras").expand.buf()
        end,
      })
    end,
  },
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = {
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind" },
            },
          },
        },
      },
      keymap = {
        preset = "none",

        ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },

        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },

        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-s>"] = { "show_signature", "hide_signature", "fallback" },
        ["<C-p>"] = { "scroll_documentation_up", "fallback_to_mappings" },
        ["<C-n>"] = { "scroll_documentation_down", "fallback_to_mappings" },
      },
    },
  },
}
