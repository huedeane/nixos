import app from "ags/gtk4/app"
import style from "./style.scss"
import HeaderBar from "./features/header-bar/header-bar"
import WindowClose from "./features/window-close/window-close"

app.start({
  css: style,
  main() {
    app.get_monitors().map(HeaderBar)
    app.get_monitors().map(WindowClose)
  },
})
