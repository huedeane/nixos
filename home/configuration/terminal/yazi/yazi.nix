{
  config,
  lib,
  editMode,
  ...
}:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/terminal/yazi";
  setting = {
    enable = true;
    enableBashIntegration = true;
    shellWrapperName = "f";
  };
in
{

  programs.yazi =
    setting
    // (
      if !editMode then
        {
          initLua = ./init.lua;
          settings = fromTOML (builtins.readFile ./yazi.toml);
          keymap = fromTOML (builtins.readFile ./keymap.toml);
          theme = fromTOML (builtins.readFile ./theme.toml);
          plugins = {
            full-border = ./plugins/full-border.yazi;
            git = ./plugins/git.yazi;
            custom-mode = ./plugins/custom-mode.yazi;
          };
          flavors = {
            catppuccin-frappe = ./flavors/catppuccin-frappe.yazi;
          };
        }
      else
        { }
    );

  xdg.configFile = lib.mkMerge [
    {
      "xdg-desktop-portal-termfilechooser/config".text = ''
        [filechooser]
        cmd=${config.home.homeDirectory}/.local/bin/yazi-wrapper.sh
        default_dir=$HOME
        open_mode=suggested
        save_mode=last
      '';
    }
    (lib.optionalAttrs editMode (
      {
        "yazi/yazi.toml".source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/yazi.toml";
        "yazi/keymap.toml".source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/keymap.toml";
        "yazi/theme.toml".source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/theme.toml";
        "yazi/package.toml".source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/package.toml";
        "yazi/init.lua".source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/init.lua";
        "yazi/flavors/catppuccin-frappe.yazi".source =
          config.lib.file.mkOutOfStoreSymlink "${dirPath}/flavors/catppuccin-frappe.yazi";
      }
      // lib.mapAttrs' (name: _: {
        name = "yazi/plugins/${name}";
        value.source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/plugins/${name}";
      }) (builtins.readDir ./plugins)
    ))
  ];

  home.file.".local/bin/tree-directory.sh" = {
    source = ./scripts/tree-directory.sh;
    executable = true;
  };

  home.file.".local/bin/yazi-wrapper.sh" = {
    source = ./scripts/yazi-wrapper.sh;
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
    categories = [
      "System"
      "FileManager"
      "FileTools"
      "ConsoleOnly"
      "X-TUI"
    ];
    settings = {
      TryExec = "yazi";
      Keywords = "File;Manager;Explorer;Browser;Launcher;Tui";
    };
  };
}
