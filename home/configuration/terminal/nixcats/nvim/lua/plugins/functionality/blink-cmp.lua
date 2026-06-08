return {
  "blink.cmp",
  enabled = nixCats('general') or false,
  event = "DeferredUIEnter",
  on_require = "blink",
  after = function ()
    require("blink.cmp").setup({
      cmdline = {
        keymap = {
          preset = 'cmdline',
            ['<Up>'] = { 'select_prev', 'fallback' },
            ['<Down>'] = { 'select_next', 'fallback' },
            ['<Tab>'] = { 'accept', 'fallback' },
            ['<Esc>'] = { 'hide', 'fallback' },
            ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        },
        completion = {
          menu = { auto_show = true },
          ghost_text = { enabled = true },
        },
      },
      keymap = {
        preset = 'none',
          ['<Up>'] = { 'select_prev', 'fallback' },
          ['<Down>'] = { 'select_next', 'fallback' },
          ['<Tab>'] = { 'accept', 'fallback' },
          ['<Esc>'] = { 'hide', 'fallback' },
          ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
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
