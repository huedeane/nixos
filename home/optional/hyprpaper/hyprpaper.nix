{ config, pkgs, ...}:

{
  services.hyprpaper = {
    enable = true;
    extraConfig = builtins.readFile ./hyprpaper.conf;
  };
}
