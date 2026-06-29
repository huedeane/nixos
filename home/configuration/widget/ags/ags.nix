{
  inputs,
  pkgs,
  ...
}:
let
  astal = inputs.astal.packages.${pkgs.system};
in
{
  imports = [ inputs.ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;
    configDir = ./src;
    extraPackages = [
      astal.hyprland
      astal.apps
      astal.battery
      astal.bluetooth
      astal.mpris
      astal.network
      astal.notifd
      astal.powerprofiles
      astal.tray
      astal.wireplumber
    ];
  };
}
