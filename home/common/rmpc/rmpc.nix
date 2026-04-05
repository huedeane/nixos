{ config, ... }:

{
  programs.rmpc = {
    enable = true;
  };

  home.file.".config/rmpc/config.ron".source = ./config.ron;
  home.file.".config/rmpc/themes".source = ./themes;
  home.file.".config/rmpc/script".source = ./script;
}
