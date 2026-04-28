{ config, configHomeDir, ... }:

{
  services.mpd = {
    enable = true;

    musicDirectory = "${config.home.homeDirectory}/Music";
    playlistDirectory = "${config.home.homeDirectory}/Music/Playlist";
    dbFile = "${config.xdg.dataHome}/mpd/database";
    network.listenAddress = "any";
    network.startWhenNeeded = true;

    extraConfig = ''
      log_file     "${config.xdg.dataHome}/mpd/log"
      pid_file     "${config.xdg.dataHome}/mpd/pid"
      state_file   "${config.xdg.dataHome}/mpd/state"
      sticker_file "${configHomeDir}/daemon/mpd/etc/sticker.sql"

      auto_update             "yes"
      follow_outside_symlinks "yes"
      follow_inside_symlinks  "yes"

      bind_to_address "$XDG_RUNTIME_DIR/mpd/socket"

      audio_output {
        type "pulse"
        name "pulse audio"
      }

      audio_output {
        type "fifo"
        name "my_fifo"
        path "/tmp/mpd.fifo"
        format "44100:16:2"
      }
    '';
  };
}
