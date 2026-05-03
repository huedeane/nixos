{ inputs, configDir, username, ... }:

{
  sops = {
    defaultSopsFile = "./secrets.yaml";
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    secrets = {
      "github/username" = {};
      "github/email" = {};
      "github/key" = {};
      "chatgpt/key" = {};
    };
  };
}
