return {
  "yamlls",
  enabled = nixCats('lsp') or false,
  lsp = {
    filetypes = { 'yaml', 'yml' },
  },
}
