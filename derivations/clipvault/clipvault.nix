{ pkgs, ... }:

pkgs.rustPlatform.buildRustPackage {
  pname = "clipvault";
  version = "1.1.1";

  doCheck = false;

  src = pkgs.fetchFromGitHub {
    owner = "rolv-apneseth";
    repo = "clipvault";
    rev = "17da6b69dabd9f8e0fa8e35b71cf81f9a396599e";
    hash = "sha256-iETuHXMUllQstKcNc7p02gU230kPfmEFXYqBh2+HMy4=";
  };

  cargoHash = "sha256-hmr3N/K+cj87OQDoCz2G4vWoNByRfh78rd0BtGJN1hA=";
}
