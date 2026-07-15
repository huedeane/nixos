return {
  "indent-blankline.nvim",
  enabled = nixCats('general') or false,
  event = "DeferredUIEnter",
  load = function(name)
    vim.cmd.packadd(name)
  end,
  after = function()
    local ibl = require("ibl")
    ibl.setup({
      indent = {
        char = "│",
        highlight = "IblIndent",
      },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
      },
      whitespace = {
        remove_blankline_trail = false
      },
    })
  end,
}
