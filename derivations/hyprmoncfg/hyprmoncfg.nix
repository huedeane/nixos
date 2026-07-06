{ pkgs, ... }:

pkgs.buildGoModule {
  pname = "hyprmoncfg";
  version = "1.8.0";

  src = pkgs.fetchFromGitHub {
    owner = "crmne";
    repo = "hyprmoncfg";
    rev = "main";
    hash = "sha256-jAqLowsG024L16nDK4Vmb9sioVGB4zYU+CHO56IiSx0=";
  };

  vendorHash = "sha256-gQbjvdKtO0hCXrs9RnWo1s0YeHf5W9t+8AgS2ELXlPo=";

  subPackages = [
    "cmd/hyprmoncfg"
    "cmd/hyprmoncfgd"
  ];
}
