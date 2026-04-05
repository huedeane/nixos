{ config, ... }:

{
  programs.vesktop = {
    enable = true;

    vencord = {

      themes = {
        catppuccin = ./themes/system24-catppuccin-frappe.theme.css;
      };
    };
  };
}
