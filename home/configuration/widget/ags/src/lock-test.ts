import app from "ags/gtk4/app"
import { lockTest } from "./features/lock-screen/lock-screen"

// Lock screen test mode, separate from the shell in app.ts (see lockTest)
app.start({
  instanceName: "ags-lock-test",
  main() {
    lockTest()
  },
})
