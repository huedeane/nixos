return {
  "edgy.nvim",
  enabled = nixCats('general') or false,
  event = "DeferredUIEnter",
  load = function(name)
    vim.cmd.packadd(name)
  end,
  after = function()
    require("edgy").setup({
      exit_when_last = true,
      left = {
        {
          title = "File System",
          ft = "neo-tree",
          filter = function(buf)
            return vim.b[buf].neo_tree_source == "filesystem"
          end,
          pinned = true,
          open = "Neotree filesystem top",
          collapsed = false,
          size = {
            height = 0.5,
          },
        },
        {
          title = "Buffers",
          ft = "neo-tree",
          filter = function(buf)
            return vim.b[buf].neo_tree_source == "buffers"
          end,
          pinned = true,
          open = "Neotree buffers bottom",
          collapsed = false,
          size = {
            height = 0.5,
          },
        },
      },
      right = {
        {
          title = "File System",
          ft = "neo-tree",
          filter = function(buf)
            return vim.b[buf].neo_tree_source == "filesystem"
          end,
          pinned = true,
          open = "Neotree filesystem top",
          collapsed = false,
          size = {
            height = 0.5,
          },
        },
        {
          title = "Buffers",
          ft = "neo-tree",
          filter = function(buf)
            return vim.b[buf].neo_tree_source == "buffers"
          end,
          pinned = true,
          open = "Neotree buffers bottom",
          collapsed = false,
          size = {
            height = 0.5,
          },
        },
      },
      options = {
        left = { size = 30 },
        right = { size = 30 },
        bottom = { size = 10 },
        top = { size = 10 },
      },
      animate = {
        enabled = false,
      },
      wo = {
        winbar = true,
        winfixwidth = true,
        winfixheight = true,
        signcolumn = "yes",
        winhighlight = "Normal:EdgyNormal,WinBar:EdgyWinBar,WinBarNC:EdgyWinBarNC",
      },
      keys = {
        ["q"] = function(win) win:close() end,
        ["<c-q>"] = function(win) win:hide() end,
        ["Q"] = function(win) win.view.edgebar:close() end,
        ["]w"] = function(win) win:next({ visible = true, focus = true }) end,
        ["[w"] = function(win) win:prev({ visible = true, focus = true }) end,
        ["]W"] = function(win) win:next({ pinned = false, focus = true }) end,
        ["[W"] = function(win) win:prev({ pinned = false, focus = true }) end,
      },
    })
    vim.keymap.set("n", "<C-e>", function()
      require("edgy").toggle("left")
    end, { desc = "Toggle left panel" })
  end,
}
