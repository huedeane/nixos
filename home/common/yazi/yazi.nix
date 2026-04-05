{ config, ... }:

{
  programs.yazi = {
    enable = true;
    
    settings = builtins.fromTOML (builtins.readFile ./yazi.toml);
    keymap = builtins.fromTOML (builtins.readFile ./keymap.toml);
    theme = builtins.fromTOML (builtins.readFile ./theme.toml);

    initLua = ./init.lua;

    plugins = {
      full-border = ./yazi/plugins/full-border.yazi
      git = ./yazi/plugins/git.yazi
    };
    
    flavors = {
      catppuccin-frappe = ./yazi/flavors/catppuccin-frappe.yazi
    }
  };

  home.file.".config/yazi/package.toml".source = ./package.toml;
}
