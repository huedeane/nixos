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
      popup_border_style = "rounded",
      window = {
        position = "left",
        width = 30,
        mappings = {
          ["<space>"] = "toggle_node",
          ["<cr>"] = "open",
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
