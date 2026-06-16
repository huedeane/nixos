{ pkgs, ... }:

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
      text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
    })
  ];
}
