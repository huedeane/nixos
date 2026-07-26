import Hyprland from "gi://AstalHyprland"
import style from "./workspace.scss"
import app from "ags/gtk4/app"
import { createBinding, For } from "ags"
import { Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"

app.apply_css(style)

const NUM_WORKSPACES = 5

export default function Workspace({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }) {
  const hypr = Hyprland.get_default()
  const workspaces = createBinding(hypr, "workspaces")
  const focused = createBinding(hypr, "focusedWorkspace")

  const monitorList = workspaces(
    (all) =>
      all
        .filter((ws) => ws.monitor?.name === gdkmonitor.connector) // only this monitor
        .sort((a, b) => a.id - b.id), // fix the scrambled order
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
    <box cssClasses={["workspace-component", "left"]}>
      <button
        cssClasses={["window-navigator"]}
        onClicked={() => focusWindow("-")}
      >
        <label label="" />
      </button>
      <box cssClasses={["workspace-navigator"]}>
        <For each={monitorList}>
          {(ws) => {
            const local = ((ws.id - 1) % NUM_WORKSPACES) + 1

            const glyph = focused((f) => {
              if (f?.id === ws.id) return ""
              const occupied = (ws.clients?.length ?? 0) > 0
              return occupied ? "" : ""
            })

            return (
              <button
                onClicked={() => focusWorkspace(local)}
                cssClasses={focused((f) =>
                  f?.id === ws.id ? ["ws", "active"] : ["ws"],
                )}
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
