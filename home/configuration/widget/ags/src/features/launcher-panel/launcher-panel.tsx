import { createComputed, createState, For, onCleanup } from "ags"
import type { Accessor } from "ags"
import { Gdk, Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import AstalApps from "gi://AstalApps"
import GLib from "gi://GLib"
import Pango from "gi://Pango"
import app from "ags/gtk4/app"
import { pointer } from "../../lib/utils"
import style from "./launcher-panel.scss"

app.apply_css(style)

const RECENT_MAX = 5
const RECENT_FILE = `${GLib.get_user_cache_dir()}/ags/launcher-recent.json`
const TILE_COLORS = 8

const ICON_SEARCH = "\u{f002}"
const ICON_TERMINAL = "\u{f120}"
const ICON_NIX = "\u{f313}"

const TEXT = "#c6d0f5"
const SUBTEXT = "#a5adce"
const DIM = "#838ba7"
const MANTLE = "#292c3c"
const SURFACE = "#51576d"
const YELLOW = "#e5c890"

// First matching desktop category wins
const CATEGORIES: [string, string][] = [
  ["Game", "Games"],
  ["InstantMessaging", "Chat"],
  ["Chat", "Chat"],
  ["WebBrowser", "Internet"],
  ["Network", "Internet"],
  ["Office", "Office"],
  ["Development", "Dev"],
  ["AudioVideo", "Media"],
  ["Audio", "Media"],
  ["Video", "Media"],
  ["Graphics", "Graphics"],
  ["Settings", "System"],
  ["System", "System"],
  ["Utility", "Utility"],
]

type App = AstalApps.Application

const esc = (text: string) => GLib.markup_escape_text(text, -1)
const paint = (text: string, color: string, bold = false) => {
  const span = `<span foreground="${color}">${esc(text)}</span>`
  return bold ? `<b>${span}</b>` : span
}

const categoryOf = (a: App) => CATEGORIES.find(([c]) => a.categories.includes(c))?.[1] ?? ""

const subtitleOf = (a: App) => {
  let generic = ""
  try {
    generic = a.get_key("GenericName") ?? ""
  } catch {}
  return generic || a.description || ""
}

const tileClass = (a: App) =>
  `c${[...a.name].reduce((sum, ch) => sum + ch.charCodeAt(0), 0) % TILE_COLORS}`

// Greedy subsequence match; null when the query isn't fully contained
const highlight = (text: string, query: string, color: string, bold = false, matchColor = YELLOW) => {
  const q = query.toLowerCase()
  let qi = 0
  let out = ""
  for (const ch of text) {
    const hit = qi < q.length && ch.toLowerCase() === q[qi]
    if (hit) qi++
    out += hit ? `<span foreground="${matchColor}" underline="single">${esc(ch)}</span>` : esc(ch)
  }
  if (qi < q.length) return null
  const span = `<span foreground="${color}">${out}</span>`
  return bold ? `<b>${span}</b>` : span
}

const loadRecent = (): string[] => {
  try {
    const [, bytes] = GLib.file_get_contents(RECENT_FILE)
    return JSON.parse(new TextDecoder().decode(bytes))
  } catch {
    return []
  }
}

const saveRecent = (entries: string[]) => {
  GLib.mkdir_with_parents(GLib.path_get_dirname(RECENT_FILE), 0o755)
  GLib.file_set_contents(RECENT_FILE, JSON.stringify(entries))
}

const sortedApps = (apps: AstalApps.Apps) =>
  apps.get_list().sort((a, b) => a.name.localeCompare(b.name))

function Tile({ app, big = false }: { app: App; big?: boolean }) {
  return (
    <box
      cssClasses={["tile", tileClass(app), ...(big ? ["big"] : [])]}
      hexpand={false}
      valign={Gtk.Align.CENTER}
      halign={Gtk.Align.CENTER}
    >
      <label hexpand halign={Gtk.Align.CENTER} useMarkup label={paint((app.name[0] ?? "?").toUpperCase(), MANTLE, true)} />
    </box>
  )
}

function Key({ label }: { label: string }) {
  return (
    <box cssClasses={["key"]} valign={Gtk.Align.CENTER}>
      <label useMarkup label={paint(label, SUBTEXT)} />
    </box>
  )
}

export function Hint({ keys, label }: { keys: string[]; label: string }) {
  return (
    <box spacing={4}>
      {keys.map((k) => (
        <Key label={k} />
      ))}
      <label useMarkup label={paint(label, DIM)} />
    </box>
  )
}

export function LauncherPanel() {
  const apps = new AstalApps.Apps()
  const [all, setAll] = createState<App[]>(sortedApps(apps))
  const [recentIds, setRecentIds] = createState<string[]>(loadRecent())
  const [query, setQuery] = createState("")
  const [selected, setSelected] = createState(0)
  const [navigating, setNavigating] = createState(false)

  let entry: Gtk.Entry | null = null
  let scroller: Gtk.ScrolledWindow | null = null
  let root: Gtk.Widget | null = null

  const searching = query((q) => q.trim() !== "")
  const results = createComputed(() => (searching() ? apps.fuzzy_query(query().trim()) : all()))
  const recent = createComputed(() =>
    searching()
      ? []
      : recentIds()
          .map((id) => all().find((a) => a.entry === id))
          .filter((a): a is App => !!a)
          .slice(0, RECENT_MAX),
  )
  // Recent tiles come first in the selection order, then the list
  const offset = recent((r) => r.length)
  const flat = createComputed(() => [...recent(), ...results()])
  const current = createComputed(() => flat()[selected()] ?? null)
  // Before typing or moving, the search box has focus and nothing is selected; typing moves
  // the focus to the first result (the entry keeps the keyboard, so typing still works)
  const showSelection = navigating
  // While searching, the two "Also try" rows follow the results in the selection
  const alsoStart = createComputed(() => flat().length)
  const total = createComputed(() => flat().length + (searching() ? 2 : 0))

  const close = () => (root?.get_ancestor(Gtk.Popover.$gtype) as Gtk.Popover | null)?.popdown()

  const launch = (a: App) => {
    // uwsm warns about desktop IDs with spaces (Steam shortcuts), even given the file path, so
    // those go through gio, which uwsm only sees as a plain command
    const file = a.entry.includes(" ") ? a.app.get_filename() : null
    execAsync(["uwsm", "app", "--", ...(file ? ["gio", "launch", file] : [a.entry])]).catch(console.error)
    const ids = [a.entry, ...recentIds.get().filter((e) => e !== a.entry)].slice(0, RECENT_MAX)
    setRecentIds(ids)
    saveRecent(ids)
    close()
  }

  const runInTerminal = (cmd: string) => {
    execAsync(["uwsm", "app", "--", "kitty", "--hold", "sh", "-c", cmd]).catch(console.error)
    close()
  }

  const searchNixpkgs = (term: string) => {
    execAsync([
      "uwsm", "app", "--", "kitty", "sh", "-c",
      'FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --query=$1" exec ns', "sh", term,
    ]).catch(console.error)
    close()
  }

  const move = (step: number) => {
    const count = total.get()
    if (count > 0) setSelected(Math.min(Math.max(selected.get() + step, 0), count - 1))
  }

  const onKey = (_ctl: Gtk.EventControllerKey, keyval: number, _code: number, state: Gdk.ModifierType) => {
    // Focus order: search box -> recent grid -> list -> "Also try"; Shift+Tab / Up walk back
    const nav = navigating.get()
    const inGrid = nav && selected.get() < offset.get()
    const atTop = inGrid || (offset.get() === 0 && selected.get() === 0)
    const toSearch = () => (setNavigating(false), setSelected(0))
    const backwards = keyval === Gdk.KEY_ISO_Left_Tab || (keyval === Gdk.KEY_Tab && state & Gdk.ModifierType.SHIFT_MASK)
    switch (keyval) {
      case Gdk.KEY_Down:
        setNavigating(true)
        return move(!nav ? 0 : inGrid ? offset.get() - selected.get() : 1), true
      case Gdk.KEY_Up:
        if (!nav) return true
        if (atTop) return toSearch(), true
        return move(selected.get() === offset.get() ? -offset.get() : -1), true
      case Gdk.KEY_Left:
      case Gdk.KEY_Right:
        if (!inGrid) return false
        setSelected(Math.min(Math.max(selected.get() + (keyval === Gdk.KEY_Left ? -1 : 1), 0), offset.get() - 1))
        return true
      case Gdk.KEY_Tab:
      case Gdk.KEY_ISO_Left_Tab: {
        // First index of each section that is showing, in focus order
        const starts = [0, offset.get(), alsoStart.get()].filter((s, i, all) => s < total.get() && all.indexOf(s) === i)
        const zone = nav ? starts.filter((s) => s <= selected.get()).length - 1 : -1
        const next = zone + (backwards ? -1 : 1)
        if (next < 0) toSearch()
        else if (next < starts.length) {
          setNavigating(true)
          setSelected(starts[next])
        }
        return true
      }
      case Gdk.KEY_Return:
      case Gdk.KEY_KP_Enter:
        if (state & Gdk.ModifierType.CONTROL_MASK) {
          if (searching.get()) runInTerminal(query.get().trim())
        } else if (showSelection.get()) {
          const a = current.get()
          const also = selected.get() - alsoStart.get()
          if (a) launch(a)
          else if (also === 0) runInTerminal(query.get().trim())
          else if (also === 1) searchNixpkgs(query.get().trim())
        }
        return true
      case Gdk.KEY_Escape:
        if (!query.get()) return false
        entry?.set_text("")
        return true
    }
    return false
  }

  const scrollTo = (widget: Gtk.Widget) => {
    const content = (scroller?.get_child() as Gtk.Viewport | null)?.get_child()
    if (!scroller || !content) return
    const [ok, bounds] = widget.compute_bounds(content)
    if (ok) scroller.vadjustment.clamp_page(bounds.origin.y, bounds.origin.y + bounds.size.height)
  }

  function Row({ app, index }: { app: App; index: Accessor<number> }) {
    const isSel = createComputed(() => showSelection() && selected() === offset() + index())
    const markup = createComputed(() => {
      const sel = isSel()
      const q = searching() ? query().trim() : ""
      const nameColor = sel ? MANTLE : TEXT
      const subColor = sel ? SURFACE : DIM
      const matchColor = sel ? MANTLE : YELLOW
      const name = q ? highlight(app.name, q, nameColor, true, matchColor) : null
      const sub = subtitleOf(app)
      const subMarkup = (q && !name && highlight(sub, q, subColor, false, matchColor)) || paint(sub, subColor)
      return `${name ?? paint(app.name, nameColor, true)}  ${subMarkup}`
    })
    const category = categoryOf(app)

    return (
      <button
        cursor={pointer}
        focusable={false}
        cssClasses={isSel((s) => (s ? ["row", "selected"] : ["row"]))}
        onClicked={() => launch(app)}
        $={(self) => {
          const unsub = isSel.subscribe(() => {
            if (isSel.get()) GLib.idle_add(GLib.PRIORITY_DEFAULT, () => (scrollTo(self), GLib.SOURCE_REMOVE))
          })
          onCleanup(unsub)
        }}
      >
        <box cssClasses={["inner"]} spacing={10}>
          <Tile app={app} />
          <label hexpand xalign={0} useMarkup label={markup} ellipsize={Pango.EllipsizeMode.END} />
          <box visible={createComputed(() => !isSel())}>
            <box cssClasses={["badge"]} visible={searching((s) => !s && category !== "")}>
              <label useMarkup label={paint(category, SUBTEXT)} />
            </box>
            <label visible={searching} useMarkup label={paint(category, DIM)} />
          </box>
          <label
            cssClasses={["open-hint"]}
            visible={createComputed(() => isSel())}
            useMarkup
            label={paint("⏎ open", SURFACE)}
          />
        </box>
      </button>
    )
  }

  function Card({ app, index }: { app: App; index: Accessor<number> }) {
    const isSel = createComputed(() => showSelection() && selected() === index())
    return (
      <button
        cursor={pointer}
        focusable={false}
        hexpand
        cssClasses={isSel((s) => (s ? ["card", "selected"] : ["card"]))}
        onClicked={() => launch(app)}
      >
        <box cssClasses={["inner"]} orientation={Gtk.Orientation.VERTICAL} spacing={8}>
          <Tile app={app} big />
          <label
            useMarkup
            label={paint(app.name, TEXT)}
            ellipsize={Pango.EllipsizeMode.END}
            maxWidthChars={10}
          />
        </box>
      </button>
    )
  }

  function Also({
    icon,
    index,
    label,
    onClicked,
  }: {
    icon: string
    index: number
    label: (q: string, sel: boolean) => string
    onClicked: () => void
  }) {
    const isSel = createComputed(() => showSelection() && selected() === alsoStart() + index)
    return (
      <button
        cursor={pointer}
        focusable={false}
        cssClasses={isSel((s) => (s ? ["also-row", "selected"] : ["also-row"]))}
        onClicked={onClicked}
      >
        <box cssClasses={["inner"]} spacing={10}>
          <box cssClasses={["glyph"]} hexpand={false} valign={Gtk.Align.CENTER}>
            <label hexpand halign={Gtk.Align.CENTER} useMarkup label={isSel((s) => paint(icon, s ? MANTLE : SUBTEXT))} />
          </box>
          <label xalign={0} useMarkup label={createComputed(() => label(query().trim(), isSel()))} />
        </box>
      </button>
    )
  }

  return (
    <box
      cssClasses={["launcher-panel"]}
      orientation={Gtk.Orientation.VERTICAL}
      $={(self) => {
        root = self
        self.connect("map", () => {
          apps.reload()
          setAll(sortedApps(apps))
          setRecentIds(loadRecent())
          entry?.set_text("")
          setSelected(0)
          setNavigating(false)
          entry?.grab_focus()
        })
      }}
    >
      <box cssClasses={["header"]}>
        <label hexpand xalign={0} useMarkup label={paint("App Launcher", YELLOW, true)} />
      </box>

      <box cssClasses={navigating((n) => (n ? ["search", "navigating"] : ["search"]))} spacing={10}>
        <label useMarkup label={paint(ICON_SEARCH, SUBTEXT)} />
        <entry
          hexpand
          placeholderText="Search apps…"
          $={(self) => {
            entry = self
            self.connect("changed", () => {
              setQuery(self.text)
              setNavigating(self.text.trim() !== "")
              setSelected(0)
            })
          }}
        >
          <Gtk.EventControllerKey propagationPhase={Gtk.PropagationPhase.CAPTURE} onKeyPressed={onKey} />
          <Gtk.GestureClick propagationPhase={Gtk.PropagationPhase.CAPTURE} onPressed={() => setNavigating(false)} />
        </entry>
        <label
          useMarkup
          label={createComputed(() =>
            paint(searching() ? `${results().length} / ${all().length}` : `${all().length} apps`, DIM),
          )}
        />
      </box>

      <box orientation={Gtk.Orientation.VERTICAL} visible={offset((n) => n > 0)}>
        <label cssClasses={["section-label"]} xalign={0} useMarkup label={paint("Recent", YELLOW)} />
        {/* Always RECENT_MAX equal slots across the full width; empty ones pad short lists */}
        <box cssClasses={["grid"]} spacing={8} homogeneous>
          <For each={recent}>{(a, index) => <Card app={a} index={index} />}</For>
          <For each={recent((r) => Array.from({ length: RECENT_MAX - r.length }, (_, i) => i))}>
            {() => <box hexpand />}
          </For>
        </box>
      </box>

      <label
        cssClasses={["section-label"]}
        xalign={0}
        useMarkup
        label={searching((s) => paint(s ? "Search results" : "All apps", YELLOW))}
      />

      <Gtk.ScrolledWindow
        cssClasses={["list"]}
        hscrollbarPolicy={Gtk.PolicyType.NEVER}
        overlayScrolling={false}
        propagateNaturalHeight
        maxContentHeight={360}
        $={(self) => (scroller = self)}
      >
        <box orientation={Gtk.Orientation.VERTICAL} spacing={2}>
          <label
            cssClasses={["empty"]}
            visible={results((r) => r.length === 0)}
            useMarkup
            label={paint("No apps match", DIM)}
          />
          <For each={results}>{(a, index) => <Row app={a} index={index} />}</For>
        </box>
      </Gtk.ScrolledWindow>

      <box cssClasses={["also"]} orientation={Gtk.Orientation.VERTICAL} spacing={4} visible={searching}>
        <label cssClasses={["section-label"]} xalign={0} useMarkup label={paint("Also try", YELLOW)} />
        <Also
          icon={ICON_TERMINAL}
          index={0}
          label={(q, sel) =>
            `${paint("Run ", sel ? MANTLE : SUBTEXT)}${paint(q, sel ? MANTLE : TEXT, true)}${paint(" in a terminal", sel ? MANTLE : SUBTEXT)}`
          }
          onClicked={() => runInTerminal(query.get().trim())}
        />
        <Also
          icon={ICON_NIX}
          index={1}
          label={(q, sel) => `${paint("Search nixpkgs for ", sel ? MANTLE : SUBTEXT)}${paint(q, sel ? MANTLE : TEXT, true)}`}
          onClicked={() => searchNixpkgs(query.get().trim())}
        />
      </box>

      <box cssClasses={["footer"]} spacing={14}>
        <box spacing={14} visible={searching((s) => !s)}>
          <Hint keys={["↑↓"]} label="move" />
          <Hint keys={["⏎"]} label="open" />
          <Hint keys={["tab"]} label="grid" />
          <Hint keys={["esc"]} label="close" />
        </box>
        <box spacing={14} visible={searching}>
          <Hint keys={["⏎"]} label="open" />
          <Hint keys={["ctrl", "⏎"]} label="run in terminal" />
          <Hint keys={["esc"]} label="clear" />
        </box>
        <box hexpand />
        <label
          visible={showSelection}
          useMarkup
          label={current((a) =>
            a ? `${paint("exec", DIM)} ${paint("│", SURFACE)} ${paint(GLib.path_get_basename(a.executable.split(" ")[0] ?? ""), YELLOW)}` : "",
          )}
        />
      </box>
    </box>
  )
}
