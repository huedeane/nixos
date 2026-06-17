{
  pkgs,
  config,
  editMode,
  ...
}:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/terminal/fzf";
in
{
  programs.nix-search-tv = {
    enable = true;
    settings.indexes = [
      "nixpkgs"
      "home-manager"
      "nixos"
    ];
  };

  home.packages = [
    (pkgs.writeShellApplication {
      name = "ns";
      runtimeInputs = with pkgs; [
        fzf
        nix-search-tv
        xdg-utils
      ];
      text =
        if editMode then
          config.lib.file.mkOutOfStoreSymlink "${dirPath}/scripts/nixpkgs.sh"
        else
          builtins.readFile ./scripts/nixpkgs.sh;
    })
  ];
}
