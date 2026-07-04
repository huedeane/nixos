local function center(str, width)
  local padding = math.floor((width - #str) / 2)
  return string.rep(" ", padding) .. str
end

return {
  "edgy.nvim",
  enabled = nixCats('general') or false,
  event = "DeferredUIEnter",
  load = function(name)
    vim.cmd.packadd(name)
  end,
  after = function()
    local edgy = require("edgy")
    local keymap = require("config.utils").keymap

    local function toggle_left()
      edgy.toggle("left")
      vim.defer_fn(edgy.goto_main, 50)
    end

    keymap({
      { "n", "<leader>en", toggle_left, desc = "(Edgy) Toggle Neotree" },
    })

    edgy.setup({
      left = {
        {
          title = center("File System", 40),
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
          title = center("Buffers", 40),
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
      icons = {
        open = "",
        closed = "",
      },
      options = {
        left = { size = 40 },
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
        winfixheight = false,
        spell = false,
        signcolumn = "no",
      },
    })

    local arg = vim.fn.argv(0)
    if arg and arg ~= "" and vim.fn.isdirectory(arg) == 1 then
      vim.defer_fn(function()
        require("edgy").open("left")
      end, 200)
    end
  end,
}
