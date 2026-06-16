{
  config,
  editMode,
  ...
}:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/terminal/fzf";
in
{
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  home.sessionVariables.FZF_DEFAULT_OPTS_FILE = "${config.xdg.configHome}/fzf/fzfrc";

  xdg.configFile."fzf/fzfrc".source =
    if editMode then
      config.lib.file.mkOutOfStoreSymlink "${dirPath}/fzfrc"
    else
      ./fzfrc;
}
