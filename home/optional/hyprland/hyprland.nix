{ config, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hyprland.conf;
  };

  services.hyprpaper = {
    enable = true;
  };
  
  home.file.".config/hypr/hyprpaper.conf".source = ./hyprpaper.conf;
}
