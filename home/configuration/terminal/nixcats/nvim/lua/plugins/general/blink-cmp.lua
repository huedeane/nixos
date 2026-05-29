return {
  "blink.cmp",
  enabled = nixCats('general') or false,
  event = "DeferredUIEnter",
  on_require = "blink",
  after = function (plugin)
    require("blink.cmp").setup({
      keymap = { preset = 'default' },
      appearance = {
        nerd_font_variant = 'mono'
      },
      signature = { enabled = true, },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    })
  end,
}
