{ pkgs, stdenvNoCC, lib }:
stdenvNoCC.mkDerivation {
  pname = "sddm-custom-theme";
  version = "1.0.0";
  src = lib.cleanSource ./theme;
  dontWrapQtApps = true;

  propagatedBuildInputs = with pkgs.kdePackages; [
    qtsvg
    qtmultimedia
    qtvirtualkeyboard
    qt5compat
  ];

  installPhase = let
    basePath = "$out/share/sddm/themes/sddm-custom-theme";
  in ''
    mkdir -p ${basePath}
    cp -r $src/* ${basePath}
  '';
}
