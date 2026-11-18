#!/usr/bin/env python3
"""Watch a keyboard-created native Rex tab and initialize OpenCode without app control."""

import argparse
from contextlib import contextmanager
import fcntl
import hashlib
import json
import math
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
import tempfile
import time
import uuid

RESERVATION_TTL = 30.0
BUNDLED_REX = Path("/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex")
SHELLS = {"bash", "zsh", "fish", "sh", "dash", "ksh", "nu", "xonsh"}
EXEC_SHELLS = {"bash", "zsh", "fish", "sh", "dash", "ksh"}
TERMINAL = "com.superlogical.terminal.shell"


class OpenError(RuntimeError):
    pass


class BusyError(OpenError):
    pass


def wait_until(read, message, timeout=5.0):
    """Poll an explicit state condition, never assume a fixed focus delay is enough."""
    deadline = time.monotonic() + timeout
    while True:
        value = read()
        if value:
            return value
        if time.monotonic() >= deadline:
            raise OpenError(message)
        time.sleep(0.05)


class Rex:
    def __init__(self, executable=None):
        self.executable = executable or (str(BUNDLED_REX) if BUNDLED_REX.is_file() else shutil.which("rex"))
        if not self.executable:
            raise OpenError("Rex CLI is not installed.")
        self.server = None
        self.verified = True

    def route(self, server, expected_host):
        if not isinstance(server, str) or not server or not isinstance(expected_host, str) or not expected_host:
            raise OpenError("Remote Rex requests require an explicit server and expected host identity.")
        self.server, self.verified = server, False
        status = self.call("server.status", {})
        if not isinstance(status, dict) or status.get("host_id") != expected_host:
            raise OpenError("Remote Rex server identity does not match the source terminal's server.")
        self.verified = True

    def call(self, method, args):
        allowed = {"server.status", "client.inspect", "session.view", "session.list", "block.method",
                   "session.set_window_label", "session.set_label", "session.set_block_label"}
        if method not in allowed:
            raise OpenError(f"Unsupported Rex method {method}; this helper does not control the app.")
        if not self.verified and method != "server.status":
            raise OpenError("The remote Rex server has not been verified.")
        command = [self.executable, "--autostart=false", "--timeout=6s"]
        if self.server:
            command.extend(["--server", self.server])
        env = {key: value for key, value in os.environ.items()
               if key not in {"REX_SERVER", "REX_SESSION", "REX_BLOCK", "REX_CLIENT"}}
        try:
            result = subprocess.run(
                [*command, "api", "call", method, json.dumps(args)],
                capture_output=True, text=True, timeout=8, env=env,
            )
        except (OSError, subprocess.TimeoutExpired) as exc:
            raise OpenError(f"Rex request {method} could not complete.") from exc
        if result.returncode:
            raise OpenError(f"Rex request {method} failed: {result.stderr.strip()[:500]}")
        try:
            return json.loads(result.stdout)
        except ValueError as exc:
            raise OpenError(f"Rex request {method} returned invalid JSON.") from exc


def blocks(window):
    return [block for layer in (window.get("layers") or []) for block in (layer.get("blocks") or [])]


def prepare_tab(rex, request):
    """Capture the baseline before Lua queues native New Tab in the app itself."""
    server, expected_host = getattr(request, "server", None), getattr(request, "expected_host", None)
    if server or expected_host:
        rex.route(server, expected_host)
    client = rex.call("client.inspect", {"client_id": request.client})["client"]
    if (client.get("info", {}).get("kind") != "app"
            or client.get("connection_state", "connected") != "connected"
            or request.session not in (client.get("session_ids") or [])):
        raise OpenError("The originating Rex app is no longer connected to this session.")
    before = rex.call("session.view", {"session_id": request.session})
    sources = [block for window in (before.get("windows") or []) for block in blocks(window)
               if block["block_id"] == request.block]
    if len(sources) != 1:
        raise OpenError("The originating terminal no longer exists; no tab was opened.")
    if sources[0].get("owner") != request.client:
        raise OpenError("Open the source terminal in the originating Rex app before trying again.")
    prepared = {
        "client": request.client, "session": request.session, "block": request.block, "cwd": request.cwd,
        "old_window_ids": [window["window_id"] for window in (before.get("windows") or [])],
        "old_session_ids": [item["session_id"] for item in (rex.call("session.list", {}).get("sessions") or [])],
    }
    if server:
        prepared.update(server=server, expected_host=expected_host)
    return prepared


