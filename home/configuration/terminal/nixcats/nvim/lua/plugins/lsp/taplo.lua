return {
  "taplo",
  enabled = nixCats('lsp') or false,
  lsp = {
    filetypes = { 'toml' },
  },
}
