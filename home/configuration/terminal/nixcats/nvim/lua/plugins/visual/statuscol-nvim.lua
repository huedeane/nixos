return {
  "statuscol.nvim",
  enabled = nixCats('general') or false,
  event = "DeferredUIEnter",
  load = function(name)
    vim.cmd.packadd(name)
  end,
  after = function()
    local builtin = require("statuscol.builtin")
    local statuscol = require("statuscol")
    statuscol.setup({
      relculright = true,
      segments = {
        { text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
        { text = { "%s" },                  click = "v:lua.ScSa" },
        { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
      },
      ft_ignore = { "neo-tree", "toggleterm" },
    })
  end,
}
