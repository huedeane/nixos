{ config, lib, inputs, configDir, ... }: let
  utils = inputs.nixCats.utils;
in {
  nixCats = {
    enable = true;

    addOverlays = [ (utils.standardPluginOverlay inputs) ];
    packageNames = [ "nvim" ];
    luaPath = ./nvim;

    categoryDefinitions.replace = { pkgs, ... }: {
      startupPlugins = {
          general = with pkgs.vimPlugins; [  
            lze
            lzextras
            catppuccin-nvim
          ];
        };
      optionalPlugins = {
        general = with pkgs.vimPlugins; [
          nvim-lspconfig
          vim-startuptime
          lualine-nvim
          lualine-lsp-progress
          gitsigns-nvim
        ];
      };
      lspsAndRuntimeDeps = {};
    };

    packageDefinitions.replace = {
      nvim = { pkgs, ... }: {
        settings = {
          wrapRc  = true;
          aliases = [ "vim" ];
        };
        categories = {
          general = true;

        };
      };
    };
  };
}
