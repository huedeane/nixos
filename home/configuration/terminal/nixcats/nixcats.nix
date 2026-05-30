{
  inputs,
  hostname,
  username,
  ...
}:
let
  utils = inputs.nixCats.utils;
in
{
  nixCats = {
    enable = true;

    addOverlays = [ (utils.standardPluginOverlay inputs) ];
    packageNames = [ "nvim" ];
    luaPath = ./nvim;

    categoryDefinitions.replace =
      { pkgs, ... }:
      {
        lspsAndRuntimeDeps = {
          lsp = with pkgs; [
            # C#
            omnisharp-roslyn

            # Lua
            lua-language-server
            stylua

            # TOML
            taplo

            # CSS
            vscode-langservers-extracted

            # Nix
            nixd
            nil
            nixfmt

            # YAML
            yaml-language-server
          ];
        };

        startupPlugins = {
          general = with pkgs.vimPlugins; [
            lze
            lzextras
            catppuccin-nvim
          ];
        };

        optionalPlugins = {
          general = with pkgs.vimPlugins; [
            # vim-startuptime
            # lualine-lsp-progress
            lualine-nvim
            gitsigns-nvim
            blink-cmp
            nvim-treesitter.withAllGrammars
            neo-tree-nvim
            nui-nvim
            nvim-web-devicons
          ];

          lsp = with pkgs.vimPlugins; [
            nvim-lspconfig
          ];
        };

        environmentVariables = {

        };

        extraWrapperArgs = {

        };
      };

    packageDefinitions.replace = {
      nvim =
        { pkgs, ... }:
        {
          settings = {
            suffix-path = true;
            suffix-LD = true;
            wrapRc = true;
            aliases = [ "vim" ];
          };
          categories = {
            general = true;
            lsp = true;
          };
          extra = {
            nixdExtras.nixpkgs = "import ${pkgs.path} {}";
            nixdExtras.nixos_options = ''
              (builtins.getFlake "path:${inputs.self.outPath}").nixosConfigurations.${hostname}.options
            '';
            nixdExtras.home_manager_options = ''
              (builtins.getFlake "path:${inputs.self.outPath}").homeConfigurations.${username}.options
            '';
          };
        };
    };
  };
}
