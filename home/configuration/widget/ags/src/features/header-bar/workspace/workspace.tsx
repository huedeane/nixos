import { createBinding, createComputed, For } from "ags"
import { Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { MonitorFocusContext } from "../../../lib/context"
import style from "./workspace.scss"
import app from "ags/gtk4/app"
import Hyprland from "gi://AstalHyprland"
import { pointer } from "../../../lib/utils"

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

  // Clicking here shouldn't drag the cursor to the newly focused window, so warping is
  // switched off just for these dispatches
  const withoutWarp = (lua: string) =>
    execAsync([
      "hyprctl",
      "dispatch",
      `function()
        hl.config({ cursor = { no_warps = true } })
        ${lua}
        hl.config({ cursor = { no_warps = false } })
      end`,
    ]).catch(console.error)

  const focusWorkspace = (workspaceID) =>
    withoutWarp(`hl.plugin.split_monitor_workspaces.workspace(${workspaceID})`)

  const focusWindow = (direction) =>
    withoutWarp(`hl.dispatch(hl.dsp.layout("move ${direction}col"))`)

  return (
    <box
      cssClasses={isFocused((f) =>
        f ? ["workspace", "component", "focused"] : ["workspace", "component"],
      )}
    >
      <button
        cursor={pointer}
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
                cursor={pointer}
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
        cursor={pointer}
        cssClasses={["window-navigator", "right"]}
        onClicked={() => focusWindow("+")}
      >
        <label label="" />
      </button>
    </box>
  )
}
