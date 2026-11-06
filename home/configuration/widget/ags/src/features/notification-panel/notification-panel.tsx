import { createComputed, createState, For } from "ags"
import type { Accessor } from "ags"
import { Gdk, Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { interval } from "ags/time"
import GLib from "gi://GLib"
import Pango from "gi://Pango"
import app from "ags/gtk4/app"
import { pointer } from "../../lib/utils"
import { Hint } from "../launcher-panel/launcher-panel"
import style from "./notification-panel.scss"

app.apply_css(style)

const HISTORY_MAX = 20
const CHAT_LINES = 3
const POLL_MS = 2000
const CLOCK_MS = 30_000
const JUST_NOW_US = 10 * 60 * 1_000_000

const ICON_BELL = "\u{f0f3}"
const ICON_MUSIC = "\u{f001}"
const ICON_CLIPBOARD = "\u{f0ea}"
const ICON_WARNING = "\u{f071}"
const ICON_CHECK = "\u{f00c}"
const ICON_CLOSE = "×"

const TEXT = "#c6d0f5"
const SUBTEXT = "#a5adce"
export const DIM = "#838ba7"
const MANTLE = "#292c3c"
const LAVENDER = "#babbf1"
const YELLOW = "#e5c890"
const GREEN = "#a6d189"
const RED = "#e78284"

const MEDIA_APPS = ["rmpc", "mpd", "mpv", "spotify"]
const CHAT_APPS = ["vesktop", "discord", "webcord", "telegramdesktop", "signal", "slack"]

export type Category = "media" | "chat" | "system"
export type Urgency = "LOW" | "NORMAL" | "CRITICAL"

export type Item = {
  ids: number[]
  app: string
  summary: string
  body: string
  // Chat notifications from the same person are merged; newest message first
  messages: string[]
  icon: string
  urgency: Urgency
  success: boolean
  timestamp: number
  category: Category
}

export type Source = {
  items: Accessor<Item[]>
  total: Accessor<number>
  dnd: Accessor<boolean>
  now: Accessor<number>
  remove: (item: Item) => void
  clear: () => void
  toggleDnd: () => void
}

const FILTERS: { key: Category | "all"; label: string }[] = [
  { key: "all", label: "All" },
  { key: "media", label: "Media" },
  { key: "chat", label: "Chat" },
  { key: "system", label: "System" },
]

const categoryOf = (appName: string): Category => {
  const a = appName.toLowerCase()
  if (MEDIA_APPS.includes(a)) return "media"
  if (CHAT_APPS.includes(a)) return "chat"
  return "system"
}

export const paint = (text: string, color: string, bold = false) => {
  const span = `<span foreground="${color}">${GLib.markup_escape_text(text, -1)}</span>`
  return bold ? `<b>${span}</b>` : span
}

const escapeRegex = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")

const safeMarkup = (s: string) => {
  try {
    Pango.parse_markup(s, -1, "\0")
    return s
  } catch {
    return GLib.markup_escape_text(s, -1)
  }
}

const cleanBody = (body: string, summary: string) =>
  safeMarkup(
    body.replace(
      new RegExp(`^<span[^>]*>${escapeRegex(summary)}</span>\\s*<span[^>]*>⋮</span>\\s*`),
      "",
    ),
  )

export function parseHistory(stdout: string): { items: Item[]; total: number } {
  const entries: Record<string, { data: unknown }>[] = JSON.parse(stdout).data?.[0] ?? []
  const items: Item[] = []
  const stacks = new Map<string, Item>()

  for (const e of entries) {
    const get = (k: string) => (e[k]?.data ?? "") as string
    const summary = get("summary")
    const app = get("appname")
    const chat = categoryOf(app) === "chat"
    const stack = get("stack_tag") || (chat ? `chat:${app}:${summary}` : "")
    const existing = stack ? stacks.get(stack) : undefined
    const id = e.id.data as number
    if (existing) {
      existing.ids.push(id)
      if (chat) existing.messages.push(cleanBody(get("body"), summary))
      continue
    }
    const item: Item = {
      ids: [id],
      app,
      summary,
      body: cleanBody(get("body"), summary),
      messages: [cleanBody(get("body"), summary)],
      icon: get("icon_path"),
      urgency: (get("urgency") || "NORMAL") as Urgency,
      success: get("category") === "x-success",
      timestamp: e.timestamp.data as number,
      category: categoryOf(get("appname")),
    }
    if (stack) stacks.set(stack, item)
    items.push(item)
  }
  return { items, total: entries.length }
}

const ago = (timestamp: number, now: number) => {
  const s = Math.max(0, (now - timestamp) / 1_000_000)
  if (s < 60) return "now"
  if (s < 3600) return `${Math.floor(s / 60)}m`
  if (s < 86400) return `${Math.floor(s / 3600)}h`
  return `${Math.floor(s / 86400)}d`
}

function dunstSource(): Source {
  const [items, setItems] = createState<Item[]>([])
  const [total, setTotal] = createState(0)
  const [dnd, setDnd] = createState(false)
  const [now, setNow] = createState(GLib.get_monotonic_time())
  let last = ""

  const refresh = () => {
    execAsync(["dunstctl", "history"])
      .then((out) => {
        if (out === last) return
        last = out
        const parsed = parseHistory(out)
        setNow(GLib.get_monotonic_time())
        setItems(parsed.items)
        setTotal(parsed.total)
      })
      .catch(() => {
        last = ""
        setItems([])
        setTotal(0)
      })
    execAsync(["dunstctl", "is-paused"])
      .then((out) => setDnd(out.trim() === "true"))
      .catch(() => setDnd(false))
  }

  interval(POLL_MS, refresh)
  interval(CLOCK_MS, () => setNow(GLib.get_monotonic_time()))

  const run = (cmd: string[]) => execAsync(cmd).then(refresh).catch(console.error)

  return {
    items,
    total,
    dnd,
    now,
    remove: (item) => item.ids.forEach((id) => run(["dunstctl", "history-rm", `${id}`])),
    clear: () => run(["dunstctl", "history-clear"]),
    toggleDnd: () => run(["dunstctl", "set-paused", "toggle"]),
  }
}

let source: Source | null = null
export const getSource = () => (source ??= dunstSource())

function ItemIcon({ item }: { item: Item }) {
  if (item.urgency === "CRITICAL")
    return (
      <box cssClasses={["icon", "warning"]} hexpand={false} valign={Gtk.Align.CENTER}>
        <label hexpand halign={Gtk.Align.CENTER} useMarkup label={paint(ICON_WARNING, RED)} />
      </box>
    )

  // GIF recordings can be tens of MB, so they get the file-type label instead of a preview
  if (item.icon && !item.icon.endsWith(".gif") && GLib.file_test(item.icon, GLib.FileTest.EXISTS))
    return (
      <box cssClasses={["icon", "image"]} hexpand={false} valign={Gtk.Align.CENTER}>
        <Gtk.Picture
          file={item.icon}
          contentFit={Gtk.ContentFit.COVER}
          widthRequest={46}
          heightRequest={32}
        />
      </box>
    )

  if (item.icon)
    return (
      <box cssClasses={["icon", "file"]} hexpand={false} valign={Gtk.Align.CENTER}>
        <label hexpand halign={Gtk.Align.CENTER} useMarkup label={paint(item.icon.split(".").pop() ?? "", DIM)} />
      </box>
    )

  if (item.category === "chat")
    return (
      <box cssClasses={["avatar"]} hexpand={false} valign={Gtk.Align.CENTER}>
        <label
          hexpand
          halign={Gtk.Align.CENTER}
          useMarkup
          label={paint((item.summary[0] ?? "?").toUpperCase(), MANTLE, true)}
        />
      </box>
    )

  const [glyph, color] =
    item.success
      ? [ICON_CHECK, GREEN]
      : item.category === "media"
      ? [ICON_MUSIC, GREEN]
      : item.app === "clipboard"
        ? [ICON_CLIPBOARD, SUBTEXT]
        : [ICON_BELL, SUBTEXT]

  return (
    <box cssClasses={["icon", item.category]} hexpand={false} valign={Gtk.Align.CENTER}>
      <label hexpand halign={Gtk.Align.CENTER} useMarkup label={paint(glyph, color)} />
    </box>
  )
}

const findIn = (widget: Gtk.Widget, cls: string) => {
  let panel: Gtk.Widget | null = widget
  while (panel && !panel.has_css_class("notification-panel")) panel = panel.get_parent()
  const found: Gtk.Widget[] = []
  const walk = (w: Gtk.Widget) => {
    for (let c = w.get_first_child(); c; c = c.get_next_sibling()) {
      if (c.has_css_class(cls) && c.get_mapped()) found.push(c)
      walk(c)
    }
  }
  if (panel) walk(panel)
  return found
}

const moveFocus = (card: Gtk.Widget, step: number) => {
  const cards = findIn(card, "card")
  const index = cards.indexOf(card) + step
  if (index < 0) findIn(card, "chip").at(-1)?.grab_focus()
  else cards[index]?.grab_focus()
}

const focusFirstCard = (from: Gtk.Widget) => {
  const first = findIn(from, "card")[0]
  if (!first) return false
  first.grab_focus()
  return true
}

function Row({ item, src }: { item: Item; src: Source }) {
  const urgency = item.urgency.toLowerCase()
  const count = item.ids.length
  const [hovered, setHovered] = createState(false)
  const [focused, setFocused] = createState(false)
  const active = createComputed(() => hovered() || focused())

  const summaryColor =
    item.urgency === "CRITICAL" ? RED : item.success ? GREEN : item.urgency === "LOW" ? DIM : item.category === "media" ? YELLOW : TEXT
  const bodyColor = item.urgency === "CRITICAL" ? TEXT : item.urgency === "LOW" && !item.success ? DIM : SUBTEXT

  return (
    <box cssClasses={["row", urgency, item.category, ...(item.success ? ["success"] : [])]}>
      <box cssClasses={["rail"]} orientation={Gtk.Orientation.VERTICAL}>
        <box cssClasses={["line"]} vexpand halign={Gtk.Align.CENTER} />
        <box cssClasses={["dot"]} halign={Gtk.Align.CENTER} />
        <box cssClasses={["line"]} vexpand halign={Gtk.Align.CENTER} />
      </box>
      <box cssClasses={["card"]} hexpand spacing={14} focusable>
        <Gtk.EventControllerMotion onEnter={() => setHovered(true)} onLeave={() => setHovered(false)} />
        <Gtk.EventControllerFocus onEnter={() => setFocused(true)} onLeave={() => setFocused(false)} />
        <Gtk.EventControllerKey
          onKeyPressed={(ctl, keyval) => {
            const card = ctl.get_widget()!
            if (keyval === Gdk.KEY_Down) return moveFocus(card, 1), true
            if (keyval === Gdk.KEY_Up) return moveFocus(card, -1), true
            const dismissKeys = [Gdk.KEY_Delete, Gdk.KEY_BackSpace, Gdk.KEY_Return, Gdk.KEY_KP_Enter]
            if (dismissKeys.includes(keyval)) {
              moveFocus(card, 1)
              src.remove(item)
              return true
            }
            return false
          }}
        />
        <ItemIcon item={item} />
        <box orientation={Gtk.Orientation.VERTICAL} hexpand valign={Gtk.Align.CENTER} spacing={2}>
          <box spacing={8}>
            <label
              useMarkup
              label={paint(item.summary || item.app, summaryColor, true)}
              xalign={0}
              ellipsize={Pango.EllipsizeMode.END}
            />
            <label cssClasses={["stack"]} visible={count > 1} useMarkup label={paint(`×${count}`, SUBTEXT)} />
            <box hexpand />
            <label
              cssClasses={["meta"]}
              useMarkup
              label={src.now((n) => paint(`${item.app} · ${ago(item.timestamp, n)}`, DIM))}
            />
          </box>
          <box spacing={12}>
            <box hexpand orientation={Gtk.Orientation.VERTICAL} visible={item.body !== ""}>
              {item.messages
                .filter((m) => m !== "")
                .slice(0, CHAT_LINES)
                .map((message) => (
                  <label
                    useMarkup
                    label={`<span foreground="${bodyColor}">${message}</span>`}
                    xalign={0}
                    maxWidthChars={72}
                    ellipsize={Pango.EllipsizeMode.END}
                  />
                ))}
            </box>
            <button
              cursor={pointer}
              focusable={false}
              cssClasses={["dismiss"]}
              // Always laid out (just invisible) so hovering doesn't change the card height
              opacity={active((a) => (a ? 1 : 0))}
              canTarget={active}
              valign={Gtk.Align.END}
              onClicked={() => src.remove(item)}
            >
              <box cssClasses={["inner"]}>
                <label useMarkup label={paint(`${ICON_CLOSE} dismiss`, MANTLE, true)} />
              </box>
            </button>
          </box>
        </box>
      </box>
    </box>
  )
}

export function NotificationPanel({ src }: { src: Source }) {
  const [filter, setFilter] = createState<Category | "all">("all")

  const shown = createComputed(() =>
    src.items().filter((i) => filter() === "all" || i.category === filter()),
  )

  const groups = createComputed(() => {
    const now = src.now()
    const recent = shown().filter((i) => now - i.timestamp < JUST_NOW_US)
    const earlier = shown().filter((i) => now - i.timestamp >= JUST_NOW_US)
    return [
      { label: "Just now", items: recent },
      { label: "Earlier", items: earlier },
    ].filter((g) => g.items.length > 0)
  })

  const countOf = (key: Category | "all") =>
    src.items((items) => items.filter((i) => key === "all" || i.category === key).length)

  return (
    <box cssClasses={["notification-panel"]} orientation={Gtk.Orientation.VERTICAL}>
      <box cssClasses={["header"]} spacing={8}>
        <label hexpand xalign={0} useMarkup label={paint("Notification History", YELLOW, true)} />
        <button
          cursor={pointer}
          cssClasses={src.dnd((d) => (d ? ["dnd", "on"] : ["dnd"]))}
          onClicked={src.toggleDnd}
        >
          <box cssClasses={["inner"]} spacing={6}>
            <box cssClasses={["track"]} valign={Gtk.Align.CENTER} hexpand={false}>
              <box cssClasses={["knob"]} hexpand halign={src.dnd((d) => (d ? Gtk.Align.END : Gtk.Align.START))} />
            </box>
            <label useMarkup label={src.dnd((d) => paint("DND", d ? LAVENDER : SUBTEXT))} />
          </box>
        </button>
        <button cursor={pointer} cssClasses={["clear"]} onClicked={src.clear}>
          <box cssClasses={["inner"]}>
            <label useMarkup label={paint("Clear all", MANTLE, true)} />
          </box>
        </button>
      </box>

      <box cssClasses={["filters"]} spacing={6}>
        {FILTERS.map((f) => (
          <button
            cursor={pointer}
            cssClasses={filter((cur) => (cur === f.key ? ["chip", "active"] : ["chip"]))}
            onClicked={() => setFilter(f.key)}
          >
            <Gtk.EventControllerKey
              onKeyPressed={(ctl, keyval) => {
                const last = f.key === FILTERS.at(-1)!.key
                if (keyval === Gdk.KEY_Down || (keyval === Gdk.KEY_Tab && last))
                  return focusFirstCard(ctl.get_widget()!)
                return false
              }}
            />
            <box cssClasses={["inner"]}>
              <label
                useMarkup
                label={createComputed(() => {
                  const text = `${f.label} - ${countOf(f.key)()}`
                  return filter() === f.key ? paint(text, MANTLE, true) : paint(text, SUBTEXT)
                })}
              />
            </box>
          </button>
        ))}
      </box>

      <Gtk.ScrolledWindow
        cssClasses={["list"]}
        hscrollbarPolicy={Gtk.PolicyType.NEVER}
        overlayScrolling={false}
        propagateNaturalHeight
        maxContentHeight={420}
      >
        <box cssClasses={["rows"]} orientation={Gtk.Orientation.VERTICAL}>
          <label
            cssClasses={["empty"]}
            visible={shown((s) => s.length === 0)}
            useMarkup
            label={paint("No notifications", DIM)}
          />
          <For each={groups}>
            {(group) => (
              <box cssClasses={["group"]} orientation={Gtk.Orientation.VERTICAL}>
                <label cssClasses={["group-label"]} useMarkup label={paint(group.label, YELLOW)} xalign={0} />
                {group.items.map((item) => (
                  <Row item={item} src={src} />
                ))}
              </box>
            )}
          </For>
        </box>
      </Gtk.ScrolledWindow>

      <box cssClasses={["footer"]} spacing={14}>
        <Hint keys={["↑↓"]} label="move" />
        <Hint keys={["⏎", "del"]} label="dismiss" />
        <Hint keys={["tab"]} label="filters / list" />
        <Hint keys={["esc"]} label="close" />
        <label
          hexpand
          xalign={1}
          useMarkup
          label={src.total((t) => paint(`history: ${t} / ${HISTORY_MAX}`, DIM))}
        />
      </box>
    </box>
  )
}
