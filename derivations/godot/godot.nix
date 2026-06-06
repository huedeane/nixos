{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.godot;

  mkGodot =
    {
      mono ? false,
      sha256,
    }:
    let
      suffix = if mono then "-mono" else "";
      slug = if mono then "mono_linux_x86_64" else "linux.x86_64";

      runtimeLibs =
        with pkgs;
        [
          xorg.libX11
          xorg.libXcursor
          xorg.libXinerama
          xorg.libXrandr
          xorg.libXi
          xorg.libXext
          libGL
          alsa-lib
          libpulseaudio
          wayland
          systemd
          dbus
          fontconfig
          freetype
          zlib
          stdenv.cc.cc.lib
          libxkbcommon
        ]
        ++ lib.optionals mono [
          pkgs.dotnet-sdk_8
          pkgs.dotnet-runtime_8
        ];
    in
    pkgs.stdenv.mkDerivation {
      pname = "godot${suffix}";
      inherit (cfg) version;

      src = pkgs.fetchurl {
        url = "https://downloads.godotengine.org/?version=${cfg.version}&flavor=${cfg.flavor}&slug=${slug}.zip&platform=linux.64";
        inherit sha256;
        name = "godot${suffix}.zip";
      };

      nativeBuildInputs = with pkgs; [
        unzip
        autoPatchelfHook
        makeWrapper
      ];
      buildInputs = runtimeLibs;

      unpackPhase = ''
        mkdir src && cd src
        unzip $src
      '';

      configurePhase = lib.optionalString mono ''
        export DOTNET_ROOT="${pkgs.dotnet-sdk_8}"
        export PATH="${pkgs.dotnet-sdk_8}/bin:$PATH"
      '';

      installPhase = ''
        mkdir -p $out/bin $out/lib
        cp -r ./* $out/lib/
        godot_bin=$(find $out/lib -type f -name "Godot_*" | head -n 1)
        makeWrapper "$godot_bin" $out/bin/godot${suffix} \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}" \
          ${lib.optionalString mono ''
            --prefix PATH : "${lib.makeBinPath [ pkgs.dotnet-sdk_8 ]}" \
            --set DOTNET_ROOT "${pkgs.dotnet-sdk_8}"
          ''}
      '';

      meta = {
        description = "Godot Engine ${cfg.version} ${cfg.flavor}${suffix}";
        homepage = "https://godotengine.org";
        platforms = [ "x86_64-linux" ];
      };
    };
in
{
  options.programs.godot = {
    enable = lib.mkEnableOption "Godot game engine";

    settings = {
      version = lib.mkOption { type = lib.types.str; };
      flavor = lib.mkOption { type = lib.types.str; };
      type = lib.mkOption {
        type = lib.types.enum [
          "gdscript"
          "mono"
        ];
      };
      sha256 = lib.mkOption { type = lib.types.str; };
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages =
      if cfg.settings.type == "mono" then
        [
          (mkGodot {
            sha256 = cfg.settings.sha256;
            mono = true;
          })
          pkgs.dotnet-sdk_8
        ]
      else
        [ (mkGodot { sha256 = cfg.settings.sha256; }) ];
  };
}
