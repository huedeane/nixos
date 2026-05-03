{ username, ... }:

{
  sops = {
    defaultSopsFile = /home/${username}/.config/nixos/secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";

    secrets = {
      "github/username" = {};
      "github/email" = {};
      "github/key" = {};
      "chatgpt/key" = {};
    };
  };
}
