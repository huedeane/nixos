return {
  "nixd",
  enabled = nixCats('lsp') or false,
  lsp = {
    filetypes = { 'nix' },
    settings = {
      nixd = {
        nixpkgs = {
          expr = nixCats.extra("nixdExtras.nixpkgs") or [[import <nixpkgs> {}]],
        },
        options = {
          nixos = {
            expr = nixCats.extra("nixdExtras.nixos_options")
          },
          ["home-manager"] = {
            expr = nixCats.extra("nixdExtras.home_manager_options")
          }
        },
        formatting = {
          command = { "nixfmt" }
        },
        diagnostic = {
          suppress = {
            "sema-escaping-with"
          }
        }
      }
    },
  }
}
