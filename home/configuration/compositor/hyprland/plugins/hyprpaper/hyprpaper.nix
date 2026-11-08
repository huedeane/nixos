{ config, configDir, lib, ... }:
let
  wallpaper = "${configDir}/resources/wallpaper.png";
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [ wallpaper ];
      wallpaper = [
        {
          monitor = "";
          path = wallpaper;
          fit_mode = "cover";
        }
      ];
    };
  };

  # Started by the ags startup fade instead
  systemd.user.services.hyprpaper.Install.WantedBy = lib.mkForce [ ];
}
