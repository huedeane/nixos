return {
  "nvim-navbuddy",
  enabled = nixCats('general') or false,
  cmd = "Navbuddy",
  keys = {
    { "<leader>n", "<cmd>Navbuddy<cr>", desc = "Navbuddy symbols" },
  },
  load = function(name)
    vim.cmd.packadd("nvim-navic")
    vim.cmd.packadd(name)
  end,
  after = function()
    require("nvim-navbuddy").setup({
      lsp = { auto_attach = true },
      window = { border = "rounded" },
    })
  end,
}
