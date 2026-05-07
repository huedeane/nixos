{ pkgs, ... }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "clipvault";
  version = "1.1.1";

  src = pkgs.fetchFromGitHub {
    owner = "rolv-apneseth";
    repo = "clipvault";
    rev = "main";
    hash = "0bikhxpqg0cabl2n2zhg97gkc1fsfjx763d7nhn595hlfcfywi48";
  };

  cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
}
