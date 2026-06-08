return {
  "roslyn.nvim",
  ft = { "cs" },
  after = function()
    require("roslyn").setup({
      filewatching = "auto",
      broad_search = false,
      lock_target = false,
    })

    vim.lsp.config("roslyn", {
      on_attach = function()
      end,
      capabilities = require("blink.cmp").get_lsp_capabilities(),
      settings = {
        ["csharp|inlay_hints"] = {
          csharp_enable_inlay_hints_for_implicit_object_creation = true,
          csharp_enable_inlay_hints_for_implicit_variable_types = true,
        },
        ["csharp|code_lens"] = {
          dotnet_enable_references_code_lens = true,
        },
      },
    })
  end,
}
