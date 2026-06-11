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
      version,
      flavor,
    }:
    let
      suffix = if mono then "-mono" else "";
      slug = if mono then "mono_linux_x86_64" else "linux.x86_64";
      runtimeLibs =
        with pkgs;
        [
          libX11
          libXcursor
          libXinerama
          libXrandr
          libXi
          libXext
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
      inherit version;
      src = pkgs.fetchurl {
        url = "https://downloads.godotengine.org/?version=${version}&flavor=${flavor}&slug=${slug}.zip&platform=linux.64";
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
        description = "Godot Engine ${version} ${flavor}${suffix}";
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
        default = "gdscript";
      };
      sha256 = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      let
        packages =
          if cfg.settings.type == "mono" then
            [
              (mkGodot {
                inherit (cfg.settings) sha256 flavor version;
                mono = true;
              })
              pkgs.dotnet-sdk_8
            ]
          else
            [
              (mkGodot {
                inherit (cfg.settings) sha256 flavor version;
              })
            ];
      in
      packages;
  };
}
