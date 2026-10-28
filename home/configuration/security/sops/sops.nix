{ config, inputs, ... }:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
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
