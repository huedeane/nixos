{ config, editMode, ... }:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/application/vesktop";
  setting = {
    enable = true;
  };
in
{

  programs.vesktop = setting // (if !editMode then { 
    settings = builtins.fromJSON (builtins.readFile ./settings.json);
    vencord = {
      settings = builtins.fromJSON (builtins.readFile ./settings/settings.json);
      extraQuickCss = builtins.readFile ./settings/quickCss.css;
      themes = {
        catppuccin = builtins.readFile ./themes/system24-catppuccin-frappe.theme.css;
      };
    };
  } else {});

 xdg.configFile = if editMode then {
    "vesktop/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/settings.json";
    "vesktop/settings/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/settings/settings.json";
    "vesktop/settings/quickCss.css".source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/settings/quickCss.css";
    "vesktop/themes/system24-catppuccin-frappe.theme.css".source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/themes/system24-catppuccin-frappe.theme.css";
  } else {};
}
