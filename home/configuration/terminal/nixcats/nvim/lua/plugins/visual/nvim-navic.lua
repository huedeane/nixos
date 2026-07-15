return {
  "nvim-navic",
  enabled = nixCats('general') or false,
  event = "LspAttach",
  load = function(name)
    vim.cmd.packadd(name)
  end,
  after = function()
    require("nvim-navic").setup({
      lsp = { auto_attach = true },
      highlight = true,
    })
  end,
}
