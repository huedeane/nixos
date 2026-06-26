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

  home.file.".local/bin/fzf-file.sh" = {
    source = ./scripts/fzf-file.sh;
    executable = true;
  };

  home.file.".local/bin/fzf-cheatsheet.sh" = {
    source = ./scripts/fzf-cheatsheet.sh;
    executable = true;
  };

  home.file.".local/bin/fzf-clipvault.sh" = {
    source = ./scripts/fzf-clipvault.sh;
    executable = true;
  };
}
