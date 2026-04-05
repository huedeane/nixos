{ lib, ... }:

{
  ExtensionSettings = with builtins; let
    extension = shortId: uuid: {
      name = uuid;
      value = {
        install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
        installation_mode = "force_installed";
      };
    };
  in
    listToAttrs [
      (extension "sidebery"                   "{3c078156-979c-498b-8990-85f7987dd929}")
      (extension "firefox-color"              "FirefoxColor@mozilla.com")
    ];
}
