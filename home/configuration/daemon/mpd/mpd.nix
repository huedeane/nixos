{
  config,
  lib,
  pkgs,
  ...
}:
let
  mpdPartition = pkgs.writers.writePython3Bin "mpd-partition" {
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./scripts/mpd-partition.py);
  mpdSongChange = pkgs.writers.writePython3Bin "mpd-song-change" {
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./scripts/mpd-song-change.py);
in
{
  home.packages = [ mpdPartition ];

  services.mpd = {
    enable = true;
    network.startWhenNeeded = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    extraConfig = ''
      ${builtins.readFile ./mpd.conf}
      sticker_file "${config.services.mpd.musicDirectory}/sticker.sql"
    '';
  };

  # Socket clients can add files outside music_directory (e.g. /mnt/nas)
  home.sessionVariables.MPD_HOST = lib.mkForce "/run/user/1000/mpd/socket";

  services.mpd-mpris.enable = true;

  # mpd-mpris exits cleanly when mpd restarts, so on-failure never brings it back
  systemd.user.services.mpd-mpris.Service.Restart = lib.mkForce "always";

  systemd.user.services.mpd-partition = {
    Unit = {
      Description = "Pause other MPD partitions and move outputs to the one playing";
      After = [ "mpd.service" ];
      BindsTo = [ "mpd.service" ];
    };
    Service = {
      ExecStart = "${mpdPartition}/bin/mpd-partition watch";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "mpd.service" ];
  };

  # rmpc's on_song_change only fires while the TUI is open, so songs skipped from a
  # keybind or played with rmpc closed never got their playCount bumped
  systemd.user.services.mpd-song-change = {
    Unit = {
      Description = "Run the rmpc song-change script whenever MPD starts a new song";
      After = [ "mpd.service" ];
      BindsTo = [ "mpd.service" ];
    };
    Service = {
      ExecStart = "${mpdSongChange}/bin/mpd-song-change ${config.xdg.configHome}/rmpc/script/song-change.sh";
      Environment = "PATH=${
        lib.makeBinPath [
          config.programs.rmpc.package
          pkgs.jq
          pkgs.coreutils
          pkgs.bash
        ]
      }";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "mpd.service" ];
  };
}
