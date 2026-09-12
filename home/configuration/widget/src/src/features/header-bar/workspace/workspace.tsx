import { createBinding, createComputed, For } from "ags"
import { Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { MonitorFocusContext } from "../../../lib/context"
import style from "./workspace.scss"
import app from "ags/gtk4/app"
import Hyprland from "gi://AstalHyprland"

app.apply_css(style)

export default function Workspace({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }) {
  const NUM_WORKSPACES = 5
  const hypr = Hyprland.get_default()
  const workspaces = createBinding(hypr, "workspaces")
  const focusedWs = createBinding(hypr, "focusedWorkspace")
  const isFocused = MonitorFocusContext.use()

  const monitorList = workspaces((all) =>
    all
      .filter((ws) => ws.monitor?.name === gdkmonitor.connector)
      .sort((a, b) => a.id - b.id),
  )

  const focusWorkspace = (workspaceID) =>
    execAsync([
      "hyprctl",
      "dispatch",
      `function() hl.plugin.split_monitor_workspaces.workspace(${workspaceID}) end`,
    ]).catch(console.error)

  const focusWindow = (direction) =>
    execAsync([
      "hyprctl",
      "dispatch",
      `hl.dsp.layout("move ${direction}col")`,
    ]).catch(console.error)

  return (
    <box
      cssClasses={isFocused((f) =>
        f ? ["workspace", "component", "focused"] : ["workspace", "component"],
      )}
    >
      <button
        cssClasses={["window-navigator", "left"]}
        onClicked={() => focusWindow("-")}
      >
        <label label="" />
      </button>
      <box cssClasses={["workspace-navigator"]} spacing={5}>
        <For each={monitorList}>
          {(ws) => {
            const local = ((ws.id - 1) % NUM_WORKSPACES) + 1

            const isActive = createComputed(
              () => isFocused() && focusedWs()?.id === ws.id,
            )

            const glyph = createComputed(() => {
              if (isActive()) return ""
              const occupied = (ws.clients?.length ?? 0) > 0
              return occupied ? "" : ""
            })

            return (
              <button
                onClicked={() => focusWorkspace(local)}
                cssClasses={isActive((a) => (a ? ["ws", "active"] : ["ws"]))}
              >
                <label label={glyph} />
              </button>
            )
          }}
        </For>
      </box>
      <button
        cssClasses={["window-navigator", "right"]}
        onClicked={() => focusWindow("+")}
      >
        <label label="" />
      </button>
    </box>
  )
}
