{ config, editMode, ... }:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/daemon/dunst";
in
{
  services.dunst = {
    enable = true;
  };

  xdg.configFile =
    if editMode then
      {
        "dunst/dunstrc".source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/dunstrc";
      }
    else
      {
        "dunst/dunstrc".source = ./dunstrc;
      };
}
