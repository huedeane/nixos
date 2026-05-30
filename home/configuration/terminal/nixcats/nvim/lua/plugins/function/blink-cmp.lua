return {
  "blink.cmp",
  enabled = nixCats('general') or false,
  event = "DeferredUIEnter",
  on_require = "blink",
  after = function (plugin)
    require("blink.cmp").setup({
      keymap = { 
        preset = 'default', 
        ['<CR>'] = { 'accept', 'fallback' },
      },
      completion = {
        trigger = {
          show_on_insert_on_trigger_character = true,
          show_on_keyword = true,
          show_on_accept_on_trigger_character = true,
          show_on_trigger_character = true,
        },
      },
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
