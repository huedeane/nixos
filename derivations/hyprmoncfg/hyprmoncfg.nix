{ pkgs, ... }:

pkgs.buildGoModule {
  pname = "hyprmoncfg";
  version = "1.8.0";

  src = pkgs.fetchFromGitHub {
    owner = "crmne";
    repo = "hyprmoncfg";
    rev = "main";
    hash = "sha256-omdfR2D5Z1cs8EpQ4ssxdL/Kft5JThqx7irGHDSqGLc=";
  };

  vendorHash = "sha256-gQbjvdKtO0hCXrs9RnWo1s0YeHf5W9t+8AgS2ELXlPo=";

  subPackages = [
    "cmd/hyprmoncfg"
    "cmd/hyprmoncfgd"
  ];
}
