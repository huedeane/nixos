{ config, pkgs, ... }:

let
  cmd-polkit = pkgs.stdenv.mkDerivation {
    pname = "cmd-polkit";
    version = "0.3.0";

    src = pkgs.fetchFromGitHub {
      owner = "OmarCastro";
      repo = "cmd-polkit";
      rev = "v0.3.0";
      sha256 = "sha256-oQaGV/ROP9YFyL8owduKOZLjqyx9D35xH67gNKECduQ=";
    };

    nativeBuildInputs = with pkgs; [ meson ninja pkg-config ];
    buildInputs = with pkgs; [ glib json-glib polkit gtk3 ];
  };
in
{
  home.packages = [ cmd-polkit ];

  home.file.".local/bin/rofi-polkit-agent" = {
    text = builtins.readFile ./rofi-polkit-agent;
    executable = true;
  };

  home.file.".local/bin/rofi-askpass" = {
    text = builtins.readFile ./rofi-askpass;
    executable = true;
  };

  systemd.user.services.cmd-polkit = {
    Unit = {
      Description = "cmd-polkit authentication agent";
      After = [ "graphical-session.target" ];
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "/home/huedeane/.local/bin/rofi-polkit-agent";
      Restart = "on-failure";
    };
  };
}
