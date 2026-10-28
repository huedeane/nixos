{ pkgs, ... }:

pkgs.buildGoModule {
  pname = "hyprmoncfg";
  version = "1.25.0";

  src = pkgs.fetchFromGitHub {
    owner = "crmne";
    repo = "hyprmoncfg";
    rev = "v1.25.0";
    hash = "sha256-d3UJm9EmfgmNplePs4V4v4WB4ptPNO1e4nmeO676PY8=";
  };

  vendorHash = "sha256-gQbjvdKtO0hCXrs9RnWo1s0YeHf5W9t+8AgS2ELXlPo=";

  subPackages = [
    "cmd/hyprmoncfg"
    "cmd/hyprmoncfgd"
  ];
}
