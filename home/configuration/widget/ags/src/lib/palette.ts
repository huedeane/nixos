import css from "./palette.scss"

// style.scss colours for Pango markup, so hex values live in one place (see palette.scss)
const colors = Object.fromEntries([...css.matchAll(/--([\w-]+):\s*(#[0-9a-fA-F]{3,8})/g)].map(([, name, value]) => [name, value]))

const color = (name: string) => colors[name] ?? (console.error(`palette: no colour "${name}" in palette.scss`), "#ff00ff")

export const palette = {
  base: color("base"),
  mantle: color("mantle"),
  crust: color("crust"),
  surface0: color("surface0"),
  surface1: color("surface1"),
  surface2: color("surface2"),
  overlay0: color("overlay0"),
  overlay1: color("overlay1"),
  overlay2: color("overlay2"),
  subtext0: color("subtext0"),
  subtext1: color("subtext1"),
  text: color("text"),
  red: color("red"),
  yellow: color("yellow"),
  green: color("green"),
  lavender: color("lavender"),
}
