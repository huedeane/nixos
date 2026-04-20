{ config, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hyprland.conf;
  };

  services.hyprpaper = {
    enable = true;
  };
  
  home.file.".config/hypr/hyprpaper.conf".source = ./plugin/hyprpaper/hyprpaper.conf;
  home.file.".local/bin/nix-rebuild" = {
    source = ./scripts/nix-rebuild;
    executable = true;
  };
}