def exec_command(cwd, shell):
    """One shell-quoted command for the new pane, never arbitrary terminal input."""
    if shell not in EXEC_SHELLS:
        raise OpenError(f"In-place OpenCode startup requires a POSIX-style shell; {shell} was left untouched.")
    if not os.path.isabs(cwd) or any(ord(char) < 32 or ord(char) == 127 for char in cwd):
        raise OpenError("The project path is not safe for in-place terminal startup.")
    return ("cd " + shlex.quote(cwd)
            + " && command -v opencode >/dev/null 2>&1 && exec opencode"
            + " || printf '%s\\n' 'OpenCode could not start; check its installation and project path.'\r")


def open_tab(rex, request, timeout=5.0, cancelled=lambda: False):
    """Finish a prepared request; the user-originated app action creates/selects its tab."""
    session = request.session
    old_ids = set(request.old_window_ids)
    old_sessions = set(request.old_session_ids)

    def check_cancelled():
        if cancelled():
            raise OpenError("OpenCode tab request was cancelled; no further terminal changes were made.")

    def change(method, args):
        check_cancelled()
        return rex.call(method, args)

    def view(session_id=None):
        check_cancelled()
        return rex.call("session.view", {"session_id": session_id or session})

    def process(block_id):
        check_cancelled()
        return rex.call("block.method", {"session_id": session, "block_id": block_id, "method": "process"})

    def native_tab():
        current = view()
        new = [(session, current, window) for window in (current.get("windows") or [])
               if window["window_id"] not in old_ids]
        # Native New Tab may create a whole session depending on UI context.
        # Do not assume it adds a window to the source session.
        client = rex.call("client.inspect", {"client_id": request.client})["client"]
        if (client.get("info", {}).get("kind") != "app"
                or client.get("connection_state", "connected") != "connected"):
            raise OpenError("The originating Rex app disconnected during tab creation.")
        attached = client.get("session_ids") or []
        listed = rex.call("session.list", {}).get("sessions") or []
        new_sessions = {item["session_id"] for item in listed} - old_sessions
        new_attached = new_sessions.intersection(attached)
        if len(new_attached) > 1 or (new_attached and new):
            raise OpenError("Multiple tabs appeared during creation; no terminal was replaced.")
        for session_id in new_attached:
            snapshot = view(session_id)
            new.extend((session_id, snapshot, window) for window in (snapshot.get("windows") or []))
        if len(new) > 1:
            raise OpenError("Multiple tabs appeared during creation; no terminal was replaced.")
        if not new:
            return None
        target_session, snapshot, window = new[0]
        starter = blocks(window)
        if len(starter) != 1 or starter[0].get("flavor") != TERMINAL:
            raise OpenError("The new tab is not a single starter shell; no terminal was replaced.")
        owner = starter[0].get("owner")
        if owner is None:
            return None
        if owner != request.client:
            raise OpenError("Another client owns the new tab; no terminal was replaced.")
        if snapshot.get("active_window_id") != window["window_id"]:
            raise OpenError("The new tab is no longer active; no terminal was replaced.")
        return target_session, window, starter[0]["block_id"]

    session, window, starter_id = wait_until(native_tab, "Native New Tab did not produce an owned tab in time.", timeout)

    def idle_shell():
        proc = process(starter_id)
        child, foreground = proc.get("child") or {}, proc.get("foreground") or {}
        child_name = Path(child.get("path") or child.get("name", "")).name.lstrip("-")
        foreground_name = Path(foreground.get("path") or foreground.get("name", "")).name.lstrip("-")
        if proc.get("last_exit") is not None:
            raise OpenError("The starter shell exited; it was left untouched.")
        if child.get("pid") and child_name in SHELLS and foreground.get("pid") == child["pid"]:
            return child["pid"], foreground["pid"], child_name
        # Rex uses /usr/bin/login as the terminal child on macOS. Accept only
        # its direct foreground shell, never a nested shell or another command.
        ancestors = proc.get("ancestors") or []
        if (child_name == "login" and child.get("pid") and foreground_name in SHELLS
                and foreground.get("pid") and [item.get("pid") for item in ancestors] == [child["pid"]]):
            return child["pid"], foreground["pid"], foreground_name
        if child.get("pid") and child_name not in SHELLS | {"login"}:
            raise OpenError("The new tab is not running a shell; it was left untouched.")
        return None

    def check_window(expected_ids):
        current = view()
        matching = [item for item in (current.get("windows") or []) if item["window_id"] == window["window_id"]]
        if len(matching) == 1:
            current_blocks = blocks(matching[0])
            if (current.get("active_window_id") == window["window_id"]
                    and {item["block_id"] for item in current_blocks} == expected_ids
                    and any(item["block_id"] == starter_id and item.get("owner") == request.client
                            for item in current_blocks)):
                return
        raise OpenError("The new tab changed during setup; no terminal was closed.")

    def terminal(method, args=None):
        check_cancelled()
        params = {"session_id": session, "block_id": starter_id, "method": method}
        if args is not None:
            params["args"] = args
        return change("block.method", params) if method == "write" else rex.call("block.method", params)

    def editing():
        identity = idle_shell()
        if not identity:
            return None
        # Do not interrupt profile initialization or a canonical password/read
        # prompt. Supported interactive line editors put their tty in raw mode.
        mode = terminal("input_mode")
        return identity if mode.get("canonical") is False else None

    def screen():
        reply = terminal("format", {"format": "vt", "extra_cursor": True, "max_bytes": 65536})
        if "id" in reply or not isinstance(reply.get("content"), str):
            raise OpenError("Cannot verify the new shell's input state safely; it was left untouched.")
        return reply["content"]

    identity = wait_until(editing, "The new shell is not ready for interactive input; it was left untouched.", timeout)
    command = exec_command(request.cwd, identity[2])
    check_window({starter_id})
    if terminal("modes").get("screen") == "alternate":
        raise OpenError("The new shell is already in a full-screen program; it was left untouched.")
    before_interrupt = screen()
    if idle_shell() != identity:
        raise OpenError("The new shell changed before startup; it was left untouched.")
    # Clear partial input only in the newly created, app-owned shell. Wait for
    # its redraw and line editor to return before submitting any command.
    terminal("write", {"data": "\x03"})

    def cleared():
        if screen() == before_interrupt:
            return None
        ready = editing()
        if ready and ready != identity:
            raise OpenError("The new shell changed while clearing input; no command was submitted.")
        return ready

    wait_until(cleared, "The new shell did not confirm cleared input; no command was submitted.", timeout)
    check_window({starter_id})
    if idle_shell() != identity:
        raise OpenError("The new shell is no longer idle; no command was submitted.")
    terminal("write", {"data": command})

    def running():
        proc = process(starter_id)
        if proc.get("last_exit") is not None:
            raise OpenError("OpenCode exited during startup in the new tab.")
        foreground = proc.get("foreground") or proc.get("child") or {}
        names = {Path(foreground.get(key) or "").name for key in ("name", "path", "invoked_path", "script", "argv0")}
        if names.intersection({"opencode", "opencode.js", "opencode-wrapped", ".opencode-wrapped"}):
            return True
        child = proc.get("child") or {}
        child_name = Path(child.get("path") or child.get("name", "")).name
        # After an in-place exec, macOS login can remain the foreground group
        # leader in Rex's report. Require OpenCode's own title AND the transition
        # to an alternate screen, not an inherited title or a different program.
        if child_name == "login" and child.get("pid") and foreground.get("pid") in (None, child["pid"]):
            title = terminal("title").get("title")
            return (isinstance(title, str) and title.casefold().startswith("opencode")
                    and terminal("modes").get("screen") == "alternate")
        return False

    wait_until(running, "OpenCode did not start in the new shell; inspect that tab for its error.", timeout)
    check_window({starter_id})
    change("session.set_block_label", {"session_id": session, "block_id": starter_id, "label": "opencode"})
    change("session.set_window_label", {"session_id": session, "window_id": window["window_id"], "label": "OpenCode"})
    if session not in old_sessions:
        change("session.set_label", {"session_id": session, "label": "OpenCode"})
    return {"session_id": session, "window_id": window["window_id"], "block_id": starter_id}


