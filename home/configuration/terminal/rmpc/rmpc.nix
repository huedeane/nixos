{ config, ... }:

{ 
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
    exec = "kitty --class tui-rmpc -e queue-rmpc %f";
    icon = "kitty";
    terminal = false;
    categories = [ "Audio" ];
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
