import { createState } from "ags"
import { Astal, Gdk } from "ags/gtk4"
import app from "ags/gtk4/app"
import cairo from "cairo"
import style from "./record-border.scss"

app.apply_css(style)

// Border is drawn just outside the recorded area so it never ends up in the GIF
const WIDTH = 3

type Region = { x: number; y: number; w: number; h: number }

const [region, setRegion] = createState<Region | null>(null)

// `ags request record-border show X Y W H` / `ags request record-border hide`
export const handleRecordBorder = (args: string[]) => {
  const [action, ...nums] = args
  if (action === "hide") return setRegion(null), "ok"
  const [x, y, w, h] = nums.map(Number)
  if (action !== "show" || [x, y, w, h].some((n) => !Number.isFinite(n))) return "usage: record-border show X Y W H | hide"
  setRegion({ x, y, w, h })
  return "ok"
}

export default function RecordBorder(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT } = Astal.WindowAnchor
  const geo = gdkmonitor.get_geometry()

  // Only the monitor holding the region's top-left corner draws it
  const here = region((r) =>
    r && r.x >= geo.x && r.x < geo.x + geo.width && r.y >= geo.y && r.y < geo.y + geo.height ? r : null,
  )

  return (
    <window
      visible={here((r) => r !== null)}
      namespace="record-border"
      cssClasses={["record-border-window"]}
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.NONE}
      anchor={TOP | LEFT}
      marginLeft={here((r) => Math.max((r?.x ?? 0) - geo.x - WIDTH, 0))}
      marginTop={here((r) => Math.max((r?.y ?? 0) - geo.y - WIDTH, 0))}
      application={app}
      $={(self) => {
        // Let every click pass through to the windows underneath
        self.connect("map", () => self.get_surface()?.set_input_region(new cairo.Region()))
      }}
    >
      <box
        cssClasses={["record-border"]}
        widthRequest={here((r) => (r?.w ?? 1) + WIDTH * 2)}
        heightRequest={here((r) => (r?.h ?? 1) + WIDTH * 2)}
      />
    </window>
  )
}
