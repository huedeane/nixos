import { createBinding, createComputed, createState, onCleanup, With } from "ags"
import type { Accessor } from "ags"
import { Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"
import GLib from "gi://GLib"
import Pango from "gi://Pango"
import { MonitorFocusContext } from "../../../lib/context"
import style from "./media.scss"
import app from "ags/gtk4/app"
import AstalMpris from "gi://AstalMpris"
import { pointer } from "../../../lib/utils"

app.apply_css(style)

const AstalCava: any = await import("gi://AstalCava")
  .then((m) => m.default)
  .catch(() => null)

const ICON_PLAY = "\u{f04b}"
const ICON_PAUSE = "\u{f04c}"
const ICON_PREV = "\u{f04ae}"
const ICON_NEXT = "\u{f04ad}"
const ICON_MUSIC = "\u{f001}"

const HOVER_ICON = "#292c3c"
const DIM = "#838ba7"
const TEXT = "#c6d0f5"
const YELLOW = "#e5c890"

const MAX_TEXT = 36
const MARQUEE_GAP = "   ·   "
const MARQUEE_STEP_MS = 90
const MARQUEE_PAUSE_MS = 5000
const MARQUEE_PAUSE_STEPS = Math.round(MARQUEE_PAUSE_MS / MARQUEE_STEP_MS)

const colored = (text: string, color: string) =>
  `<span foreground="${color}">${GLib.markup_escape_text(text, -1)}</span>`

type Part = { text: string; dim?: boolean }

const marquee = (parts: Part[], tick: number) => {
  const chars = parts.flatMap((p) => [...p.text].map((c) => ({ c, dim: p.dim })))
  let view = chars
  if (chars.length > MAX_TEXT) {
    const loop = [...chars, ...[...MARQUEE_GAP].map((c) => ({ c, dim: true }))]
    const steps = tick % (loop.length + MARQUEE_PAUSE_STEPS)
    const o = Math.max(0, steps - MARQUEE_PAUSE_STEPS)
    view = [...loop, ...loop].slice(o, o + MAX_TEXT)
  }

  let out = ""
  for (let i = 0; i < view.length; ) {
    let j = i
    while (j < view.length && view[j].dim === view[i].dim) j++
    const run = view.slice(i, j).map((v) => v.c).join("")
    out += view[i].dim ? colored(run, DIM) : GLib.markup_escape_text(run, -1)
    i = j
  }
  return out
}

const DIVIDER_DOTS = 3
const DIVIDER_GAP = 3

const isMpd = (p: AstalMpris.Player) =>
  p.busName.startsWith("org.mpris.MediaPlayer2.mpd")

function notifySongChanges() {
  const mpris = AstalMpris.get_default()
  let last: string | null = null
  const watched = new Map<AstalMpris.Player, number[]>()

  const check = (p: AstalMpris.Player) => {
    const key = `${p.title}\n${p.artist}\n${p.album}`
    if (last === null) return void (last = key)
    if (!p.title || key === last) return
    if (p.playbackStatus !== AstalMpris.PlaybackStatus.PLAYING) return
    last = key
    const extra = p.album || p.artist
    const body = [
      colored("Now Playing", YELLOW),
      colored("⋮", DIM),
      `<b>${colored(p.title, TEXT)}</b>`,
      ...(extra ? [colored("-", DIM), colored(extra, DIM)] : []),
    ].join(" ")
    execAsync([
      "notify-send",
      "-a",
      "rmpc",
      "-h",
      "string:x-dunst-stack-tag:rmpc",
      "Now Playing",
      body,
    ]).catch(console.error)
  }

  const watch = () => {
    for (const [p, ids] of watched) ids.forEach((id) => p.disconnect(id))
    watched.clear()
    for (const p of mpris.players.filter(isMpd)) {
      watched.set(p, [
        p.connect("notify::title", () => check(p)),
        p.connect("notify::playback-status", () => check(p)),
      ])
      check(p)
    }
  }
  mpris.connect("notify::players", watch)
  watch()
}
notifySongChanges()

const toggleRmpc = () =>
  execAsync([
    "hyprctl",
    "dispatch",
    `function()
      local rmpc = hl.get_windows({ class = "tui-rmpc" })[1]
      if rmpc then
        hl.dispatch(hl.dsp.window.close({ window = "address:" .. tostring(rmpc.address) }))
      else
        hl.dispatch(hl.dsp.exec_cmd("kitty --class tui-rmpc -o confirm_os_window_close=0 rmpc"))
      end
    end`,
  ]).catch(console.error)

const CAVA_BARS = 5
const CAVA_BAR_WIDTH = 3
const CAVA_GAP = 2
const CAVA_HEIGHT = 14

function Divider() {
  return (
    <box
      cssClasses={["divider"]}
      orientation={Gtk.Orientation.VERTICAL}
      valign={Gtk.Align.CENTER}
      spacing={DIVIDER_GAP}
    >
      {Array.from({ length: DIVIDER_DOTS }, () => (
        <box cssClasses={["dot"]} />
      ))}
    </box>
  )
}

function ControlButton({
  icon,
  onClicked,
}: {
  icon: string | Accessor<string>
  onClicked: () => void
}) {
  const [hovered, setHovered] = createState(false)
  const glyph = typeof icon === "string" ? () => icon : icon
  const label = createComputed(() =>
    hovered()
      ? `<span foreground="${HOVER_ICON}">${glyph()}</span>`
      : glyph(),
  )

  return (
    <button cursor={pointer} valign={Gtk.Align.CENTER} onClicked={onClicked}>
      <Gtk.EventControllerMotion
        onEnter={() => setHovered(true)}
        onLeave={() => setHovered(false)}
      />
      <box cssClasses={["icon-bg"]}>
        <label hexpand useMarkup label={label} />
      </box>
    </button>
  )
}

function CavaBar({
  index,
  values,
}: {
  index: number
  values: () => number[]
}) {
  return (
    <drawingarea
      cssClasses={["bar", `bar-${index}`]}
      widthRequest={CAVA_BAR_WIDTH}
      heightRequest={CAVA_HEIGHT}
      $={(self) =>
        self.set_draw_func((area, cr, w, h) => {
          const c = area.get_color()
          cr.setSourceRGBA(c.red, c.green, c.blue, c.alpha)
          const v = Math.min(Math.max(values()[index] ?? 0, 0), 1)
          const bh = Math.max(w, v * h)
          cr.rectangle(0, h - bh, w, bh)
          cr.fill()
          cr.$dispose()
        })
      }
    />
  )
}

function Cava({ playing }: { playing: Accessor<boolean> }) {
  const cava = AstalCava?.get_default() ?? null
  if (cava) cava.bars = CAVA_BARS

  const values = (): number[] => (cava && playing.get() ? cava.values : [])

  return (
    <box
      cssClasses={["cava"]}
      valign={Gtk.Align.CENTER}
      spacing={CAVA_GAP}
      $={(self) => {
        const redraw = () => {
          for (let bar = self.get_first_child(); bar; bar = bar.get_next_sibling())
            bar.queue_draw()
        }
        const unsub = playing.subscribe(redraw)
        const id = cava?.connect("notify::values", redraw)
        onCleanup(() => {
          unsub()
          if (id) cava.disconnect(id)
        })
      }}
    >
      {Array.from({ length: CAVA_BARS }, (_, i) => (
        <CavaBar index={i} values={values} />
      ))}
    </box>
  )
}

function Pill({
  player,
  isFocused,
}: {
  player: AstalMpris.Player
  isFocused: Accessor<boolean>
}) {
  const [hovered, setHovered] = createState(false)

  const title = createBinding(player, "title")
  const album = createBinding(player, "album")
  const tick = createPoll(0, MARQUEE_STEP_MS, (t) => t + 1)
  let start = 0
  let shown = ""
  const text = createComputed(() => {
    const t = title() || "Unknown"
    const a = album()
    if (t + a !== shown) {
      shown = t + a
      start = tick.get()
    }
    const parts: Part[] = a ? [{ text: t }, { text: ` - ${a}`, dim: true }] : [{ text: t }]
    return marquee(parts, tick() - start)
  })
  let flip = false
  const titleClasses = text(() => {
    flip = !flip
    return ["title", flip ? "repaint-a" : "repaint-b"]
  })
  const scrolling = createComputed(() => {
    const a = album()
    return [...(title() || "Unknown"), ...(a ? ` - ${a}` : "")].length > MAX_TEXT
  })
  const position = createBinding(player, "position")
  const length = createBinding(player, "length")
  const status = createBinding(player, "playbackStatus")
  const playing = status((s) => s === AstalMpris.PlaybackStatus.PLAYING)
  const progress = createComputed(() => {
    const l = length()
    return l > 0 ? Math.min(position() / l, 1) : 0
  })

  return (
    <overlay
      overflow={Gtk.Overflow.HIDDEN}
      cssClasses={createComputed(() => [
        "media",
        "component",
        ...(isFocused() ? ["focused"] : []),
        playing() ? "playing" : "paused",
      ])}
    >
      <Gtk.EventControllerMotion
        onEnter={() => setHovered(true)}
        onLeave={() => setHovered(false)}
      />
      <box>
        <revealer
          revealChild={hovered((h) => !h)}
          transitionType={Gtk.RevealerTransitionType.SLIDE_RIGHT}
          transitionDuration={200}
        >
          <label cssClasses={["music-icon"]} label={ICON_MUSIC} />
        </revealer>
        <revealer
          revealChild={hovered}
          transitionType={Gtk.RevealerTransitionType.SLIDE_RIGHT}
          transitionDuration={200}
        >
          <box cssClasses={["controls"]} spacing={4}>
            <ControlButton icon={ICON_PREV} onClicked={() => player.previous()} />
            <ControlButton
              icon={playing((p) => (p ? ICON_PAUSE : ICON_PLAY))}
              onClicked={() => player.play_pause()}
            />
            <ControlButton icon={ICON_NEXT} onClicked={() => player.next()} />
          </box>
        </revealer>
        <Divider />
        <button cursor={pointer} cssClasses={["info"]} onClicked={toggleRmpc}>
          <label
            cssClasses={titleClasses}
            useMarkup
            label={text}
            xalign={0}
            overflow={Gtk.Overflow.HIDDEN}
            widthChars={scrolling((s) => (s ? MAX_TEXT : -1))}
            maxWidthChars={scrolling((s) => (s ? MAX_TEXT : -1))}
            ellipsize={scrolling((s) =>
              s ? Pango.EllipsizeMode.END : Pango.EllipsizeMode.NONE,
            )}
          />
        </button>
        <Divider />
        <Cava playing={playing} />
      </box>
      <Gtk.ProgressBar
        $type="overlay"
        valign={Gtk.Align.END}
        fraction={progress}
      />
    </overlay>
  )
}

function Player({
  player,
  isFocused,
}: {
  player: AstalMpris.Player
  isFocused: Accessor<boolean>
}) {
  const title = createBinding(player, "title")
  const status = createBinding(player, "playbackStatus")
  const [emptyQueue, setEmptyQueue] = createState(false)

  const checkQueue = () =>
    execAsync(["rmpc", "status"])
      .then((out) => setEmptyQueue(JSON.parse(out).song == null))
      .catch(() => setEmptyQueue(false))

  const unsubs = [status.subscribe(checkQueue), title.subscribe(checkQueue)]
  onCleanup(() => unsubs.forEach((u) => u()))
  checkQueue()

  return (
    <box>
      <With value={emptyQueue}>
        {(empty) =>
          empty ? (
            <NoMusic isFocused={isFocused} />
          ) : (
            <Pill player={player} isFocused={isFocused} />
          )
        }
      </With>
    </box>
  )
}

function NoMusic({ isFocused }: { isFocused: Accessor<boolean> }) {
  return (
    <box
      cssClasses={isFocused((f) =>
        f
          ? ["media", "component", "empty", "focused"]
          : ["media", "component", "empty"],
      )}
      spacing={8}
    >
      <label cssClasses={["music-icon"]} label={ICON_MUSIC} />
      <label label="Nothing playing" />
    </box>
  )
}

export default function Media() {
  const isFocused = MonitorFocusContext.use()
  const mpris = AstalMpris.get_default()
  const players = createBinding(mpris, "players")

  const active = players((ps) => ps.find(isMpd) ?? null)

  return (
    <box>
      <With value={active}>
        {(player) =>
          player ? (
            <Player player={player} isFocused={isFocused} />
          ) : (
            <NoMusic isFocused={isFocused} />
          )
        }
      </With>
    </box>
  )
}
