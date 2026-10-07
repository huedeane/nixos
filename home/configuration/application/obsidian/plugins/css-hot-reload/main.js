const { Plugin, Notice } = require("obsidian");
const fs = require("fs");
const path = require("path");

module.exports = class CssHotReload extends Plugin {
  onload() {
    this.addCommand({
      id: "reload-theme-css",
      name: "Reload theme CSS",
      callback: () => this.reload(true),
    });
    this.app.workspace.onLayoutReady(() => this.watch());
  }

  themeCssPath() {
    const base = this.app.vault.adapter.basePath;
    const theme = this.app.customCss && this.app.customCss.theme;
    if (!base || !theme) return null;
    const p = path.join(base, ".obsidian", "themes", theme, "theme.css");
    try {
      return fs.realpathSync(p);
    } catch (e) {
      return p;
    }
  }

  watch() {
    const file = this.themeCssPath();
    if (!file) {
      console.warn("css-hot-reload: no active custom theme to watch");
      return;
    }
    this.file = file;
    console.log("css-hot-reload: watching", file);
    fs.watchFile(file, { interval: 400 }, (curr, prev) => {
      if (curr.mtimeMs !== prev.mtimeMs) {
        console.log("css-hot-reload: change detected -> reloading CSS");
        this.reload();
      }
    });
  }

  reload(notify) {
    const cc = this.app.customCss;
    if (!cc) return;
    if (typeof cc.loadCss === "function") {
      cc.loadCss();
    } else {
      const t = cc.theme;
      cc.setTheme("");
      cc.setTheme(t);
    }
    if (notify) new Notice("Theme CSS reloaded");
  }

  onunload() {
    if (this.file) fs.unwatchFile(this.file);
  }
};
