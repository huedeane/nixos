{ config, ... }:

{
  programs.yazi = {
    enable = true;
    
    theme = {
      flavor = {
        dark = "catppuccin-frappe";
      };
    };
  };

  home.file.".config/yazi/init.lua".source = ./init.lua;
  home.file.".config/yazi/keymap.toml".source = ./keymap.toml;
  home.file.".config/yazi/package.toml".source = ./package.toml;
  home.file.".config/yazi/yazi.toml".source = ./yazi.toml;
  home.file.".config/yazi/flavors".source = ./flavors;
  home.file.".config/yazi/plugins".source = ./plugins;
}
