import { createRoot, createState, getScope } from "ags"
import type { Accessor } from "ags"
import { Gdk, Gtk } from "ags/gtk4"
import app from "ags/gtk4/app"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"
import AstalAuth from "gi://AstalAuth"
import AstalMpris from "gi://AstalMpris"
import Hyprland from "gi://AstalHyprland"
import Gio from "gi://Gio"
import GLib from "gi://GLib"
import Gtk4SessionLock from "gi://Gtk4SessionLock"
import Clock from "../../shared/login-screen/clock"
import { applyCss, setScale } from "../../shared/login-screen/common"
import LoginCard from "../../shared/login-screen/login-card"
import PowerButtons from "../../shared/login-screen/power-buttons"
import { MonitorFocusContext } from "../../lib/context"
import Notification from "../../shared/notification/notification"
import Battery from "../../shared/battery/battery"
import Microphone from "../../shared/microphone/microphone"
import Volume from "../../shared/volume/volume"
import MachineInfo from "./machine-info"
import { notificationsSince } from "./notifications-since"
import style from "./lock-screen.scss"

applyCss(style)

// Same picture as the desktop, from hyprpaper's config; the repo's copy if that can't be read
const wallpaper = () => {
  try {
    const [, bytes] = GLib.file_get_contents(`${GLib.get_user_config_dir()}/hypr/hyprpaper.conf`)
    const path = new TextDecoder().decode(bytes).match(/^\s*path\s*=\s*(\S+)/m)?.[1]
    if (path) return path
  } catch {}
  return `${SRC}/../../../../../resources/wallpaper.png`
}

// Checks the password with PAM's astal-auth service (security.pam.services in the host configs);
// rejects on a wrong one
const authenticate = (password: string) =>
  new Promise<void>((resolve, reject) =>
    AstalAuth.Pam.authenticate(password, (_, res) => {
      try {
        AstalAuth.Pam.authenticate_finish(res)
        resolve()
      } catch (e) {
        reject(e)
      }
    }),
  )

const lockedFor = (since: number) => {
  const minutes = Math.floor((GLib.get_real_time() / 1e6 - since) / 60)
  if (minutes < 1) return "locked just now"
  if (minutes < 60) return `locked ${minutes}m ago`
  return `locked ${Math.floor(minutes / 60)}h ${minutes % 60}m ago`
}

type WindowProps = {
  monitor: Gdk.Monitor
  // Connector of the monitor showing the card and pills; the others only get the clock
  main: Accessor<string>
  lockedAt: number
  // New notifications since locking (one counter for all the lock's windows)
  notifications: Accessor<number>
  onUnlock: () => void
}

function LockWindow({ monitor, main, lockedAt, notifications, onUnlock }: WindowProps) {
  const [loggingIn, setLoggingIn] = createState(false)
  const [failed, setFailed] = createState(false)
  const user = createState(GLib.get_user_name())[0]
  const note = createPoll(lockedFor(lockedAt), 30_000, () => lockedFor(lockedAt))
  const focused = createState(true)[0]

  const submit = async (password: string) => {
    setFailed(false)
    setLoggingIn(true)
    try {
      await authenticate(password)
    } catch (e) {
      console.error(e)
      setLoggingIn(false)
      setFailed(true)
      return
    }
    onUnlock()
  }

  return (
    <Gtk.Window
      application={app}
      cssClasses={["login-screen", "lock-screen"]}
      $={(self) => {
        setScale(monitor)
        // GTK fades focus rings out after a few seconds of no typing; keep them (as the greeter does)
        self.connect("notify::focus-visible", () => self.get_focus_visible() || self.set_focus_visible(true))
        self.set_focus_visible(true)
      }}
    >
      <overlay>
        <Gtk.Picture
          file={Gio.File.new_for_path(wallpaper())}
          contentFit={Gtk.ContentFit.COVER}
          canShrink
          hexpand
          vexpand
        />
        <Clock $type="overlay" />
        {/* One password field across all screens, so typing can't land in a hidden one */}
        <overlay $type="overlay" visible={main((c) => c === monitor.connector)}>
          <box hexpand vexpand />
          {/* The bar's own widgets, drawn as on the focused monitor's bar; lock-widgets makes them
              as tall as the pills */}
          <box
            $type="overlay"
            cssClasses={["lock-widgets", "top"]}
            halign={Gtk.Align.END}
            valign={Gtk.Align.START}
          >
            <MonitorFocusContext value={focused}>
              {() => (
                <box>
                  <Notification lockScreen count={notifications} />
                  <Battery />
                  <Microphone lockScreen />
                  <Volume lockScreen />
                </box>
              )}
            </MonitorFocusContext>
          </box>
          <LoginCard
            $type="overlay"
            user={user}
            loggingIn={loggingIn}
            failed={failed}
            onSubmit={submit}
            onEdit={() => setFailed(false)}
            title="Locked"
            action="Unlock"
            note={note}
          />
          <box $type="overlay" cssClasses={["actions"]} valign={Gtk.Align.END}>
            <MachineInfo />
            <box hexpand />
            <PowerButtons
              onReboot={() => execAsync(["systemctl", "reboot"]).catch(console.error)}
              onPowerOff={() => execAsync(["systemctl", "poweroff"]).catch(console.error)}
            />
          </box>
        </overlay>
      </overlay>
    </Gtk.Window>
  )
}

