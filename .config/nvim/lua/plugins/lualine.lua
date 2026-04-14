return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.section_separators = { left = "", right = "" }
      opts.options.component_separators = { left = "", right = "" }

      -- Remove the Copilot icon (fragile - might have to update in future)
      table.remove(opts.sections.lualine_x, 2)

      -- Add LSP status with a custom spinner and color
      table.insert(opts.sections.lualine_x, 2, {
        "lsp_status",
        icon = "󱘖",
        symbols = {
          spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
          done = "",
          separator = "⚫",
        },
        ignore_lsp = {},
        show_name = true,
        color = { fg = "#565f89" },
      })

      opts.sections.lualine_y = {
        { "progress", separator = " ", padding = { left = 1, right = 0 } },
        { "location", separator = "", padding = { left = 0, right = 0 } },
        {
          function()
            return "(" .. vim.api.nvim_buf_line_count(0) .. ")"
          end,
          padding = { left = 0, right = 1 },
        },
      }

      -- Add winbar section to show filename and progress in the current buffer

      local function total_lines()
        local winid = vim.g.statusline_winid or 0
        local bufnr = vim.api.nvim_win_get_buf(winid)
        return "/ " .. vim.api.nvim_buf_line_count(bufnr)
      end

      opts.winbar = {
        lualine_a = {},
        lualine_b = { "filename" },
        lualine_c = {},
        lualine_x = {},
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { total_lines, padding = { left = 0, right = 1 } },
        },
        lualine_z = {},
      }

      opts.inactive_winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { total_lines, padding = { left = 0, right = 1 } },
        },
        lualine_y = {},
        lualine_z = {},
      }
    end,
  },
}
