{
  inputs,
  pkgs,
  lib,
  config,
  editMode,
  ...
}:
let
  astal = inputs.astal.packages.${pkgs.stdenv.hostPlatform.system};
  agsDir = "${config.xdg.configHome}/ags";
  agsShare = "${config.home.homeDirectory}/.local/share/ags";
in
{
  imports = [ inputs.ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;
    configDir = if editMode then null else ./src;
    extraPackages = [
      astal.hyprland
      astal.apps
      astal.battery
      astal.bluetooth
      astal.cava
      astal.mpris
      astal.network
      astal.notifd
      astal.powerprofiles
      astal.tray
      astal.wireplumber
    ];
  };

  home.activation.agsConfig =
    if editMode then
      lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        if [ -L "${agsDir}" ] || [ ! -e "${agsDir}" ]; then
          run rm -f "${agsDir}"
          run cp -r --no-preserve=mode ${./src} "${agsDir}"
          run mkdir -p "${agsDir}/node_modules"
          run ln -sfn "${agsShare}" "${agsDir}/node_modules/ags"
          run ln -sfn "${agsShare}/node_modules/gnim" "${agsDir}/node_modules/gnim"
        fi
      ''
    else
      lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
        if [ -d "${agsDir}" ] && [ ! -L "${agsDir}" ]; then
          run rm -rf "${agsDir}.backup"
          run mv "${agsDir}" "${agsDir}.backup"
        fi
      '';
}
