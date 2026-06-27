return {
  "emmet_language_server",
  enabled = nixCats('lsp') or false,
  lsp = {
    filetypes = {
      'html',
      'css',
      'scss',
      'sass',
      'less',
      'javascriptreact',
      'typescriptreact',
    },
  },
}
