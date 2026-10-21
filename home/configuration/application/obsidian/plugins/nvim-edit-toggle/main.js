const { Plugin, Notice, setIcon, FileView } = require("obsidian");
const fs = require("fs");
const path = require("path");
const os = require("os");

const TERMINAL_PLUGIN_ID = "terminal";
const TARGET_FILE = path.join(process.env.XDG_RUNTIME_DIR || os.tmpdir(), "obsidian-nvim-target");
const NVIM_VIEW_TYPE = "nvim-edit-redirect";

// Text/code extensions that Obsidian can't display natively (so it would hand
// them to the OS / browser). Images, md, canvas, pdf, audio, video are left
// alone. Extensionless files (Makefile, Dockerfile) can't be registered.
const EXTENSIONS = [
  "json", "jsonc", "js", "mjs", "cjs", "ts", "tsx", "jsx",
  "css", "scss", "sass", "less",
  "html", "htm", "xml", "xhtml",
  "yaml", "yml", "toml", "ini", "cfg", "conf", "properties", "env",
  "sh", "bash", "zsh", "fish", "ps1", "bat",
  "lua", "vim",
  "py", "rb", "pl", "php",
  "go", "rs", "c", "h", "cpp", "hpp", "cc", "cxx", "java", "kt", "kts", "swift", "cs",
  "sql", "graphql", "gql",
  "txt", "log", "csv", "tsv",
  "nix", "diff", "patch",
  "tex", "bib",
  "r", "jl", "dart", "scala", "clj", "ex", "exs", "erl", "hs", "ml",
];

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

class NvimRedirectView extends FileView {
  constructor(leaf, plugin) {
    super(leaf);
    this.plugin = plugin;
  }
  getViewType() {
    return NVIM_VIEW_TYPE;
  }
  getDisplayText() {
    return this.file ? this.file.basename : "Neovim";
  }
  async onLoadFile(file) {
    // Don't spawn terminals while the workspace is restoring on startup.
    if (!this.plugin.app.workspace.layoutReady) {
      this.leaf.detach();
      return;
    }
    if (this.plugin.app.plugins.plugins[TERMINAL_PLUGIN_ID]) {
      await this.plugin.launchNvim(file, null);
    } else if (typeof this.plugin.app.openWithDefaultApp === "function") {
      // No terminal here — behave like Obsidian did (hand off to the OS).
      this.plugin.app.openWithDefaultApp(file.path);
    }
    this.leaf.detach();
  }
  async onUnloadFile() {}
}

