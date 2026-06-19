{
  config,
  editMode,
  pkgs,
  ...
}:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/terminal/fzf";
in
{
  home.packages = with pkgs; [
    bat
    fd
    ripgrep
    file
    jq
  ];

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  xdg.configFile."fzf/fzfrc".source =
    if editMode then config.lib.file.mkOutOfStoreSymlink "${dirPath}/fzfrc" else ./fzfrc;

  home.file.".local/bin/fzf-preview.sh" = {
    source = ./scripts/fzf-preview.sh;
    executable = true;
  };
}
