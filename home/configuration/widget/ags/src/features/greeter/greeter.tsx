import { createComputed, createState } from "ags"
import { Gdk, Gtk } from "ags/gtk4"
import app from "ags/gtk4/app"
import Gio from "gi://Gio"
import GLib from "gi://GLib"
import Clock from "../../shared/login-screen/clock"
import { applyCss, setScale } from "../../shared/login-screen/common"
import LoginCard from "../../shared/login-screen/login-card"
import PowerButtons from "../../shared/login-screen/power-buttons"
import SessionButton from "./session-button"
import {
  authenticate,
  loadState,
  powerOff,
  reboot,
  saveState,
  start,
  sessions as listSessions,
  sway,
  users as listUsers,
} from "./system"
import style from "./greeter.scss"

applyCss(style)

// Set by the greetd module; `ags run` falls back to the repo's copy
const WALLPAPER =
  typeof GREETER_WALLPAPER !== "undefined" ? GREETER_WALLPAPER : `${SRC}/../../../../../resources/wallpaper.png`

// The screen fades to black before the session starts, and back in quickly if login fails
const LOGIN_FADE_MS = 3000

const sleep = (ms: number) =>
  new Promise<void>((resolve) => GLib.timeout_add(GLib.PRIORITY_DEFAULT, ms, () => (resolve(), GLib.SOURCE_REMOVE)))

export default function Greeter() {
  const users = listUsers()
  const sessions = listSessions()
  const saved = loadState()

  const [userIndex, setUserIndex] = createState(Math.max(0, users.findIndex((u) => u.name === saved.user)))
  const [session, setSession] = createState(
    sessions.find((s) => s.id === saved.session) ?? sessions.find((s) => s.id === "hyprland-uwsm") ?? sessions[0],
  )
  const [loggingIn, setLoggingIn] = createState(false)
  const [failed, setFailed] = createState(false)
  const [fading, setFading] = createState(false)
  const user = createComputed(() => users[userIndex()]?.name ?? "user")

  const submit = async (password: string) => {
    const s = session.get()
    if (!s) return
    setFailed(false)
    setLoggingIn(true)
    try {
      await authenticate(user.get(), password)
    } catch (e) {
      console.error(e)
      setLoggingIn(false)
      setFailed(true)
      return
    }
    // Only a correct password fades out, taking the cursor with it
    setFading(true)
    sway("seat", "seat0", "hide_cursor", 1)
    await sleep(LOGIN_FADE_MS)
    try {
      await start(s)
      saveState({ user: user.get(), session: s.id })
      app.quit()
    } catch (e) {
      console.error(e)
      sway("seat", "seat0", "hide_cursor", 0)
      setFading(false)
      setLoggingIn(false)
      setFailed(true)
    }
  }

  const display = Gdk.Display.get_default()!
  setScale(display.get_monitors().get_item(0) as Gdk.Monitor | null)

  return (
    <Gtk.Window
      application={app}
      cssClasses={["login-screen", "greeter"]}
      decorated={false}
      $={(self) => {
        let shown = false
        const onMap = () => {
          if (shown) return
          shown = true
          const surface = self.get_surface()
          const monitor = surface ? display.get_monitor_at_surface(surface) : null
          setScale(monitor)
          // sway starts the pointer at 0,0 (top left); move it to the middle of the greeter's screen
          if (monitor) {
            const { x, y, width, height } = monitor.get_geometry()
            sway("seat", "seat0", "cursor", "set", Math.round(x + width / 2), Math.round(y + height / 2))
          }
          // Fade in from black; a frame later so the transition runs
          GLib.timeout_add(GLib.PRIORITY_DEFAULT, 50, () => (self.add_css_class("ready"), GLib.SOURCE_REMOVE))
        }
        // Listen before presenting, which can map the window straight away
        self.connect("map", onMap)
        // GTK fades focus rings out after a few seconds of no typing; keep them
        self.connect("notify::focus-visible", () => self.get_focus_visible() || self.set_focus_visible(true))
        self.set_focus_visible(true)
        self.fullscreen()
        self.present()
        if (self.get_mapped()) onMap()
      }}
    >
      <overlay>
        <Gtk.Picture
          file={Gio.File.new_for_path(WALLPAPER)}
          contentFit={Gtk.ContentFit.COVER}
          canShrink
          hexpand
          vexpand
        />
        <Clock $type="overlay" />
        <LoginCard
          $type="overlay"
          user={user}
          loggingIn={loggingIn}
          failed={failed}
          onSubmit={submit}
          onEdit={() => setFailed(false)}
          onSwitchUser={() => users.length && setUserIndex((userIndex.get() + 1) % users.length)}
        />
        <box $type="overlay" cssClasses={["actions"]} valign={Gtk.Align.END}>
          <SessionButton sessions={sessions} current={session} onSelect={setSession} />
          <box hexpand />
          <PowerButtons onReboot={reboot} onPowerOff={powerOff} />
        </box>
        {/* Swallows input while the screen is dark, and fades for login */}
        <box
          $type="overlay"
          cssClasses={fading((f) => (f ? ["login-fade", "dark"] : ["login-fade"]))}
          canTarget={loggingIn}
        />
        <box $type="overlay" cssClasses={["boot-fade"]} canTarget={false} />
      </overlay>
    </Gtk.Window>
  )
}
