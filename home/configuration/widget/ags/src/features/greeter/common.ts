import { Gdk } from "ags/gtk4"

// Kept here rather than in lib/utils, which pulls in Hyprland the greeter doesn't run under
export const pointer = Gdk.Cursor.new_from_name("pointer", null)
