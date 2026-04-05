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
}
