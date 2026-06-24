def _is_nvim(window):
    try:
        fp = window.child.foreground_processes
        return any("nvim" in p.get("cmdline", [""])[0] for p in fp)
    except Exception:
        return False

def on_title_change(boss, window, data):
    if _is_nvim(window):
        boss.call_remote_control(window, ("set-spacing", "padding=0", "margin=0"))
    else:
        boss.call_remote_control(window, ("set-spacing", "padding=default", "margin=default"))

def on_focus_change(boss, window, data):
    if not window:
        return
    if _is_nvim(window):
        boss.call_remote_control(window, ("set-spacing", "padding=0", "margin=0"))
    else:
        boss.call_remote_control(window, ("set-spacing", "padding=default", "margin=default"))
