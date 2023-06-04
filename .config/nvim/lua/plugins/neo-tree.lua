local get_icon = require('utils').get_icon
return {
  {
    'mrbjarksen/neo-tree-diagnostics.nvim',
    dependencies = {
      'nvim-neo-tree/neo-tree.nvim',
    }
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',      
    },
    cmd = 'Neotree',
    init = function() vim.g.neo_tree_remove_legacy_commands = true end,
    opts = {
      auto_clean_after_session_restore = true,
      close_if_last_window = true,
      --popup_border_style = 'rounded',
      --git_status_async = false,
      enable_diagnostics = true,
      --open_files_do_not_replace_types = { 'terminal', 'trouble', 'qf' },
      --sort_case_insensitive = false,
      --sort_function = nil,
      sources = { 'filesystem', 'document_symbols', 'diagnostics', 'git_status' },
      source_selector = {
        winbar = true,
        content_layout = 'center',
        sources = {
          { source = 'filesystem', display_name = get_icon('FolderClosed') .. ' File' },
          { source = 'diagnostics', display_name = get_icon('Diagnostic') .. ' Diagnostic' },
          { source = 'git_status', display_name = get_icon('Git') .. ' Git' },
        },
      },
      default_component_configs = {
        container = {
          enable_character_fade = true
        },
        indent = {
          indent_size = 1,
          padding = 0,
        },
        icon = {
          folder_closed = get_icon('FolderClosed'),
          folder_open = get_icon('FolderOpen'),
          folder_empty = get_icon('FolderEmpty'),
          folder_empty_open = get_icon('FolderEmpty'),
          default = get_icon('DefaultFile'),
        },
        modified = {
          symbol = get_icon('FileModified'),
        },
        git_status = {
          symbols = {
            added = get_icon('GitAdd'),
            deleted = get_icon('GitDelete'),
            modified = get_icon('GitChange'),
            renamed = get_icon('GitRenamed'),
            untracked = get_icon('GitUntracked'),
            ignored = get_icon('GitIgnored'),
            unstaged = get_icon('GitUnstaged'),
            staged = get_icon('GitStaged'),
            conflict = get_icon('GitConflict'),
          },
        },
      },
      commands = {
        system_open = function(state) require('utils').system_open(state.tree:get_node():get_id()) end,
        parent_or_close = function(state)
          local node = state.tree:get_node()
          if (node.type == 'directory' or node:has_children()) and node:is_expanded() then
            state.commands.toggle_node(state)
          else
            require('neo-tree.ui.renderer').focus_node(state, node:get_parent_id())
          end
        end,
        child_or_open = function(state)
          local node = state.tree:get_node()
          if node.type == 'directory' or node:has_children() then
            if not node:is_expanded() then -- if unexpanded, expand
              state.commands.toggle_node(state)
            else -- if expanded and has children, seleect the next child
              require('neo-tree.ui.renderer').focus_node(state, node:get_child_ids()[1])
            end
          else -- if not a directory just open it
            state.commands.open(state)
          end
        end,
        copy_selector = function(state)
          local node = state.tree:get_node()
          local filepath = node:get_id()
          local filename = node.name
          local modify = vim.fn.fnamemodify

          local results = {
            e = { val = modify(filename, ':e'), msg = 'Extension only' },
            f = { val = filename, msg = 'Filename' },
            F = { val = modify(filename, ':r'), msg = 'Filename w/o extension' },
            h = { val = modify(filepath, ':~'), msg = 'Path relative to Home' },
            p = { val = modify(filepath, ':.'), msg = 'Path relative to CWD' },
            P = { val = filepath, msg = 'Absolute path' },
          }

          local messages = {
            { '\nChoose to copy to clipboard:\n', 'Normal' },
          }
          for i, result in pairs(results) do
            if result.val and result.val ~= '' then
              vim.list_extend(messages, {
                { ('%s.'):format(i), 'Identifier' },
                { (' %s: '):format(result.msg) },
                { result.val, 'String' },
                { '\n' },
              })
            end
          end
          vim.api.nvim_echo(messages, false, {})
          local result = results[vim.fn.getcharstr()]
          if result and result.val and result.val ~= '' then
            vim.notify('Copied: ' .. result.val)
            vim.fn.setreg('+', result.val)
          end
        end,
      },
      window = {
	position = 'left',
        width = 30,
        mappings = {
          ['<C-Space>'] = 'toggle_node',
          ['<2-LeftMouse>'] = 'open',
          ['<CR>'] = 'open_with_window_picker',
          ['<Esc>'] = 'revert_preview',
          p = { 'toggle_preview', config = { use_float = true } },
          s = 'split_with_window_picker',
          v = 'vsplit_with_window_picker',
          y = 'copy_selector',
          z = 'close_all_nodes',
          Z = 'expand_all_nodes',
          a = { 
            'add',
            -- this command supports BASH style brace expansion ('x{a,b,c}' -> xa,xb,xc). see `:h neo-tree-file-actions` for details
            -- some commands may take optional config options, see `:h neo-tree-mappings` for details
            config = {
              show_path = 'none' -- 'none', 'relative', 'absolute'
            }
          },
          R = 'rename',
          r = 'refresh',
          e = function() vim.api.nvim_exec('Neotree focus filesystem left', true) end,
          d = function() vim.api.nvim_exec('Neotree focus diagnostics left', true) end,
          h = 'parent_or_close',
          l = 'child_or_open',
          o = 'open',
          O = 'system_open',
          ['?'] = 'show_help',
          ['<'] = 'prev_source',
          ['>'] = 'next_source',
          A = 'noop',
          c = 'noop',
          C = 'noop',
          D = 'noop',
          f = 'noop',
          m = 'noop',
          P = 'noop',
          q = 'noop',
          S = 'noop',
          t = 'noop',
          x = 'noop',
          ['#'] = 'noop',
          ['<Space>'] = 'noop',
          ['<BS>'] = 'noop',
        },
      },
      filesystem = {
        async_directory_scan = 'never',
        filtered_items = {
          visible = false, -- when true, they will just be displayed differently than normal items
          hide_dotfiles = true,
          hide_gitignored = true,
          hide_hidden = true, -- only works on Windows for hidden files/directories
          hide_by_name = {
            'node_modules',
          },
          hide_by_pattern = {
            '*.lock',
          },
          always_show = {
            '.gitignore',
          },
          never_show = { },
          never_show_by_pattern = { },
        },
        follow_current_file = true,
        group_empty_dirs = false,
        hijack_netrw_behavior = 'open_default',
        use_libuv_file_watcher = true,
        window = {
          mappings = {
            ['-'] = 'navigate_up',
            ['.'] = 'set_root',
            ['H'] = 'toggle_hidden',
            ['/'] = 'filter_on_submit',
            ['<c-x>'] = 'clear_filter',
            ['[g'] = 'prev_git_modified',
            [']g'] = 'next_git_modified',
          },
          fuzzy_finder_mappings = {
            ['<down>'] = 'move_cursor_down',
            ['<C-j>'] = 'move_cursor_down',
            ['<up>'] = 'move_cursor_up',
            ['<C-k>'] = 'move_cursor_up',
          },
        },
        commands = { }
      },
      diagnostics = {
        auto_preview = {
          enabled = false,
        },
        bind_to_cwd = true,
        diag_sort_function = 'severity',
        follow_behavior = {
          always_focus_file = false,
          expand_followed = true,
          collapse_others = true,
        },
        follow_current_file = true,
        group_dirs_and_files = true,
        group_empty_dirs = true,
        show_unloaded = true,
        refresh = {
          delay = 250,
          event = 'vim_diagnostic_changed',
          max_items = false,
        },
      },
      document_symbols = {
        follow_cursor = true,
        window = {
          mappings = {
            ['<CR>'] = 'open',
            ['<Esc>'] = function() vim.api.nvim_exec('Neotree action=close source=document_symbols', true) end,
            ['<C-f>'] = function() vim.api.nvim_exec('Neotree action=close source=document_symbols', true) end,
          },
        },
      },
      event_handlers = {
        {
          event = 'neo_tree_buffer_enter',
          handler = function(_) vim.opt_local.signcolumn = 'auto' end,
        },
        {
          event = 'neo_tree_window_after_open',
          handler = function(args)
            if args.position == 'left' or args.position == 'right' then
              vim.cmd('wincmd =')
            end
          end
        },
        {
          event = 'neo_tree_window_after_close',
          handler = function(args)
            if args.position == 'left' or args.position == 'right' then
              vim.cmd('wincmd =')
            end
          end
        }
      },
    },
  },
}
