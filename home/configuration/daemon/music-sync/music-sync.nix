{ pkgs, ... }:
let
  # Writes rating stickers into the mp3s' POPM tags
  musicSyncPopm = pkgs.writers.writePython3Bin "music-sync-popm" {
    libraries = [ pkgs.python3Packages.mutagen ];
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./music-sync-popm.py);

  musicSync = pkgs.writeShellApplication {
    name = "music-sync";
    runtimeInputs = with pkgs; [
      musicSyncPopm
      unison
      sqlite
      socat
      libnotify
      util-linux
      coreutils
      systemd
    ];
    text = builtins.readFile ./music-sync.sh;
  };
in
{
  home.packages = [ musicSync ];

  # Sync ~/Music (songs + MPD sticker DB) with /mnt/nas/Music; skips when the NAS isn't mounted
  systemd.user.services.music-sync = {
    Unit.Description = "Sync ~/Music with the NAS";
    Service = {
      Type = "oneshot";
      ExecStart = "${musicSync}/bin/music-sync";
    };
  };

  systemd.user.timers.music-sync = {
    Unit.Description = "Sync ~/Music with the NAS periodically";
    Timer = {
      # Give the login NAS mount time to come up
      OnStartupSec = "3min";
      OnUnitActiveSec = "15min";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
