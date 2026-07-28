{
  pkgs,
  lib,
  editMode,
  config,
  ...
}:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/terminal/rmpc";
  setting = {
    enable = true;
  };
in
{
  home.packages = with pkgs; [
    cava
  ];

  programs.rmpc =
    setting
    // (
      if !editMode then
        {
          config = builtins.readFile ./config.ron;
        }
      else
        { }
    );

  xdg.configFile =
    if editMode then
      lib.mapAttrs' (
        name: _:
        lib.nameValuePair "rmpc/themes/${name}" {
          source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/themes/${name}";
        }
      ) (lib.filterAttrs (_: type: type == "regular") (builtins.readDir ./themes))
      // lib.mapAttrs' (
        name: _:
        lib.nameValuePair "rmpc/script/${name}" {
          source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/script/${name}";
        }
      ) (lib.filterAttrs (_: type: type == "regular") (builtins.readDir ./script))
      // {
        "rmpc/config.ron".source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/config.ron";
      }
    else
      {
        "rmpc/themes".source = ./themes;
        "rmpc/script".source = ./script;
      };

  xdg.desktopEntries."rmpc" = {
    name = "Rmpc";
    genericName = "Audio Player";
    exec = "kitty --class tui-rmpc rmpc";
    icon = "kitty";
    terminal = false;
    categories = [
      "Audio"
      "X-TUI"
    ];
    type = "Application";
    mimeType = [
      "audio/mpeg"
      "audio/flac"
      "audio/ogg"
      "audio/wav"
      "audio/x-flac"
      "audio/mp4"
    ];
    settings = {
      Keywords = "Audio;Music;Player;Tui;";
    };
  };
}
