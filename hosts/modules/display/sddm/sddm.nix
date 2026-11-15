{
  config,
  pkgs,
  username,
  ...
}:
let
  sddm-theme = pkgs.callPackage ../../../../derivations/sddm/sddm-theme.nix { };
  # Same cursor as the session (home/configuration/appearance/pointer)
  cursor = config.home-manager.users.${username}.home.pointerCursor;
in
{
  environment.systemPackages = [
    sddm-theme
    cursor.package
  ];

  systemd.services.display-manager.environment = {
    QML_DISABLE_DISK_CACHE = "1";
    # The greeter's Weston only knows its built-in paths, none of which exist on NixOS,
    # so it had no cursor theme at all and drew no pointer
    XCURSOR_PATH = "/run/current-system/sw/share/icons";
  };

  services.displayManager = {
    sddm = {
      wayland.enable = true;
      enable = true;
      package = pkgs.kdePackages.sddm;

      # "sddm-theme" (video background) or "sddm-theme-space" (wallpaper + lock screen colours)
      theme = "sddm-theme-space";
      extraPackages = with pkgs; [
        sddm-theme
      ];
      settings.Theme = {
        CursorTheme = cursor.name;
        CursorSize = 36;
      };
    };
    autoLogin = {
      enable = false;
      user = "${username}";
    };
  };
}
