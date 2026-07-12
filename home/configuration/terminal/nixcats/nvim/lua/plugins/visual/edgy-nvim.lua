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

    local function toggle_edgy(dir)
      return function()
        if dir == nil then
          edgy.toggle()
        else
          edgy.toggle(dir)
        end
        vim.defer_fn(edgy.goto_main, 50)
      end
    end

    keymap({
      { "n", "<leader>e<left>", toggle_edgy("left"),   hide = true },
      { "n", "<leader>e<down>", toggle_edgy("bottom"), hide = true },
      { "n", "<leader>eh",      toggle_edgy("left"),   desc = "(Edgy) Toggle Neotree" },
      { "n", "<leader>ej",      toggle_edgy("bottom"), desc = "(Edgy) Toggle Terminal" },
      { "n", "<leader>ea",      toggle_edgy(),         desc = "(Edgy) Toggle All" },
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
      bottom = {
        {
          title = center("Terminal", 40),
          ft = "toggleterm",
          size = { height = 0.3 },
          open = "ToggleTerm",
          pinned = true,
          filter = function(buf, win)
            return vim.api.nvim_win_get_config(win).relative == ""
          end,
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
        winhighlight = "Normal:EdgyNormal,NormalNC:EdgyNormalNC",
      },
    })

    local arg = vim.fn.argv(0)
    if arg and arg ~= "" and vim.fn.isdirectory(arg) == 1 then
      vim.schedule(function()
        edgy.open("left")
        vim.cmd("Neotree filesystem focus")
      end)
    end
  end,
}
