return {
  "nvim-treesitter",
  enabled = nixCats('general') or false,
  event = "DeferredUIEnter",
  after = function()
    -- Treesitter's experimental indentexpr over-indents these; keep Neovim's
    -- built-in indent for them instead.
    local skip_ts_indent = { css = true, scss = true, sass = true, less = true }

    local function treesitter_try_attach(buf, language)
      if not vim.treesitter.language.add(language) then
        return false
      end
      vim.treesitter.start(buf, language)
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.wo.foldmethod = "expr"
      vim.o.foldlevel = 99
      if not skip_ts_indent[vim.bo[buf].filetype] then
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
      return true
    end

    local installable_parsers = require("nvim-treesitter").get_available()
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local buf, filetype = args.buf, args.match
        local language = vim.treesitter.language.get_lang(filetype)
        if not language then
          return
        end
        if not treesitter_try_attach(buf, language) then
          if vim.tbl_contains(installable_parsers, language) then
            require("nvim-treesitter").install(language):await(function()
              treesitter_try_attach(buf, language)
            end)
          end
        end
      end,
    })
  end,
}
