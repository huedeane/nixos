{
  lib,
  pkgs,
  config,
  editMode ? false,
  ...
}:

let
  catppuccin-custom = pkgs.runCommandLocal "obsidian-theme-catppuccin-custom" { } ''
    mkdir -p "$out"
    cp ${./themes/catppuccin-custom/manifest.json} "$out/manifest.json"
    cp ${./themes/catppuccin-custom/theme.css} "$out/theme.css"
  '';

  themeName = "Catppuccin Custom";
  vaultsBaseDir = "Documents/github/obsidian-vault";

  font = "ComicShannsMono Nerd Font Mono";

  repoDir = "${config.home.homeDirectory}/.config/nixos/home/configuration/application/obsidian";

  themeSource =
    if editMode then "${repoDir}/themes/catppuccin-custom" else "${catppuccin-custom}";

  pluginIds = [
    "sidebar-header-toggles"
    "css-hot-reload"
    "mode-indicator"
  ];

  mkPluginPkg =
    id:
    pkgs.runCommandLocal "obsidian-plugin-${id}" { } ''
      mkdir -p "$out"
      cp ${./plugins}/${id}/manifest.json "$out/manifest.json"
      cp ${./plugins}/${id}/main.js "$out/main.js"
    '';

  pluginSource = id: if editMode then "${repoDir}/plugins/${id}" else "${mkPluginPkg id}";

  installPlugins = lib.concatMapStringsSep "\n" (id: ''
    ln -sfn "${pluginSource id}" "$obs/plugins/${id}"
    cpj="$obs/community-plugins.json"
    cp_base="[]"
    [ -s "$cpj" ] && cp_base="$(cat "$cpj")"
    if printf '%s' "$cp_base" \
      | ${pkgs.jq}/bin/jq --arg id "${id}" \
          'if index($id) then . else . + [$id] end' > "$cpj.tmp" 2>/dev/null; then
      mv "$cpj.tmp" "$cpj"
    else
      rm -f "$cpj.tmp"
      echo "Obsidian: could not update $cpj (invalid JSON?), skipping"
    fi
  '') pluginIds;
in
{
  programs.obsidian.enable = true;

  home.activation.obsidianFrappe = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    themeSrc="${themeSource}"
    themeName="${themeName}"
    font="${font}"
    base="$HOME/${vaultsBaseDir}"

    if [ ! -d "$base" ]; then
      echo "Skipping Obsidian theme: $base not found"
    else
      for dir in "$base" "$base"/*/; do
        obs="$dir/.obsidian"
        [ -d "$obs" ] || continue

        mkdir -p "$obs/themes"
        ln -sfn "$themeSrc" "$obs/themes/$themeName"

        appearance="$obs/appearance.json"
        base_json="{}"
        if [ -s "$appearance" ]; then
          base_json="$(cat "$appearance")"
        elif [ -s "$appearance.backup" ]; then
          base_json="$(cat "$appearance.backup")"
        fi

        if printf '%s' "$base_json" \
          | ${pkgs.jq}/bin/jq --arg t "$themeName" --arg f "$font" \
              '.cssTheme = $t
               | .interfaceFontFamily = $f
               | .textFontFamily = $f
               | .monospaceFontFamily = $f' > "$appearance.tmp" 2>/dev/null; then
          mv "$appearance.tmp" "$appearance"
        else
          rm -f "$appearance.tmp"
          echo "Obsidian: could not update $appearance (invalid JSON?), skipping"
        fi

        mkdir -p "$obs/plugins"
        ${installPlugins}
      done
    fi
  '';
}
