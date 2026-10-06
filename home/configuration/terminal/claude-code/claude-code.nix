{
  config,
  lib,
  editMode,
  ...
}:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/terminal/claude-code";

  # Point ~/.claude/<rel> at the live source in this repo (edit mode only).
  editSource = rel: {
    source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/${rel}";
  };

  # Turn ./output-styles/*.md into the attrset shape `outputStyles` expects
  # ({ <name> = <path>; }). There is no `outputStylesDir` option upstream, so
  # we build it from the directory ourselves.
  mkOutputStyles =
    dir:
    lib.optionalAttrs (builtins.pathExists dir) (
      lib.mapAttrs' (name: _: lib.nameValuePair (lib.removeSuffix ".md" name) (dir + "/${name}")) (
        lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".md" n) (builtins.readDir dir)
      )
    );

  # Options that don't map to editable files on disk, so they're identical in both modes.
  commonSettings = {
    enable = true;

    # Directory holding Claude Code's config. Leave as the ~/.claude default.
    # configDir = "${config.xdg.configHome}/claude";

    # Merge programs.mcp.servers into Claude Code's MCP config (needs programs.mcp.enable).
    enableMcpIntegration = false;

    # MCP servers -> written to the wrapper's .mcp.json. Example:
    #   github = { type = "http"; url = "https://api.githubcopilot.com/mcp/"; };
    mcpServers = { };

    # LSP servers -> written to .lsp.json. Example:
    #   go = { command = "gopls"; args = [ "serve" ]; extensionToLanguage.".go" = "go"; };
    lspServers = { };

    # Extra plugins (paths or packages), enabled via --plugin-dir.
    plugins = [ ];

    # Custom plugin marketplaces (name -> path/package).
    marketplaces = { };
  };

  # Options backed by files/dirs in this repo. In normal mode they're baked into
  # the Nix store via the module; in edit mode they're symlinked live (see home.file
  # below) so the module must not also manage them. Each dir-backed option only
  # wires up when the sibling path exists, so you can add e.g. ./agents later and
  # have it picked up without touching this file.
  fileSettings = lib.optionalAttrs (!editMode) (
    {
      settings = builtins.fromJSON (builtins.readFile ./settings.json);
      outputStyles = mkOutputStyles ./output-styles;
    }
    // lib.optionalAttrs (builtins.pathExists ./CLAUDE.md) { context = ./CLAUDE.md; }
    // lib.optionalAttrs (builtins.pathExists ./agents) { agentsDir = ./agents; }
    // lib.optionalAttrs (builtins.pathExists ./commands) { commandsDir = ./commands; }
    // lib.optionalAttrs (builtins.pathExists ./hooks) { hooksDir = ./hooks; }
    // lib.optionalAttrs (builtins.pathExists ./rules) { rulesDir = ./rules; }
    // lib.optionalAttrs (builtins.pathExists ./skills) { skills = ./skills; }
  );
in
{
  programs.claude-code = commonSettings // fileSettings;

  # Edit mode: symlink ~/.claude/* straight to this repo so changes take effect
  # without a rebuild. Only wire entries whose source actually exists.
  home.file = lib.optionalAttrs editMode (
    { ".claude/settings.json" = editSource "settings.json"; }
    // lib.optionalAttrs (builtins.pathExists ./CLAUDE.md) {
      ".claude/CLAUDE.md" = editSource "CLAUDE.md";
    }
    // lib.optionalAttrs (builtins.pathExists ./agents) { ".claude/agents" = editSource "agents"; }
    // lib.optionalAttrs (builtins.pathExists ./commands) { ".claude/commands" = editSource "commands"; }
    // lib.optionalAttrs (builtins.pathExists ./hooks) { ".claude/hooks" = editSource "hooks"; }
    // lib.optionalAttrs (builtins.pathExists ./rules) { ".claude/rules" = editSource "rules"; }
    // lib.optionalAttrs (builtins.pathExists ./skills) { ".claude/skills" = editSource "skills"; }
    // lib.optionalAttrs (builtins.pathExists ./output-styles) {
      ".claude/output-styles" = editSource "output-styles";
    }
  );
}
