return {
  "neo-tree.nvim",
  enabled = nixCats('general') or false,
  event = "DeferredUIEnter",
  load = function(name)
    vim.cmd.packadd(name)
    vim.cmd.packadd("nui.nvim")
  end,
  after = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      open_files_in_last_window = true,
      popup_border_style = "rounded",
      window = {
        position = "left",
        width = 30,
        mappings = {
          ["<space>"] = "none",
          ["<cr>"] = function(state)
            local node = state.tree:get_node()
            if node.type == "directory" then
              require("neo-tree.sources.filesystem.commands").toggle_node(state)
              return
            end
            require("neo-tree.sources.common.commands").open(state)
            vim.schedule(function()
              vim.cmd("Neotree focus")
            end)
          end,
          ["s"] = "open_vsplit",
          ["S"] = "open_split",
          ["t"] = "open_tabnew",
          ["q"] = "close_window",
          ["R"] = "refresh",
          ["a"] = "add",
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["m"] = "move",
          ["P"] = { "toggle_preview", config = { use_float = true } },
        },
        border = "rounded",
      },
      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = {
          enabled = true,
        },
        hijack_netrw_behavior = "open_default",
      },
      buffers = {
        follow_current_file = { enabled = true },
        show_unloaded = true,
      },
      git_status = {
        symbols = {
          added     = "+",
          modified  = "~",
          deleted   = "x",
          renamed   = ">",
          untracked = "?",
          ignored   = "#",
          unstaged  = "!",
          staged    = "*",
          conflict  = "!",
        },
      },
    })
  end,
}
