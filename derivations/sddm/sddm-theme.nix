{
  pkgs,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "sddm-theme";
  version = "1.0.0";
  src = ./theme;
  dontWrapQtApps = true;

  propagatedBuildInputs = with pkgs.kdePackages; [
    qtsvg
    qtmultimedia
    qt5compat
  ];

  installPhase =
    let
      basePath = "$out/share/sddm/themes/sddm-theme";
    in
    ''
      mkdir -p ${basePath}
      cp -rv $src/. ${basePath}/
    '';
}
