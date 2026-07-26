local function lsp_on_attach(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>lr', vim.lsp.buf.rename, '[R]ename')
  nmap('<leader>lca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('<leader>lgd', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>lgD', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('<leader>ltd', vim.lsp.buf.type_definition, '[T]ype [D]efinition')
  nmap('<leader>ldh', vim.lsp.buf.hover, '[D]ocumentation [H]over')
  nmap('<leader>lds', vim.lsp.buf.signature_help, '[D]ocumentation [S]ignature')
  nmap('<leader>lwa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>lwr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>lwl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')
  nmap('<leader>lgr', vim.lsp.buf.references, '[G]oto [R]eferences')
  nmap('<leader>lgi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>lsd', vim.lsp.buf.document_symbol, '[S]ymbols [D]ocument')
  nmap('<leader>lsw', vim.lsp.buf.workspace_symbol, '[S]ymbols [W]orkspace')
  nmap('<leader>le', vim.diagnostic.open_float, '[E]rror/diagnostic Float')
  nmap('<leader>lq', vim.diagnostic.setloclist, '[Q]uickfix Diagnostics')
  nmap('<leader>lf', function() vim.lsp.buf.format({ async = true }) end, '[F]ormat')

  nmap('<leader>lls', function()
    for _, c in pairs(vim.lsp.get_clients()) do c:stop() end
  end, '[L]SP [S]top All Clients')

  nmap('<leader>llr', function()
    vim.cmd('edit') -- re-triggers attach for the current buffer
  end, '[L]SP [R]estart Clients')

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

return {
  {
    "nvim-lspconfig",
    enabled = nixCats("lsp") or false,
    on_require = { "lspconfig" },
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
    before = function(_)
      vim.lsp.config('*', {
        on_attach = lsp_on_attach,
      })
    end,
  },
}
