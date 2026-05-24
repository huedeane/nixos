{ config, lib, inputs, configDir, ... }: let
  utils = inputs.nixCats.utils;
in {
  nixCats = {
    enable = true;

    addOverlays = [ (utils.standardPluginOverlay inputs) ];

    packageNames = [ "nvim" ];

    luaPath = ./nvim;

    categoryDefinitions.replace = { pkgs, ... }: {
      startupPlugins = {};
      optionalPlugins = {};
      lspsAndRuntimeDeps = {};
    };

    packageDefinitions.replace = {
      nvim = { pkgs, ... }: {
        settings = {
          wrapRc  = false;
          aliases = [ "vim" ];
        };
        categories = {};
      };
    };
  };
}
