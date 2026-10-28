{ pkgs, username, ... }:

{
  environment.systemPackages = [ pkgs.cifs-utils ];

  # QNAP NAS (Nix-Nas, Shared folder) over CIFS. Device/credentials are
  # rendered by home-manager sops at system activation (see
  # home/configuration/security/sops/sops.nix), so the mount happens
  # after that unit, not via a hardcoded device string in this repo.
  systemd.services.mount-nas = {
    description = "Mount QNAP NAS Shared folder over CIFS";
    after = [
      "network-online.target"
      "home-manager-${username}.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "mount-nas-start" ''
        set -eu
        mkdir -p /mnt/nas
        device=$(cat /run/user/1000/secrets/qnap_device)
        ${pkgs.cifs-utils.bin}/bin/mount.cifs "$device" /mnt/nas \
          -o credentials=/run/user/1000/secrets/qnap_credentials,uid=1000,gid=100,vers=3.0
      '';
      ExecStop = "-${pkgs.util-linux}/bin/umount /mnt/nas";
    };
  };
}
