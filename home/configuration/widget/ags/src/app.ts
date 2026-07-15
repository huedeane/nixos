import app from "ags/gtk4/app"
import style from "./style.scss"
import bar from "./features/bar/bar"

app.start({
  css: style,
  main() {
    app.get_monitors().map(bar)
  },
})
