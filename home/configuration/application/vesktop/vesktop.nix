{ config, lib, configHomeDir, ... }:

{
  programs.vesktop = {
    enable = true;

    vencord = {
      extraQuickCss = builtins.readFile ./settings/quickCss.css;
      themes = {
        catppuccin = builtins.readFile ./themes/system24-catppuccin-frappe.theme.css;
      };
    };
  };

  home.activation.vencordSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ln -sf "${configHomeDir}/application/vesktop/settings/settings.json" \
    "${config.xdg.configHome}/vesktop/settings/settings.json"
  '';
}
