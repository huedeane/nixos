{
  pkgs,
  config,
  editMode,
  ...
}:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/terminal/nix-search-tv";
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
          ''
            exec bash "${dirPath}/scripts/nixpkgs.sh" "$@"
          ''
        else
          builtins.readFile ./scripts/nixpkgs.sh;
    })
  ];

  home.file.".local/bin/nixpkgs-add.sh" = {
    source = ./scripts/nixpkgs-add.sh;
    executable = true;
  };

  xdg.desktopEntries."ns" = {
    name = "Nix Package Manager";
    genericName = "Package Manager";
    exec = "kitty --class tui-ns -e ns";
    icon = "kitty";
    type = "Application";
    terminal = false;
    categories = [ "X-TUI" ];
    settings = {
      Keywords = "Git;Tui;Kitty;";
    };
  };
}
