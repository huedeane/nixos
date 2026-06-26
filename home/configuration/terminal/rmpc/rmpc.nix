{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cava 
  ];

  programs.rmpc = {
    enable = true;

    config = builtins.readFile ./config.ron;
  };

  xdg.configFile = {
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
