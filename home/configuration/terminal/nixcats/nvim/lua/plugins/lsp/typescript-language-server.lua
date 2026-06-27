return {
  "ts_ls",
  enabled = nixCats('lsp') or false,
  lsp = {
    filetypes = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
    },
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
    },
  },
}
