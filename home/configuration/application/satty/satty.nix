{
  config,
  lib,
  editMode,
  ...
}:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/application/satty";
in
{
  programs.satty = {
    enable = true;
    settings = lib.mkIf (!editMode) (fromTOML (builtins.readFile ./config.toml));
  };

  xdg.configFile."satty/config.toml" = lib.mkIf editMode {
    source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/config.toml";
  };
}
