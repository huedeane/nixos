import os
import socket
import subprocess
import sys
import threading

SOCKET = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/run/user/1000"), "mpd/socket")
PARTITIONS = ["default", "single"]


class Client:
    def __init__(self, partition="default"):
        self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.sock.connect(SOCKET)
        self.file = self.sock.makefile("rw", encoding="utf-8")
        self.file.readline()
        if partition != "default":
            try:
                self.command("newpartition " + partition)
            except RuntimeError:
                pass
            self.command("partition " + partition)

    def command(self, line):
        self.file.write(line + "\n")
        self.file.flush()
        pairs = {}
        while True:
            reply = self.file.readline()
            if not reply:
                raise ConnectionError("mpd closed the connection")
            reply = reply.rstrip("\n")
            if reply == "OK":
                return pairs
            if reply.startswith("ACK"):
                raise RuntimeError(reply)
            key, _, value = reply.partition(": ")
            pairs.setdefault(key, value)


def current(client):
    status = client.command("status")
    if status.get("state") != "play":
        return None, None
    return status.get("songid"), client.command("currentsong").get("file")


def watch(name, hook):
    # Runs the hook whenever a new song starts playing, no matter who changed it
    # (rmpc TUI, `rmpc next` from a keybind, or the queue moving on by itself)
    try:
        client = Client(name)
        last, _ = current(client)
        while True:
            client.command("idle player")
            songid, file = current(client)
            if songid is not None and songid != last and file:
                subprocess.run([hook], env={**os.environ, "FILE": file})
            if songid is not None:
                last = songid
    except Exception as error:
        print(f"{name}: {error}", file=sys.stderr, flush=True)
        os._exit(1)


if len(sys.argv) != 2:
    sys.exit("usage: mpd-song-change <hook>")

threads = [threading.Thread(target=watch, args=(name, sys.argv[1])) for name in PARTITIONS]
for thread in threads:
    thread.start()
for thread in threads:
    thread.join()
