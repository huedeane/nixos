declare const SRC: string

// Greeter paths, defined by the greetd module when it bundles greeter.ts
declare const GREETER_WALLPAPER: string
declare const GREETER_SESSIONS: string
declare const GREETER_STATE: string
declare const GREETER_SWAYMSG: string

declare module "inline:*" {
  const content: string
  export default content
}

declare module "*.scss" {
  const content: string
  export default content
}

declare module "*.blp" {
  const content: string
  export default content
}

declare module "*.css" {
  const content: string
  export default content
}
