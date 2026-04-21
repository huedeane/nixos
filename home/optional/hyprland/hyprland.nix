{ config, hostname, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "EDITOR,nvim"
        "VISUAL,nvim"
        "PATH,$HOME/.local/bin:$PATH"
        "SUDO_ASKPASS,$HOME/.local/bin/rofi-askpass"
        "NIXOS_CONFIG,/home/huedeane/.config/nixos"
        "NIXOS_HOST,${hostname}"
      ];
    };

    extraConfig = builtins.readFile ./hyprland.conf;
  };

  services.hyprpaper = {
    enable = true;
  };
  
  home.file.".config/hypr/hyprpaper.conf".source = ./plugins/hyprpaper/hyprpaper.conf;
  home.file.".local/bin/nix-rebuild" = {
    source = ./scripts/nix-rebuild;
    executable = true;
  };
}
