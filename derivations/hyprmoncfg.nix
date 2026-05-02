{ pkgs, ... }:

pkgs.buildGoModule {
  pname = "hyprmoncfg";
  version = "1.4.1";
  src = pkgs.fetchFromGitHub {
    owner = "crmne";
    repo = "hyprmoncfg";
    rev = "main";
    hash = "sha256-UWt/gFrdxR7bTvX2ArMDDkXPkc6+VjjaopFq/5aGq+o=";
  };
  vendorHash = "sha256-gQbjvdKtO0hCXrs9RnWo1s0YeHf5W9t+8AgS2ELXlPo=";
  subPackages = [
    "cmd/hyprmoncfg"
    "cmd/hyprmoncfgd"
  ];
}
