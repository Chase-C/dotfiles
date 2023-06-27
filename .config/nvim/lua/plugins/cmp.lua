return {
  {
    'L3MON4D3/LuaSnip',
    build = 'make install_jsregexp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    config = function(_, opts)
      if opts then require('luasnip').config.setup(opts) end
      vim.tbl_map(function(type) require('luasnip.loaders.from_' .. type).lazy_load() end, { 'vscode', 'snipmate', 'lua' })
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'saadparwaiz1/cmp_luasnip',
      'chrisgrieser/cmp-nerdfont',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp',
      'onsails/lspkind.nvim',
    },
    event = 'InsertEnter',
    opts = function()
      local cmp = require('cmp')
      local cmp_buffer = require('cmp_buffer')
      local lspkind = require('lspkind')
      local luasnip = require('luasnip')

      local border_opts = {
        border = 'single',
        winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
      }

      local function has_words_before()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
      end

      return {
        enabled = function()
          local dap_prompt = vim.tbl_contains(
	        { 'dap-repl', 'dapui_watches', 'dapui_hover' },
	        vim.api.nvim_get_option_value('filetype', { buf = 0 })
	      )

          if vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt' and not dap_prompt then return false end
          return vim.g.cmp_enabled
        end,
        --preselect = cmp.PreselectMode.None,
        preselect = cmp.PreselectMode.Item,
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        },
        window = {
          completion = cmp.config.window.bordered(border_opts),
          documentation = cmp.config.window.bordered(border_opts),
        },
        mapping = {
          ['<C-k>'] = cmp.mapping.select_prev_item(),
          ['<C-j>'] = cmp.mapping.select_next_item(),
          ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
          ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
          ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    	    ['<C-e>'] = cmp.mapping(function(fallback)
      	    cmp.abort()
      	    fallback()
    	    end, {'i','s'}),
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              if cmp.get_active_entry() then
                cmp.select_next_item()
              else
                cmp.select_next_item({ count = 0 })
              end
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, {'i','s'}),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          {
            name = 'buffer',
            option = {
              -- Get completions from visible buffers, not just the current one
              get_bufnrs = function()
                local bufs = {}
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  bufs[vim.api.nvim_win_get_buf(win)] = true
                end
                return vim.tbl_keys(bufs)
              end
            },
          },
          { name = 'path' },
          { name = 'nerdfont' },
        }),
        sorting = {
          comparators = {
            -- Sort completion results by distance from cursor
            function(...) return cmp_buffer:compare_locality(...) end,
          }
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = 'symbol_text',
            maxwidth = 48,
            ellipsis_char = '...',
            menu = ({
              nvim_lsp = '[LSP]',
              luasnip = '[Snippet]',
              buffer = '[Buffer]',
              path = '[Path]',
              nerdfont = '[Icon]',
            })
          }),
        },
        expirimental = {
          ghost_text = false -- This conflicts with Copilot's preview
        },
      }
    end,
  },
  config = function(_, opts)
    local cmp = require('cmp')
    cmp.setup(opts.config)

    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' }
      },
      sorting = {
        comparators = {
          -- Sort completion results by distance from cursor
          function(...) return cmp_buffer:compare_locality(...) end,
        }
      },
    })
    
    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' }
      }, {
        { name = 'cmdline' }
      })
    })
  end,
}
