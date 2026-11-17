const { Plugin, setIcon } = require("obsidian");

module.exports = class SidebarHeaderToggles extends Plugin {
  onload() {
    this.apply = this.apply.bind(this);
    this.app.workspace.onLayoutReady(this.apply);
    this.registerEvent(this.app.workspace.on("active-leaf-change", this.apply));
    this.registerEvent(this.app.workspace.on("layout-change", this.apply));
  }

  apply() {
    const header = this.app.workspace.activeLeaf?.view?.containerEl?.querySelector(".view-header");
    if (header) {
      this.addBtn(header, "left", "panel-left", ".view-header-nav-buttons", "append");
      this.addBtn(header, "right", "panel-right", ".view-actions", "prepend");
    }
    this.addLeftPanelToggle();
  }

  addLeftPanelToggle() {
    const container = this.app.workspace.leftSplit?.containerEl
      ?.querySelector(".workspace-tab-header-container");
    if (!container || container.querySelector(".hdr-sidebar-toggle.mod-left-panel")) return;
    const btn = createEl("button", { cls: "clickable-icon hdr-sidebar-toggle mod-left-panel" });
    setIcon(btn, "panel-left");
    btn.setAttribute("aria-label", "Collapse left sidebar");
    btn.addEventListener("click", () => this.app.workspace.leftSplit.toggle());
    container.append(btn);
  }

  addBtn(header, side, icon, targetSel, where) {
    if (header.querySelector(`.hdr-sidebar-toggle.mod-${side}`)) return;
    const target = header.querySelector(targetSel) || header;
    const btn = createEl("button", { cls: `clickable-icon hdr-sidebar-toggle mod-${side}` });
    setIcon(btn, icon);
    btn.setAttribute("aria-label", side === "left" ? "Toggle left sidebar" : "Toggle right sidebar");
    btn.addEventListener("click", () =>
      (side === "left" ? this.app.workspace.leftSplit : this.app.workspace.rightSplit).toggle()
    );
    target[where](btn);
  }

  onunload() {
    document.querySelectorAll(".hdr-sidebar-toggle").forEach((el) => el.remove());
  }
};
