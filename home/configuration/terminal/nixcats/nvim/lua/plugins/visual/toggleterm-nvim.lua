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
      start_in_insert = true,
      persist_mode = false,
      shade_terminals = false,
    })
  end,
}
