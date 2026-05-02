{ config, ... }:

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    shellWrapperName = "f";

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
      Keywords = "File;Manager;Explorer;Browser;Launcher;";
    };
  };
}
