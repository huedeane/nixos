return {
  "omnisharp",
  enabled = nixCats('lsp') or false,
  lsp = {
    filetypes = { 'cs', 'vb' },
    cmd = { "OmniSharp" },
  },
}
