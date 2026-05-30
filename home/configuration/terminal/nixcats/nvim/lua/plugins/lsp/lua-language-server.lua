return {
  "lua_ls",
  enabled = nixCats('lsp') or false,
  lsp = {
    filetypes = { 'lua' },
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        formatters = {
          ignoreComments = true,
        },
        signatureHelp = { enabled = true },
        diagnostics = {
          globals = { "nixCats", "vim", },
          disable = { 'missing-fields' },
        },
        telemetry = { enabled = false },
      },
    },
  },
}
