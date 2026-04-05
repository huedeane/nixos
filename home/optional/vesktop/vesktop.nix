{ config, lib, ... }:

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
    ln -sf "$HOME/.config/nixos/home/optional/vesktop/settings/settings.json" \
    "$HOME/.config/vesktop/settings/settings.json"
  '';
}
