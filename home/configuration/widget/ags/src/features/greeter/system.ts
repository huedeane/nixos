import { execAsync } from "ags/process"
import AstalGreet from "gi://AstalGreet"
import GLib from "gi://GLib"

// Set by the greetd module through `ags bundle -d`; the fallbacks are for `ags run` while editing
const SESSIONS_DIR = typeof GREETER_SESSIONS !== "undefined" ? GREETER_SESSIONS : "/run/current-system/sw/share/wayland-sessions"
const STATE_FILE = `${typeof GREETER_STATE !== "undefined" ? GREETER_STATE : GLib.get_user_cache_dir()}/ags-greeter.json`

// greetd hands its greeter a socket; without one (`ags run`), logins are faked so the UI can be tried
export const demo = !GLib.getenv("GREETD_SOCK")

// Commands for the sway the greeter runs in; skipped outside it (`ags run`, cage)
const SWAYMSG = typeof GREETER_SWAYMSG !== "undefined" ? GREETER_SWAYMSG : "swaymsg"
export const sway = (...args: (string | number)[]) =>
  GLib.getenv("SWAYSOCK") ? execAsync([SWAYMSG, ...args.map(String)]).catch(console.error) : Promise.resolve()

export type User = { name: string; realName: string }
export type Session = { id: string; name: string; exec: string; desktops: string[] }

const read = (path: string) => {
  try {
    const [, bytes] = GLib.file_get_contents(path)
    return new TextDecoder().decode(bytes)
  } catch {
    return ""
  }
}

// Regular accounts: uid 1000+ with a login shell
export const users = (): User[] =>
  read("/etc/passwd")
    .split("\n")
    .map((line) => line.split(":"))
    .filter(([name, , uid, , , , shell]) => name && Number(uid) >= 1000 && Number(uid) < 60000 && !/nologin|false$/.test(shell ?? ""))
    .map(([name, , , , gecos]) => ({ name, realName: gecos?.split(",")[0] || name }))

export const sessions = (): Session[] => {
  const dir = GLib.Dir.open(SESSIONS_DIR, 0)
  const found: Session[] = []
  for (let file = dir.read_name(); file; file = dir.read_name()) {
    if (!file.endsWith(".desktop")) continue
    const key = new GLib.KeyFile()
    try {
      key.load_from_file(`${SESSIONS_DIR}/${file}`, GLib.KeyFileFlags.NONE)
    } catch {
      continue // a broken file just isn't listed
    }
    const get = (k: string) => {
      try {
        return key.get_string("Desktop Entry", k)
      } catch {
        return ""
      }
    }
    if (!get("Exec") || get("Hidden") === "true" || get("NoDisplay") === "true") continue
    found.push({
      id: file.replace(/\.desktop$/, ""),
      name: get("Name") || file,
      // Field codes (%f, %U…) mean nothing for a session command
      exec: get("Exec").replace(/\s*%[a-zA-Z]/g, ""),
      desktops: get("DesktopNames").split(";").filter(Boolean),
    })
  }
  dir.close()
  return found.sort((a, b) => a.name.localeCompare(b.name))
}

// Last user and session, so the next boot preselects them
type State = { user?: string; session?: string }

export const loadState = (): State => {
  try {
    return JSON.parse(read(STATE_FILE)) as State
  } catch {
    return {}
  }
}

export const saveState = (state: State) => {
  try {
    GLib.file_set_contents(STATE_FILE, JSON.stringify(state))
  } catch (e) {
    console.error(e)
  }
}

const sleep = (ms: number) =>
  new Promise<void>((resolve) => GLib.timeout_add(GLib.PRIORITY_DEFAULT, ms, () => (resolve(), GLib.SOURCE_REMOVE)))

// Leaves greetd ready for the next attempt, then reports what went wrong
const fail = async (res: AstalGreet.Response): Promise<never> => {
  await send(AstalGreet.CancelSession.new()).catch(console.error)
  throw new Error(res instanceof AstalGreet.Error ? res.description : "greetd: unexpected response")
}

// Checks the password only, so the screen can stay up to show a wrong one; rejects on failure.
// `start` is then called to launch the session.
// Not AstalGreet.login_with_env: it reads `env` after the JS array behind it is freed and
// segfaults once the password is accepted. StartSession copies it when constructed instead.
export const authenticate = async (user: string, password: string) => {
  if (demo) {
    await sleep(800)
    if (password !== "demo") throw new Error("demo mode: the password is \"demo\"")
    return
  }
  let res = await send(AstalGreet.CreateSession.new(user))
  while (res instanceof AstalGreet.AuthMessage) {
    const prompt = res.messageType === AstalGreet.AuthMessageType.SECRET || res.messageType === AstalGreet.AuthMessageType.VISIBLE
    res = await send(AstalGreet.PostAuthMessage.new(prompt ? password : null))
  }
  if (!(res instanceof AstalGreet.Success)) await fail(res)
}

// Starts the session of an authenticated user; greetd exits the greeter once it's up
export const start = async (session: Session) => {
  if (demo) return console.log(`demo mode: start ${session.exec}`)
  const env = [
    "XDG_SESSION_TYPE=wayland",
    `XDG_SESSION_DESKTOP=${session.id}`,
    ...(session.desktops.length ? [`XDG_CURRENT_DESKTOP=${session.desktops.join(":")}`] : []),
  ]
  // greetd runs this through `sh -c`; systemd-cat keeps uwsm's startup output off the tty
  // between the greeter fading out and the session drawing
  const cmd = `systemd-cat -t ${session.id} ${session.exec}`
  const res = await send(AstalGreet.StartSession.new([cmd], env))
  if (!(res instanceof AstalGreet.Success)) await fail(res)
}

const send = (req: AstalGreet.Request) =>
  new Promise<AstalGreet.Response>((resolve, reject) =>
    req.send((_, res) => {
      try {
        resolve(req.send_finish(res))
      } catch (e) {
        reject(e)
      }
    }),
  )

export const reboot = () => (demo ? console.log("demo mode: reboot") : execAsync(["systemctl", "reboot"]).catch(console.error))
export const powerOff = () =>
  demo ? console.log("demo mode: power off") : execAsync(["systemctl", "poweroff"]).catch(console.error)
