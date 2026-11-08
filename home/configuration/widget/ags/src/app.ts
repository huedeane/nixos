import app from "ags/gtk4/app"
import style from "./style.scss"
import HeaderBar from "./features/header-bar/header-bar"
import WindowClose from "./features/window-close/window-close"
import RecordBorder, { handleRecordBorder } from "./features/record-border/record-border"
import StartupFade from "./features/startup-fade/startup-fade"
import ColumnPeek from "./features/column-peek/column-peek"
import { toggleLauncher } from "./features/header-bar/launcher/launcher"
import { toggleNotifications } from "./features/header-bar/notification/notification"
import { closePopups, focusPopup } from "./lib/utils"

app.start({
  css: style,
  requestHandler(argv, res) {
    if (argv[0] === "record-border") return res(handleRecordBorder(argv.slice(1)))
    if (argv[0] === "launcher") return res(toggleLauncher())
    if (argv[0] === "notifications") return res(toggleNotifications())
    if (argv[0] === "focus-popup") return res(focusPopup())
    if (argv[0] === "close-popups") return res(closePopups())
    res(`unknown request: ${argv.join(" ")}`)
  },
  main() {
    app.get_monitors().map(HeaderBar)
    app.get_monitors().map(WindowClose)
    app.get_monitors().map(RecordBorder)
    app.get_monitors().map(StartupFade)
    app.get_monitors().map(ColumnPeek)
  },
})
