{ config, inputs, ... }:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "/home/huedeane/.config/sops/age/keys.txt";

    defaultSopsFile = ./secrets.yaml;
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";
    
    secrets = {
      "chatgpt/key".path = "${config.sops.defaultSymlinkPath}/chatgpt_key";
      "github/username".path = "${config.sops.defaultSymlinkPath}/github_username";
      "github/email".path = "${config.sops.defaultSymlinkPath}/github_email";
      "github/key".path = "${config.sops.defaultSymlinkPath}/github_key";
    };
  };
}
