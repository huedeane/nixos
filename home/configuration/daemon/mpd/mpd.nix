{ config, editMode, ... }:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/daemon/mpd";
  setting = {
    enable = true;
    network.startWhenNeeded = true;
    musicDirectory = "${config.home.homeDirectory}/Music"; 
    extraConfig = ''
      sticker_file "${dirPath}/etc/sticker.sql"
    '';
  };
in
{
  services.mpd = setting // (if !editMode then { 
    extraConfig = ''
      ${builtins.readFile ./mpd.conf}
      sticker_file "${dirPath}/etc/sticker.sql"
    '';
  } else {});

  xdg.configFile = if editMode then {
    "mpd/mpd.conf".source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/mpd.conf";
  } else {};
}