@contextmanager
def client_lock(directory, client, timeout=30.0):
    """Serialize native UI actions for this app, including across sessions."""
    directory.mkdir(mode=0o700, parents=True, exist_ok=True)
    key = hashlib.sha256(client.encode()).hexdigest()
    fd = os.open(directory / (key + ".lock"), os.O_CREAT | os.O_RDWR | getattr(os, "O_NOFOLLOW", 0), 0o600)
    try:
        def acquire():
            try:
                fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
                return True
            except BlockingIOError:
                return False
        try:
            wait_until(acquire, "Another OpenCode tab is still opening; try again.", timeout)
        except OpenError as exc:
            raise BusyError(str(exc)) from exc
        yield
    finally:
        os.close(fd)


def state_directory():
    return Path(os.environ.get("XDG_STATE_HOME", str(Path.home() / ".local/state"))) / "rex/opencode-tab"


def write_json(path, value):
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(dir=path.parent, prefix=".request-")
    try:
        with os.fdopen(fd, "w") as handle:
            json.dump(value, handle)
            handle.write("\n")
        os.replace(name, path)
    finally:
        if os.path.exists(name):
            os.unlink(name)


def write_status(directory, value):
    write_json(directory / "status.json", {"time": time.time(), **value})


def request_path(directory, client):
    return directory / (hashlib.sha256(client.encode()).hexdigest() + ".request.json")


