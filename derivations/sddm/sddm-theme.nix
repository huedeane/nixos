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

  # Two themes from one QML source: "sddm-theme" (video background) and "sddm-theme-space"
  # (wallpaper background + lock screen palette), which only swaps theme.conf and the background
  installPhase =
    let
      themes = "$out/share/sddm/themes";
    in
    ''
      mkdir -p ${themes}/sddm-theme
      cp -rv $src/. ${themes}/sddm-theme/

      space=${themes}/sddm-theme-space
      mkdir -p $space
      cp -r $src/. $space/
      chmod -R u+w $space
      rm $space/Assets/bg.mp4
      cp ${../../resources/wallpaper.png} $space/Assets/bg.png
      cp ${./space/theme.conf} $space/theme.conf
      sed -i 's/^Name=.*/Name=Huedeane Space/; s/^Description=.*/Description=Huedeane SDDM Theme (space wallpaper)/' $space/metadata.desktop
    '';
}
