{ lib, ... }:

# https://mozilla.github.io/policy-templates/
{
  ExtensionSettings = with builtins; let
    extension = shortId: uuid: privateAccess: {
      name = uuid;
      value = {
        install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
        installation_mode = "normal_installed";
        private_browsing = privateAccess;
      };
    };
  in
    listToAttrs [
      (extension "sidebery"                   "{3c078156-979c-498b-8990-85f7987dd929}"  true)
      (extension "firefox-color"              "FirefoxColor@mozilla.com"                true)
      (extension "vimium-ff"                  "{d7742d87-e61d-4b78-b8a1-b469842139fa}"  true)
    ];
}