def cancellation_path(directory, client, token):
    key = hashlib.sha256((client + "\0" + token).encode()).hexdigest()
    return directory / (key + ".cancel.json")


def read_request(path):
    """Call under the app lock; quarantine damaged state instead of wedging forever."""
    try:
        value = json.loads(path.read_text())
    except FileNotFoundError:
        return None
    except ValueError:
        value = None
    valid = isinstance(value, dict)
    if valid:
        token, expires = value.get("token"), value.get("expires")
        valid = (isinstance(token, str) and len(token) == 32 and all(c in "0123456789abcdef" for c in token)
                 and type(expires) in (int, float) and 0 < expires < 1e12 and math.isfinite(expires)
                 and all(isinstance(value.get(key), str) and value[key]
                         for key in ("client", "session", "block", "cwd"))
                 and all(isinstance(value.get(key), list) and all(isinstance(item, str) for item in value[key])
                         for key in ("old_window_ids", "old_session_ids")))
        if "server" in value or "expected_host" in value:
            valid = valid and all(isinstance(value.get(key), str) and value[key]
                                  for key in ("server", "expected_host"))
    if not valid:
        path.replace(path.with_name(path.name + ".invalid-" + uuid.uuid4().hex))
        return None
    return value


def reserve_tab(directory, rex, request):
    """Reserve one operation per app and snapshot before native creation can run."""
    with client_lock(directory, request.client, timeout=0):
        path = request_path(directory, request.client)
        previous = read_request(path)
        if previous:
            cancelled = cancellation_path(directory, request.client, previous["token"])
            if previous["expires"] > time.time() and not cancelled.exists():
                raise OpenError("Another OpenCode tab is still opening; try again.")
            cancelled.unlink(missing_ok=True)
        prepared = prepare_tab(rex, request)
        prepared.update(token=uuid.uuid4().hex, expires=time.time() + RESERVATION_TTL)
        try:
            write_json(path, prepared)
            write_status(directory, {"status": "opening", "phase": "waiting_for_native_tab"})
        except OSError:
            path.unlink(missing_ok=True)
            raise
        return {"token": prepared["token"]}


