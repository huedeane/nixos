{ config, pkgs, ... }:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/daemon/mpd";
  mpdPartition = pkgs.writers.writePython3Bin "mpd-partition" {
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./scripts/mpd-partition.py);
in
{
  home.packages = [ mpdPartition ];

  services.mpd = {
    enable = true;
    network.startWhenNeeded = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    extraConfig = ''
      ${builtins.readFile ./mpd.conf}
      sticker_file "${dirPath}/etc/sticker.sql"
    '';
  };

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
}
