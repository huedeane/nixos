const { Plugin } = require("obsidian");

module.exports = class ModeIndicator extends Plugin {
  onload() {
    this.el = this.addStatusBarItem();
    this.el.addClass("mode-indicator");
    this.statusBar = this.el.closest(".status-bar") || document.querySelector(".status-bar");
    this.last = null;

    this.setMode("Obsidian");

    const update = () => {
      const mode = this.currentMode();
      if (mode) this.setMode(mode);
    };

    this.registerEvent(this.app.workspace.on("active-leaf-change", update));
    this.registerEvent(this.app.workspace.on("layout-change", update));
    this.registerInterval(window.setInterval(update, 200));
    this.app.workspace.onLayoutReady(update);
  }

  setMode(mode) {
    if (mode === this.last) return;
    this.last = mode;
    const key = mode.toLowerCase().replace(/\s+/g, "");
    this.el.setText(mode);
    this.el.dataset.mode = key;
    if (this.statusBar) this.statusBar.dataset.mode = key;
  }

  currentMode() {
    if (document.body.querySelector(".modal-container .prompt")) return "Command";

    const view = this.app.workspace.activeLeaf && this.app.workspace.activeLeaf.view;
    if (!view) return "";

    const type = (view.getViewType && view.getViewType()) || "";
    if (type === "markdown") {
      const mode = view.getMode && view.getMode();
      return mode === "preview" ? "Reading" : "Editing";
    }
    if (/web|surfing|browser/i.test(type)) return "Web View";
    return "";
  }

  onunload() {
    if (this.statusBar) delete this.statusBar.dataset.mode;
  }
};
