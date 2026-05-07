{ pkgs, configDir, ... }:
let
  clipvault = pkgs.callPackage "${configDir}/derivations/clipvault.nix" { };
in
{
  home.packages = [ clipvault ];
}
  
