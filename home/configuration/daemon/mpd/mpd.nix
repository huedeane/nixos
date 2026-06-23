{ config, ... }:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/daemon/mpd";
in
{
  services.mpd = {
    enable = true;
    network.startWhenNeeded = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    extraConfig = ''
      ${builtins.readFile ./mpd.conf}
      sticker_file "${dirPath}/etc/sticker.sql"
    '';
  };
}
