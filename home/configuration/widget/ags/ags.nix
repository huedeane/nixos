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
  srcDir = "${config.home.homeDirectory}/.config/nixos/home/configuration/widget/ags/src";
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

  # Edit mode links ~/.config/ags straight to the repo's src, so edits apply on an ags restart
  xdg.configFile."ags".source = lib.mkIf editMode (config.lib.file.mkOutOfStoreSymlink srcDir);

  # A real directory left over from an older setup would block the link either way
  home.activation.agsBackup = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    if [ -d "${agsDir}" ] && [ ! -L "${agsDir}" ]; then
      run rm -rf "${agsDir}.backup"
      run mv "${agsDir}" "${agsDir}.backup"
    fi
  '';

  # Type definitions for the editor; node_modules is gitignored, so it stays out of builds
  home.activation.agsNodeModules = lib.mkIf editMode (
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run mkdir -p "${srcDir}/node_modules"
      run ln -sfn "${agsShare}" "${srcDir}/node_modules/ags"
      run ln -sfn "${agsShare}/node_modules/gnim" "${srcDir}/node_modules/gnim"
    ''
  );
}
