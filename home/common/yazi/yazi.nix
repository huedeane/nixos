{ config, ... }:

{
  programs.yazi = {
    enable = true;

    shellWrapperName = "y";    
    settings = builtins.fromTOML (builtins.readFile ./yazi.toml);
    keymap = builtins.fromTOML (builtins.readFile ./keymap.toml);
    theme = builtins.fromTOML (builtins.readFile ./theme.toml);

    initLua = ./init.lua;

    plugins = {
      full-border = ./plugins/full-border.yazi;
      git = ./plugins/git.yazi;
    };
    
    flavors = {
      catppuccin-frappe = ./flavors/catppuccin-frappe.yazi;
    };
  };

  xdg.configFile = {
    "rmpc/package.toml".source = ./package.toml;
  };
}
