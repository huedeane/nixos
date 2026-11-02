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
    let
      link =
        dir:
        lib.mapAttrs' (
          name: _:
          lib.nameValuePair "rmpc/${dir}/${name}" {
            source =
              if editMode then
                config.lib.file.mkOutOfStoreSymlink "${dirPath}/${dir}/${name}"
              else
                ./. + "/${dir}/${name}";
          }
        ) (lib.filterAttrs (_: type: type == "regular") (builtins.readDir (./. + "/${dir}")));
    in
    link "themes"
    // link "script"
    // lib.optionalAttrs editMode {
      "rmpc/config.ron".source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/config.ron";
    };

  home.file.".local/bin/rmpc-open.sh" = {
    source = ./rmpc-open.sh;
    executable = true;
  };

  xdg.desktopEntries."rmpc" = {
    name = "Rmpc";
    genericName = "Audio Player";
    exec = "${config.home.homeDirectory}/.local/bin/rmpc-open.sh %F";
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
