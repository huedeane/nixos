import { createState, onCleanup } from "ags"
import { subprocess } from "ags/process"

// Notifications sent since the screen locked, from 0 at lock. dunst keeps no list of new ones
// (and its history is capped), so this watches the session bus for Notify calls instead. Stops
// with the lock (its scope's cleanup)
export function notificationsSince() {
  const [count, setCount] = createState(0)
  const monitor = subprocess(
    ["dbus-monitor", "--session", "type='method_call',interface='org.freedesktop.Notifications',member='Notify'"],
    // One header line per call; the monitor's own NameAcquired/NameLost signals don't match
    (line) => line.includes("member=Notify") && setCount(count.get() + 1),
    () => {},
  )
  onCleanup(() => monitor.kill())
  return count
}
