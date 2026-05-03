{ inputs, configDir, username, ... }:

{
  sops = {
    defaultSopsFile = "../../../../secrets/secrets.yaml";
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
