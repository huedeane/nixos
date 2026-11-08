{
  config,
  lib,
  inputs,
  withSecrets,
  ...
}:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  # Blank age key placeholder; fill it in and rebuild to enable secrets
  home.activation.ensureSopsKeyFile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="${config.home.homeDirectory}/.config/sops/age/keys.txt"
    if [ ! -e "$target" ]; then
      mkdir -p -m 700 "$(dirname "$target")"
      touch "$target"
      chmod 600 "$target"
    fi
  '';

  # withSecrets = false (flake.nix) disables sops-nix entirely: no service, no activation
  sops = lib.mkIf withSecrets {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = ./secrets.yaml;
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";

    secrets = {
      "github/username".path = "${config.sops.defaultSymlinkPath}/github_username";
      "github/email".path = "${config.sops.defaultSymlinkPath}/github_email";
      "github/key".path = "${config.sops.defaultSymlinkPath}/github_key";
      "qnap/username" = { };
      "qnap/password" = { };
      "qnap/device".path = "${config.sops.defaultSymlinkPath}/qnap_device";
    };

    templates."qnap_credentials" = {
      path = "${config.sops.defaultSymlinkPath}/qnap_credentials";
      content = ''
        username=${config.sops.placeholder."qnap/username"}
        password=${config.sops.placeholder."qnap/password"}
      '';
    };
  };
}