def watch_tab(directory, rex, client, token, timeout=5.0):
    with client_lock(directory, client, timeout=0):
        path = request_path(directory, client)
        prepared = read_request(path)
        if not prepared:
            raise OpenError("The OpenCode tab request is unavailable; try the shortcut again.")
        if prepared["token"] != token:
            raise OpenError("This OpenCode tab request was superseded; no terminal was changed.")
        cancelled = cancellation_path(directory, client, token)
        try:
            if prepared["expires"] <= time.time():
                raise OpenError("The OpenCode tab request expired; try the shortcut again.")
            if prepared["client"] != client:
                raise OpenError("The OpenCode tab request has an invalid client.")
            if prepared.get("server"):
                rex.route(prepared["server"], prepared["expected_host"])
            result = open_tab(rex, argparse.Namespace(**prepared), timeout, cancelled=cancelled.exists)
            if cancelled.exists():
                raise OpenError("OpenCode tab request was cancelled.")
            write_status(directory, {"status": "ok", **result})
            return result
        finally:
            path.unlink(missing_ok=True)
            cancelled.unlink(missing_ok=True)


def cancel_tab(directory, client, token):
    # A token-specific marker must be writable even while the watcher holds the
    # app lock. It is checked before discovery and every terminal mutation.
    cancelled = cancellation_path(directory, client, token)
    write_json(cancelled, {"token": token})
    path = request_path(directory, client)
    try:
        with client_lock(directory, client, timeout=0):
            prepared = read_request(path)
            matches = bool(prepared and prepared["token"] == token)
            if matches:
                path.unlink()
                write_status(directory, {"status": "error", "message": "OpenCode tab request cancelled before native creation."})
            cancelled.unlink(missing_ok=True)
            return {"cancelled": matches}
    except BusyError:
        # Read only here: a valid request is atomically written, and the locked
        # watcher must do its own cleanup. Never overwrite a newer reservation.
        try:
            prepared = json.loads(path.read_text())
        except FileNotFoundError:
            cancelled.unlink(missing_ok=True)
            return {"cancelled": False}
        except ValueError:
            return {"cancelled": True}
        if isinstance(prepared, dict) and prepared.get("token") == token:
            return {"cancelled": True}
        cancelled.unlink(missing_ok=True)
        return {"cancelled": False}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--client")
    parser.add_argument("--session")
    parser.add_argument("--block")
    parser.add_argument("--cwd")
    parser.add_argument("--server", help="explicit remote Rex host label, captured by the GUI action")
    parser.add_argument("--expected-host", help="expected remote server host_id; required with --server")
    parser.add_argument("--rex", help="Rex CLI executable; defaults to the bundled Mac CLI, then PATH")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--prepare", action="store_true", help="reserve and snapshot before the keyboard queues New Tab")
    mode.add_argument("--watch", metavar="TOKEN", help="finish a reserved keyboard-created tab; never control the app")
    mode.add_argument("--cancel", metavar="TOKEN", help="cancel a reservation if the watcher cannot start")
    mode.add_argument("--status", action="store_true", help="show the last helper result, including background errors")
    args = parser.parse_args(argv)
    directory = state_directory()
    if args.status:
        try:
            result = json.loads((directory / "status.json").read_text())
        except (OSError, ValueError):
            print("No OpenCode tab helper result recorded.", file=sys.stderr)
            return 1
        print(json.dumps(result, indent=2))
        return 0 if result.get("status") == "ok" else 1
    if not args.client:
        parser.error("--client is required unless --status is used")
    if args.prepare and not all((args.session, args.block, args.cwd)):
        parser.error("--session, --block, and --cwd are required with --prepare")
    try:
        if args.prepare:
            if not os.path.isabs(args.cwd) or (not args.server and not os.path.isdir(args.cwd)):
                raise OpenError("The requested working directory must exist locally or belong to the explicit remote host.")
            result = reserve_tab(directory, Rex(args.rex), args)
        elif args.watch:
            result = watch_tab(directory, Rex(args.rex), args.client, args.watch)
        else:
            result = cancel_tab(directory, args.client, args.cancel)
        print(json.dumps(result))
        return 0
    except (OpenError, OSError, KeyError, TypeError, ValueError) as exc:
        message = str(exc)
        try:
            write_status(directory, {"status": "error", "message": message})
        except OSError:
            pass  # Preserve the original failure if status storage is unavailable.
        print(message, file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
