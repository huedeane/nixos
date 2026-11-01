import os
import socket
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
            self.command("partition " + partition)

    def command(self, line):
        self.file.write(line + "\n")
        self.file.flush()
        pairs = []
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
            pairs.append((key, value))

    def try_command(self, line):
        try:
            return self.command(line)
        except RuntimeError:
            return []

    def status(self):
        return dict(self.command("status"))

    def close(self):
        self.sock.close()


def quote(value):
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'


def ensure_partitions():
    client = Client()
    for name in PARTITIONS[1:]:
        client.try_command("newpartition " + name)
    client.close()


def status_of(name):
    client = Client(name)
    status = client.status()
    client.close()
    return status


def switch(target):
    ensure_partitions()
    outputs = set()
    for name in PARTITIONS:
        client = Client(name)
        outputs.update(value for key, value in client.command("outputs") if key == "outputname")
        if name != target and client.status().get("state") == "play":
            client.command("pause 1")
        client.close()

    client = Client(target)
    for output in sorted(outputs):
        client.try_command("moveoutput " + quote(output))
    client.close()


def watch():
    ensure_partitions()
    lock = threading.Lock()
    states = {name: status_of(name).get("state") for name in PARTITIONS}

    def loop(name):
        try:
            idler = Client(name)
            while True:
                idler.command("idle player")
                with lock:
                    status = status_of(name)
                    if "outputs are disabled" in status.get("error", ""):
                        switch(name)
                        client = Client(name)
                        client.command("clearerror")
                        client.command("play")
                        client.close()
                    elif status.get("state") == "play" and states[name] != "play":
                        switch(name)
                    for other in PARTITIONS:
                        states[other] = status_of(other).get("state")
        except Exception as error:
            print(f"{name}: {error}", file=sys.stderr, flush=True)
            os._exit(1)

    threads = [threading.Thread(target=loop, args=(name,)) for name in PARTITIONS]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()


if len(sys.argv) == 2 and sys.argv[1] == "watch":
    watch()
elif len(sys.argv) == 3 and sys.argv[1] == "switch":
    switch(sys.argv[2])
else:
    sys.exit("usage: mpd-partition watch | switch <partition>")
