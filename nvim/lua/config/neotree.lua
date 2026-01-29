-- =================================
-- Neo-tree 설정 파일
-- ~/.config/nvim/lua/config/neotree.lua
-- =================================

local M = {}

function M.setup()
  require("neo-tree").setup({
    close_if_last_window = true,
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,
    open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
    sort_case_insensitive = false,
    
    default_component_configs = {
      container = {
        enable_character_fade = true,
      },
      indent = {
        indent_size = 2,
        padding = 1,
        with_markers = true,
        indent_marker = "│",
        last_indent_marker = "└",
        highlight = "NeoTreeIndentMarker",
        with_expanders = nil,
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
      modified = {
        symbol = "[+]",
        highlight = "NeoTreeModified",
      },
      name = {
        trailing_slash = false,
        use_git_status_colors = true,
        highlight = "NeoTreeFileName",
      },
      git_status = {
            symbols = {
              -- Change type
              added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
              modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
              deleted = "✖", -- this can only be used in the git_status source
              renamed = "󰁕", -- this can only be used in the git_status source
              -- Status type
              untracked = "",
              ignored = "",
              unstaged = "󰄱",
              staged = "",
              conflict = "",
            },
          },
      -- 파일 정보 컬럼들
      file_size = {
        enabled = true,
        width = 12,
        required_width = 64,
      },
      type = {
        enabled = true,
        width = 10,
        required_width = 122,
      },
      last_modified = {
        enabled = true,
        width = 20,
        required_width = 88,
      },
      created = {
        enabled = true,
        width = 20,
        required_width = 110,
      },
      symlink_target = {
        enabled = false,
      },
    },
    
    window = {
      position = "left",
      width = 40,
      auto_expand_width = false,
      mapping_options = {
        noremap = true,
        nowait = true,
      },
      mappings = {
        ["<space>"] = "toggle_node",
        ["<2-LeftMouse>"] = "open",
        ["<cr>"] = "open",
        ["<esc>"] = "cancel",
        ["P"] = {
          "toggle_preview",
          config = { use_float = true }
        },
        ["l"] = "focus_preview",
        ["S"] = "open_split",
        ["s"] = "open_vsplit",
        ["t"] = "open_tabnew",
        ["w"] = "open_with_window_picker",
        ["C"] = "close_node",
        ["z"] = "close_all_nodes",
        ["a"] = {
          "add",
          config = { show_path = "none" }
        },
        ["A"] = "add_directory",
        ["d"] = "delete",
        ["r"] = "rename",
        ["b"] = "rename_basename",
        ["y"] = "copy_to_clipboard",
        ["x"] = "cut_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["c"] = "copy",
        ["m"] = "move",
        ["q"] = "close_window",
        ["R"] = "refresh",
        ["?"] = "show_help",
        ["<"] = "prev_source",
        [">"] = "next_source",
        ["i"] = "show_file_details",
      }
    },
    
    filesystem = {
    follow_current_file = true,
    hijack_netrw_behavior = "open_default",
    use_libuv_file_watcher = true,
    filtered_items = {
            visible = false, -- when true, they will just be displayed differently than normal items
            hide_dotfiles = true,
            hide_gitignored = true,
            hide_hidden = true, -- only works on Windows for hidden files/directories
            hide_by_name = {
              --"node_modules"
            },
            hide_by_pattern = { -- uses glob style patterns
              --"*.meta",
              --"*/src/*/tsconfig.json",
            },
            always_show = { -- remains visible even if other settings would normally hide it
              ".gitignored",
	      ".dockerignore",
	      ".gitignore",
	      ".git",
	      ".claude",
	      ".cursor",
	      "res",
            },
            always_show_by_pattern = { -- uses glob style patterns
              ".env*",
            },
            never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
              ".DS_Store",
              "thumbs.db"
            },
            never_show_by_pattern = { -- uses glob style patterns
              ".null-ls_*",
            },
          },
          follow_current_file = {
            enabled = false, -- This will find and focus the file in the active buffer every time
            --               -- the current file is changed while the tree is open.
            leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
          },
          group_empty_dirs = false, -- when true, empty folders will be grouped together
          hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
          -- in whatever position is specified in window.position
          -- "open_current",  -- netrw disabled, opening a directory opens within the
          -- window like netrw would, regardless of window.position
          -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
          use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
          -- instead of relying on nvim autocmd events.
          window = {
            mappings = {
              ["<bs>"] = "navigate_up",
              ["."] = "set_root",
              ["H"] = "toggle_hidden",
              ["/"] = "fuzzy_finder",
              ["D"] = "fuzzy_finder_directory",
              ["#"] = "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
              -- ["D"] = "fuzzy_sorter_directory",
              ["f"] = "filter_on_submit",
              ["<c-x>"] = "clear_filter",
              ["[g"] = "prev_git_modified",
              ["]g"] = "next_git_modified",
              ["o"] = {
                "show_help",
                nowait = false,
                config = { title = "Order by", prefix_key = "o" },
              },
              ["oc"] = { "order_by_created", nowait = false },
              ["od"] = { "order_by_diagnostics", nowait = false },
              ["og"] = { "order_by_git_status", nowait = false },
              ["om"] = { "order_by_modified", nowait = false },
              ["on"] = { "order_by_name", nowait = false },
              ["os"] = { "order_by_size", nowait = false },
              ["ot"] = { "order_by_type", nowait = false },
              -- ['<key>'] = function(state) ... end,
            },
            fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
              ["<down>"] = "move_cursor_down",
              ["<C-n>"] = "move_cursor_down",
              ["<up>"] = "move_cursor_up",
              ["<C-p>"] = "move_cursor_up",
              ["<esc>"] = "close",
              ["<S-CR>"] = "close_keep_filter",
              ["<C-CR>"] = "close_clear_filter",
              ["<C-w>"] = { "<C-S-w>", raw = true },
              {
                -- normal mode mappings
                n = {
                  ["j"] = "move_cursor_down",
                  ["k"] = "move_cursor_up",
                  ["<S-CR>"] = "close_keep_filter",
                  ["<C-CR>"] = "close_clear_filter",
                  ["<esc>"] = "close",
                }
              }
              -- ["<esc>"] = "noop", -- if you want to use normal mode
              -- ["key"] = function(state, scroll_padding) ... end,
            },
          },

          commands = {}, -- Add a custom command or override a global one using the same function name
    },

    buffers = {
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      group_empty_dirs = true,
      show_unloaded = true,
      window = {
        mappings = {
          ["d"] = "buffer_delete",
          ["bd"] = "buffer_delete",
          ["<bs>"] = "navigate_up",
          ["."] = "set_root",
        },
      },
    },
    
    git_status = {
      window = {
        position = "float",
        mappings = {
          ["A"] = "git_add_all",
          ["gu"] = "git_unstage_file",
          ["ga"] = "git_add_file",
          ["gr"] = "git_revert_file",
          ["gc"] = "git_commit",
          ["gp"] = "git_push",
          ["gg"] = "git_commit_and_push",
        }
      }
    },

    -- Event handlers for custom footer
    event_handlers = {
      {
        event = "neo_tree_buffer_enter",
        handler = function(arg)
          -- Add footer with computer name and username
          vim.defer_fn(function()
            local bufnr = arg.bufnr or vim.api.nvim_get_current_buf()

            -- Check if this is actually a neo-tree buffer
            local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
            if filetype ~= 'neo-tree' then
              return
            end

            local ns_id = vim.api.nvim_create_namespace('neo_tree_footer')
            local hostname = vim.fn.hostname()
            local username = vim.fn.getenv('USER') or vim.fn.getenv('USERNAME') or 'unknown'

            -- Clear previous footer
            vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

            -- Create footer text with icons
            local footer_lines = {
              {""},
              {"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "Comment"},
              {""},
              {string.format("  %s  %s", username, hostname), "NeoTreeGitModified"},
              {""},
            }

            -- Get buffer line count
            local line_count = vim.api.nvim_buf_line_count(bufnr)

            -- Add virtual text at the bottom
            vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_count - 1, 0, {
              virt_lines = footer_lines,
              virt_lines_above = false
            })
          end, 50)  -- Small delay to ensure buffer is ready
        end
      },
      {
        event = "neo_tree_window_after_open",
        handler = function(args)
          -- Refresh footer when window is opened
          vim.defer_fn(function()
            local bufnr = vim.api.nvim_win_get_buf(args.winid)
            local ns_id = vim.api.nvim_create_namespace('neo_tree_footer')
            local hostname = vim.fn.hostname()
            local username = vim.fn.getenv('USER') or vim.fn.getenv('USERNAME') or 'unknown'

            -- Clear previous footer
            vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

            -- Create footer text with icons
            local footer_lines = {
              {""},
              {"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "Comment"},
              {""},
              {string.format("  %s  %s", username, hostname), "NeoTreeGitModified"},
              {""},
            }

            -- Get buffer line count
            local line_count = vim.api.nvim_buf_line_count(bufnr)

            -- Add virtual text at the bottom
            vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_count - 1, 0, {
              virt_lines = footer_lines,
              virt_lines_above = false
            })
          end, 100)
        end
      }
    }
  })

end

-- Neo-tree 토글 후 창 크기 균등 분배하는 커스텀 함수
function M.toggle_with_resize()
  vim.cmd("Neotree toggle")
  -- Neo-tree 토글 완료 후 창 크기 균등 분배
  vim.defer_fn(function()
    vim.cmd("wincmd =")
  end, 150) -- 150ms 대기 후 창 크기 조정
end

return M
