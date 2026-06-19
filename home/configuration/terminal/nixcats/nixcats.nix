{
  config,
  inputs,
  hostname,
  username,
  editMode,
  pkgs,
  ...
}:
let
  utils = inputs.nixCats.utils;
in
{
  home.packages = with pkgs; [
    nixfmt
  ];

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
            roslyn-ls
            dotnet-sdk

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
            nui-nvim
            nvim-notify
          ];

          lsp = with pkgs.vimPlugins; [
            roslyn-nvim
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
            nvim-web-devicons
            edgy-nvim
            which-key-nvim
            fzf-lua
            noice-nvim
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
            wrapRc = if editMode then false else true;
            unwrappedCfgPath = if editMode then "${config.home.homeDirectory}/.config/nixos/home/configuration/terminal/nixcats/nvim" else null;
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
