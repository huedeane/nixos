import app from "ags/gtk4/app"
import Greeter from "./features/greeter/greeter"

// Login screen run by greetd (hosts/modules/display/greetd), separate from the shell in app.ts
app.start({
  instanceName: "ags-greeter",
  main() {
    Greeter()
  },
})
