{ pkgs, configDir, ... }:
let
  clipvault = pkgs.callPackage "${configDir}/derivations/clipvault/clipvault.nix" { };
in
{
  home.packages = [ clipvault ];
}
