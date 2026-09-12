import { createContext } from "gnim"
import type { Accessor } from "ags"

// default false so a component works even if rendered outside a Bar
export const MonitorFocusContext = createContext<Accessor<boolean>>(null!)
