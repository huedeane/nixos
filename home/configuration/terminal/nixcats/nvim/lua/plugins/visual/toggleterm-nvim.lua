return {
  "toggleterm.nvim",
  enabled = nixCats('general') or false,
  cmd = { "ToggleTerm", "TermExec" },
  load = function(name)
    vim.cmd.packadd(name)
  end,
  after = function()
    require("toggleterm").setup({
      direction = "horizontal",
      shade_terminals = false, -- edgy handles the visuals
    })
  end,
}
