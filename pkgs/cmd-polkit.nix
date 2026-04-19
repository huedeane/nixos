{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "cmd-polkit";
  version = "0.3.0";

  src = pkgs.fetchFromGitHub {
    owner = "OmarCastro";
    repo = "cmd-polkit";
    rev = "v0.3.0";
    sha256 = pkgs.lib.fakeSha256;
  };

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
  ];

  buildInputs = with pkgs; [
    glib
    json-glib
    polkit
    gtk3
  ];
}