// Held while locked, so a second request doesn't start another lock
let current: Gtk4SessionLock.Instance | null = null

// `ags request lock`: hypridle's lock_cmd, so the keybind (loginctl lock-session), idling and
// sleeping all end up here
export function lock() {
  if (current) return "already locked"
  if (!Gtk4SessionLock.is_supported()) return "session lock not supported"

  const instance = Gtk4SessionLock.Instance.new()
  current = instance
  const lockedAt = GLib.get_real_time() / 1e6
  const others = (monitor?: Gdk.Monitor) => app.get_monitors().filter((m) => m !== monitor)
  const focused = Hyprland.get_default().get_focused_monitor()?.get_name()

  createRoot((dispose) => {
    const scope = getScope()
    // The card goes on the focused screen
    const [main, setMain] = createState(
      others().find((m) => m.connector === focused)?.connector ?? others()[0]?.connector ?? "",
    )
    const end = () => {
      current = null
      dispose()
    }
    const notifications = notificationsSince()

    instance.connect("monitor", (_, monitor: Gdk.Monitor) => {
      // If the card's screen is unplugged it moves to another, so there's always one to unlock with
      if (!others().some((m) => m.connector === main.get())) setMain(monitor.connector ?? "")
      const id = monitor.connect("invalidate", () => {
        if (main.get() === monitor.connector) setMain(others(monitor)[0]?.connector ?? "")
      })
      scope.onCleanup(() => monitor.disconnect(id))
      const window = scope.run(() =>
        LockWindow({ monitor, main, lockedAt, notifications, onUnlock: () => instance.unlock() }),
      ) as Gtk.Window
      // Shows the window; the library destroys it again on unlock
      instance.assign_window_to_monitor(window, monitor)
    })
    instance.connect("failed", () => {
      console.error("lock-screen: could not lock the session")
      end()
    })
    instance.connect("unlocked", end)
    // Whatever's playing pauses once the screen is locked, and stays paused after unlocking
    instance.connect("locked", () => {
      for (const player of AstalMpris.get_default().players)
        if (player.playbackStatus === AstalMpris.PlaybackStatus.PLAYING) player.pause()
    })
    instance.lock()
  })

  return "locking"
}

// `ags run lock-test.ts`: the same screen in a plain fullscreen window on the focused monitor,
// without the session lock, so it can be tried safely. Escape closes it, and so does unlocking
// with your real password
export function lockTest() {
  const focused = Hyprland.get_default().get_focused_monitor()?.get_name()
  const monitor = app.get_monitors().find((m) => m.connector === focused) ?? app.get_monitors()[0]
  const window = LockWindow({
    monitor,
    main: createState(monitor.connector ?? "")[0],
    lockedAt: GLib.get_real_time() / 1e6,
    notifications: notificationsSince(),
    onUnlock: () => app.quit(),
  }) as Gtk.Window

  const keys = new Gtk.EventControllerKey()
  keys.connect("key-pressed", (_, keyval) => {
    if (keyval !== Gdk.KEY_Escape) return false
    app.quit()
    return true
  })
  window.add_controller(keys)
  window.fullscreen_on_monitor(monitor)
  window.present()
}
