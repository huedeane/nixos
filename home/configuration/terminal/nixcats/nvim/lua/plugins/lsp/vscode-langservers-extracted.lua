return {
  {
    "html",
    enabled = nixCats('lsp') or false,
    lsp = {
      filetypes = { 'html' },
    },
  },
  {
    "cssls",
    enabled = nixCats('lsp') or false,
    lsp = {
      filetypes = { 'css', 'scss', 'less', 'sass' },
    },
  },
  {
    "jsonls",
    enabled = nixCats('lsp') or false,
    lsp = {
      filetypes = { 'json', 'jsonc' },
    },
  },
  {
    "eslint",
    enabled = nixCats('lsp') or false,
    lsp = {
      filetypes = { 'javascript', 'typescript' },
    },
  },
}
