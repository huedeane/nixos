{ pkgs, config, username, ... }:

let
  # Device/credentials come from the home-manager sops config
  # (home/configuration/security/sops/sops.nix), decrypted at login.
  hmSops = config.home-manager.users.${username}.sops;
in
{
  environment.systemPackages = [ pkgs.cifs-utils ];

  # Started from the login session (see mount-nas-login below), not at boot.
  systemd.services.mount-nas = {
    description = "Mount QNAP NAS Shared folder over CIFS";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # The link can still be coming up at login (esp. Wi-Fi), so retry
      # until the NAS is reachable instead of failing once.
      TimeoutStartSec = "150s";
      ExecStart = pkgs.writeShellScript "mount-nas-start" ''
        set -u
        mkdir -p /mnt/nas
        ${pkgs.util-linux}/bin/mountpoint -q /mnt/nas && exit 0
        device=$(cat ${hmSops.secrets."qnap/device".path})
        for _ in $(seq 1 60); do
          ${pkgs.cifs-utils.bin}/bin/mount.cifs "$device" /mnt/nas \
            -o credentials=${hmSops.templates."qnap_credentials".path},uid=1000,gid=100,vers=3.0 \
            && exit 0
          sleep 2
        done
        echo "Failed to mount $device after 60 attempts" >&2
        exit 1
      '';
      ExecStop = "-${pkgs.util-linux}/bin/umount /mnt/nas";
    };
  };

  systemd.user.services.mount-nas-login = {
    description = "Mount QNAP NAS after login";
    wantedBy = [ "graphical-session.target" ];
    # sops-nix (home-manager) decrypts the qnap secrets at login.
    after = [
      "graphical-session.target"
      "sops-nix.service"
    ];
    wants = [ "sops-nix.service" ];
    unitConfig.ConditionUser = username;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl start --no-block mount-nas.service";
    };
  };

  # Let the user start/stop mount-nas.service without a password prompt.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "mount-nas.service" &&
          subject.user == "${username}") {
        return polkit.Result.YES;
      }
    });
  '';
}
