{ config, lib, editMode, ... }:
let
  yaziDir = "${config.home.homeDirectory}/.config/nixos/home/configuration/terminal/yazi";
  setting = {
    enable = true;
    enableBashIntegration = true;
    shellWrapperName = "f";
  };
in
{

  programs.yazi = setting // (if !editMode then { 
    initLua = ./init.lua;
    settings = builtins.fromTOML (builtins.readFile ./yazi.toml);
    keymap = builtins.fromTOML (builtins.readFile ./keymap.toml);
    theme = builtins.fromTOML (builtins.readFile ./theme.toml);
    plugins = {
      full-border = ./plugins/full-border.yazi;
      git = ./plugins/git.yazi;
    };
    flavors = {
      catppuccin-frappe = ./flavors/catppuccin-frappe.yazi;
    };
  } else {});

 xdg.configFile = if editMode then {
    "yazi/yazi.toml".source = config.lib.file.mkOutOfStoreSymlink "${yaziDir}/yazi.toml";
    "yazi/keymap.toml".source = config.lib.file.mkOutOfStoreSymlink "${yaziDir}/keymap.toml";
    "yazi/theme.toml".source = config.lib.file.mkOutOfStoreSymlink "${yaziDir}/theme.toml";
    "yazi/package.toml".source = config.lib.file.mkOutOfStoreSymlink "${yaziDir}/package.toml";
    "yazi/init.lua".source = config.lib.file.mkOutOfStoreSymlink "${yaziDir}/init.lua";
    "yazi/flavors/catppuccin-frappe.yazi".source = config.lib.file.mkOutOfStoreSymlink "${yaziDir}/flavors/catppuccin-frappe.yazi";
  } // lib.mapAttrs' (name: _: {
    name = "yazi/plugins/${name}";
    value.source = config.lib.file.mkOutOfStoreSymlink "${yaziDir}/plugins/${name}";
  }) (builtins.readDir ./plugins)
  else {};
 
  home.file.".local/bin/tree-directory.sh" = {
    source = ./scripts/tree-directory.sh;
    executable = true;
  };

  xdg.desktopEntries.yazi = {
    name = "Yazi";
    genericName = "File Manager";
    icon = "yazi";
    terminal = false;
    exec = "kitty --class tui-yazi yazi %f";
    type = "Application";
    mimeType = [ "inode/directory" ];
    categories = [ "System" "FileManager" "FileTools" "ConsoleOnly" "X-TUI" ];
    settings = {
      TryExec = "yazi";
      Keywords = "File;Manager;Explorer;Browser;Launcher;Tui";
    };
  };
}