module.exports = class NvimEditToggle extends Plugin {
  onload() {
    // filePath -> { termLeaf, sourceLeaf }
    this.sessions = new Map();
    this.apply = this.apply.bind(this);

    this.addCommand({
      id: "close-return",
      name: "Close Neovim and return to note",
      checkCallback: (checking) => {
        const entry = this.sessionForLeaf(this.app.workspace.activeLeaf);
        if (!entry) return false;
        if (!checking) this.closeSession(entry.key);
        return true;
      },
    });

    // Open non-image text/code files in nvim instead of the browser — but only
    // in vaults where the Terminal plugin exists (checked once layout is ready,
    // so plugin load order doesn't matter). Elsewhere, leave the default
    // browser/OS handling untouched.
    this.registerView(NVIM_VIEW_TYPE, (leaf) => new NvimRedirectView(leaf, this));

    this.app.workspace.onLayoutReady(() => {
      this.apply();
      if (!this.app.plugins.plugins[TERMINAL_PLUGIN_ID]) return;
      for (const ext of EXTENSIONS) {
        try {
          this.registerExtensions([ext], NVIM_VIEW_TYPE);
        } catch (e) {
          // extension already claimed by another plugin/core — skip it
        }
      }
    });
    this.registerEvent(this.app.workspace.on("active-leaf-change", this.apply));
    this.registerEvent(this.app.workspace.on("layout-change", this.apply));
  }

  apply() {
    const leaf = this.app.workspace.activeLeaf;
    const view = leaf && leaf.view;
    if (view && view.getViewType && view.getViewType() === "markdown") {
      this.addNoteButton(view);
    }
    for (const [key, s] of this.sessions) {
      if (s.termLeaf && s.termLeaf.view) this.addBackButton(s.termLeaf.view, key);
    }
  }

  // --- Note side: toggle button in the markdown view header -----------------

  addNoteButton(view) {
    const actions = view.containerEl && view.containerEl.querySelector(".view-header .view-actions");
    if (!actions) return;
    let btn = actions.querySelector(".nvim-edit-toggle");
    if (!btn) {
      btn = createEl("button", { cls: "clickable-icon view-action nvim-edit-toggle" });
      setIcon(btn, "terminal");
      btn.addEventListener("click", (e) => {
        e.preventDefault();
        this.toggle(view);
      });
      actions.prepend(btn);
    }
    const rightToggle = actions.querySelector(".hdr-sidebar-toggle.mod-right");
    if (rightToggle && rightToggle.nextElementSibling !== btn) {
      rightToggle.insertAdjacentElement("afterend", btn);
    }
    const open = view.file && this.sessions.has(view.file.path);
    btn.toggleClass("is-active", !!open);
    btn.setAttribute("aria-label", open ? "Close Neovim" : "Edit in Neovim");
  }

  // --- Terminal side: "return to note" button -------------------------------

  addBackButton(view, key) {
    const actions = view.containerEl && view.containerEl.querySelector(".view-header .view-actions");
    if (actions) {
      if (actions.querySelector(".nvim-edit-back")) return;
      const btn = createEl("button", { cls: "clickable-icon view-action nvim-edit-back" });
      setIcon(btn, "corner-up-left");
      btn.setAttribute("aria-label", "Close Neovim & return to note");
      btn.addEventListener("click", (e) => {
        e.preventDefault();
        this.closeSession(key);
      });
      actions.prepend(btn);
      return;
    }
    const host = view.containerEl && view.containerEl.querySelector(".view-content");
    if (!host || host.querySelector(".nvim-edit-back-float")) return;
    const fb = createEl("button", { cls: "clickable-icon nvim-edit-back-float" });
    setIcon(fb, "corner-up-left");
    fb.setAttribute("aria-label", "Close Neovim & return to note");
    fb.style.cssText =
      "position:absolute;top:8px;right:8px;z-index:50;background:var(--background-secondary);";
    fb.addEventListener("click", (e) => {
      e.preventDefault();
      this.closeSession(key);
    });
    host.appendChild(fb);
  }

  // --- Toggle / launch logic ------------------------------------------------

  async toggle(view) {
    const file = view.file;
    if (!file) return;
    if (this.sessions.has(file.path)) {
      this.closeSession(file.path);
    } else {
      await this.launchNvim(file, this.app.workspace.activeLeaf);
    }
  }

  async launchNvim(file, sourceLeaf) {
    if (!this.app.plugins.plugins[TERMINAL_PLUGIN_ID]) {
      new Notice("Terminal plugin is not enabled in this vault");
      return false;
    }
    const cmdId = this.findOpenCommand();
    if (!cmdId) {
      new Notice("Terminal 'open default' command not found");
      return false;
    }

    try {
      fs.writeFileSync(TARGET_FILE, this.absPath(file.path));
    } catch (e) {
      console.error("nvim-edit-toggle: cannot write target file", e);
      new Notice("nvim-edit: cannot write target file");
      return false;
    }

    const before = this.allLeaves();
    this.app.commands.executeCommandById(cmdId);

    let termLeaf = null;
    for (let i = 0; i < 40 && !termLeaf; i++) {
      await sleep(50);
      const active = this.app.workspace.activeLeaf;
      if (active && active !== sourceLeaf && this.isTerminalLeaf(active)) {
        termLeaf = active;
        break;
      }
      const added = this.allLeaves().filter((l) => !before.includes(l) && this.isTerminalLeaf(l));
      if (added.length) {
        termLeaf = added[added.length - 1];
        break;
      }
    }

    if (!termLeaf) {
      new Notice("nvim-edit: opened, but couldn't track the terminal tab");
      return false;
    }

    this.sessions.set(file.path, { termLeaf, sourceLeaf: sourceLeaf || null });
    [0, 100, 300, 600].forEach((d) => setTimeout(() => this.apply(), d));
    return true;
  }

  isTerminalLeaf(leaf) {
    const t = leaf && leaf.view && leaf.view.getViewType && leaf.view.getViewType();
    return !!t && t !== "markdown" && t !== "empty" && t !== NVIM_VIEW_TYPE;
  }

  closeSession(key) {
    const s = this.sessions.get(key);
    this.sessions.delete(key);
    if (s && s.termLeaf) {
      try {
        s.termLeaf.detach();
      } catch (e) {
        /* already gone */
      }
    }
    if (s && s.sourceLeaf) {
      try {
        this.app.workspace.setActiveLeaf(s.sourceLeaf, { focus: true });
      } catch (e) {
        /* leaf may be gone */
      }
    }
    this.apply();
  }

  // --- Helpers --------------------------------------------------------------

  findOpenCommand() {
    const cmds = this.app.commands.commands || {};
    const prefer = [
      `${TERMINAL_PLUGIN_ID}:open-terminal.default.current`,
      `${TERMINAL_PLUGIN_ID}:open-terminal.default.root`,
    ];
    return prefer.find((id) => cmds[id]) || null;
  }

  sessionForLeaf(leaf) {
    if (!leaf) return null;
    for (const [key, s] of this.sessions) {
      if (s.termLeaf === leaf) return { key };
    }
    return null;
  }

  absPath(vaultRelPath) {
    const a = this.app.vault.adapter;
    if (typeof a.getFullPath === "function") return a.getFullPath(vaultRelPath);
    return path.join(a.basePath || "", vaultRelPath);
  }

  allLeaves() {
    const leaves = [];
    this.app.workspace.iterateAllLeaves((l) => leaves.push(l));
    return leaves;
  }

  onunload() {
    document
      .querySelectorAll(".nvim-edit-toggle, .nvim-edit-back, .nvim-edit-back-float")
      .forEach((el) => el.remove());
  }
};
