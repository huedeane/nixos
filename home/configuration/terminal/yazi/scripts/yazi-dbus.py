import asyncio
import os
import subprocess
from urllib.parse import unquote, urlparse

from dbus_next.aio import MessageBus
from dbus_next.service import ServiceInterface, method

NAME = "org.freedesktop.FileManager1"
PATH = "/org/freedesktop/FileManager1"


def to_path(uri):
    parsed = urlparse(uri)
    if parsed.scheme in ("", "file"):
        return unquote(parsed.path)
    return None


def open_yazi(uris):
    for uri in uris:
        path = to_path(uri)
        if path is None or not os.path.exists(path):
            continue
        subprocess.Popen(
            ["kitty", "--class", "tui-yazi", "yazi", path],
            start_new_session=True,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )


class FileManager1(ServiceInterface):
    def __init__(self):
        super().__init__(NAME)

    @method()
    def ShowFolders(self, uris: "as", startup_id: "s"):
        open_yazi(uris)

    @method()
    def ShowItems(self, uris: "as", startup_id: "s"):
        open_yazi(uris)

    @method()
    def ShowItemProperties(self, uris: "as", startup_id: "s"):
        open_yazi(uris)


async def main():
    bus = await MessageBus().connect()
    bus.export(PATH, FileManager1())
    await bus.request_name(NAME)
    await bus.wait_for_disconnect()


asyncio.run(main())
