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

  # The Comic Shanns Mono (Nerd Font) weights referenced by the theme CSS,
  # bundled so the vault can carry its own font when synced to mobile.
  comicFont = pkgs.runCommandLocal "obsidian-comic-font" { } ''
    src=${pkgs.nerd-fonts.comic-shanns-mono}/share/fonts/opentype/NerdFonts/ComicShannsMono
    mkdir -p "$out"
    cp "$src/ComicShannsMonoNerdFontMono-Regular.otf" "$out/"
    cp "$src/ComicShannsMonoNerdFontMono-Bold.otf" "$out/"
  '';

  themeName = "Catppuccin Custom";
  vaultsBaseDir = "Documents/github/obsidian-vault";

  font = "ComicShannsMono Nerd Font Mono";

  repoDir = "${config.home.homeDirectory}/.config/nixos/home/configuration/application/obsidian";

  themeSource =
    if editMode then "${repoDir}/themes/catppuccin-custom" else "${catppuccin-custom}";

  # Edit mode: live symlink to the repo. Non-edit mode: wipe and copy real files
  # into the vault (so it syncs to mobile and isn't a dangling store symlink).
  themeInstall =
    if editMode then ''
      ln -sfn "$themeSrc" "$obs/themes/$themeName"
    ''
    else ''
      rm -rf "$obs/themes/$themeName"
      mkdir -p "$obs/themes/$themeName"
      cp -RL "$themeSrc"/. "$obs/themes/$themeName/"
      chmod -R u+w "$obs/themes/$themeName"
    '';

  # Only bundle the font in non-edit mode (the copy that syncs to mobile); in
  # edit mode the theme dir is a live symlink to the repo and the desktop
  # already resolves the font via fontconfig, so there's nothing to copy.
  fontInstall =
    if editMode then ""
    else ''
      rm -rf "$obs/themes/$themeName/fonts"
      mkdir -p "$obs/themes/$themeName/fonts"
      cp -RL "${comicFont}"/. "$obs/themes/$themeName/fonts/"
      chmod -R u+w "$obs/themes/$themeName/fonts"
    '';

  pluginIds = [
    "sidebar-header-toggles"
    "css-hot-reload"
    "mode-indicator"
    "nvim-edit-toggle"
  ];

  mkPluginPkg =
    id:
    pkgs.runCommandLocal "obsidian-plugin-${id}" { } ''
      mkdir -p "$out"
      cp -r ${./plugins}/${id}/. "$out/"
    '';

  pluginSource = id: if editMode then "${repoDir}/plugins/${id}" else "${mkPluginPkg id}";

  # Edit mode: live symlink to the repo. Non-edit mode: wipe and copy real files
  # into the vault, so the plugin isn't a dangling nix-store symlink off-NixOS
  # (Windows / mobile) — it syncs as a standalone folder.
  pluginInstall =
    id:
    if editMode then ''
      ln -sfn "${pluginSource id}" "$obs/plugins/${id}"
    ''
    else ''
      rm -rf "$obs/plugins/${id}"
      mkdir -p "$obs/plugins/${id}"
      cp -RL "${pluginSource id}"/. "$obs/plugins/${id}/"
      chmod -R u+w "$obs/plugins/${id}"
    '';

  installPlugins = lib.concatMapStringsSep "\n" (id: ''
    ${pluginInstall id}
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
        ${themeInstall}
        ${fontInstall}

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
