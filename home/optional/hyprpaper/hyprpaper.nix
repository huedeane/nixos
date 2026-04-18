{ config, pkgs, ...}:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [ "${config.home.homeDirectory}/.config/nixos/home/resources/wallpaper.png" ];
      wallpaper = [ ", ${config.home.homeDirectory}/.config/nixos/home/resources/wallpaper.png" ];
    };
  };
}
