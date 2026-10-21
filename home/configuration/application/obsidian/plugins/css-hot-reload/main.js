const { Plugin, Notice } = require("obsidian");
const fs = require("fs");
const path = require("path");

const STYLE_ID = "css-hot-reload-theme";

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

  targetEl(css) {
    if (this.el && this.el.isConnected) return this.el;
    for (const el of document.head.querySelectorAll("style")) {
      if (el.textContent === css) {
        this.el = el;
        return el;
      }
    }
    let own = document.getElementById(STYLE_ID);
    if (!own) {
      own = document.createElement("style");
      own.id = STYLE_ID;
      document.head.appendChild(own);
    }
    this.el = own;
    return own;
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
    if (!this.file) return;
    try {
      const css = fs.readFileSync(this.file, "utf8");
      this.targetEl(css).textContent = css;
      if (notify) new Notice("Theme CSS reloaded");
    } catch (e) {
      console.error("css-hot-reload: failed to reload", e);
      if (notify) new Notice("Theme CSS reload failed (see console)");
    }
  }

  onunload() {
    if (this.file) fs.unwatchFile(this.file);
    const own = document.getElementById(STYLE_ID);
    if (own) own.remove();
  }
};
