return {
  "taplo",
  enabled = nixCats('lsp') or false,
  lsp = {
    filetypes = { 'toml' },
    settings = {
      evenBetterToml = {
        formatter = {
          arrayAutoExpand = false,
          inlineTableExpand = false,
          arrayAutoCollapse = true,
          columnWidth = 120,
        },
      },
    },
  },
}
