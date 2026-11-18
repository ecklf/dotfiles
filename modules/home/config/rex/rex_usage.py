#!/usr/bin/env python3
"""Read Codex plan limits; no auth files, model turns, cache, or service."""

import argparse
from datetime import datetime, timezone
import json
import math
import os
import queue
import selectors
import signal
import subprocess
import sys
import threading
import time

TIMEOUT = 10.0
REFRESH = 60.0
MESSAGES = {
    "missing_cli": "Codex CLI unavailable; install codex and check PATH.",
    "login_required": "Sign into your ChatGPT subscription with `codex login`.",
    "subscription_required": "ChatGPT login required; API keys do not expose plan limits.",
    "read_error": "Could not read usage; check Codex login with `codex login`.",
    "protocol_error": "Codex returned an invalid usage response.",
    "timeout": "Codex usage request timed out.",
    "cancelled": "Usage refresh cancelled.",
    "quota_unavailable": "Some plan-limit fields are unavailable.",
}


class ReadError(Exception):
    pass


class Shutdown:
    """Cooperative cancellation; signal handlers neither raise nor acquire locks."""

    def __init__(self):
        self.signum = None
        self.cancelled = False

    def handle(self, signum, _frame):
        if self.signum is None:
            self.signum = signum

    def is_set(self):
        return self.cancelled or self.signum is not None

    def set(self):
        self.cancelled = True


def empty_snapshot(error):
    return {"status": "error", "error": error, "fetched_at": None,
            "five_hour": {"remaining_percent": None, "resets_at": None},
            "weekly": {"remaining_percent": None, "resets_at": None}}


def finite_number(value):
    if type(value) not in (int, float):
        return None
    try:
        return float(value) if math.isfinite(value) else None
    except OverflowError:
        return None


def sanitize(result):
    """Whitelist only account-window numbers; never expose backend strings."""
    if not isinstance(result, dict):
        raise ReadError("protocol_error")
    buckets = result.get("rateLimitsByLimitId")
    quota = (buckets["codex"] if isinstance(buckets, dict) and "codex" in buckets
             else result.get("rateLimits"))
    if not isinstance(quota, dict) or quota.get("limitId") not in (None, "codex"):
        quota = {}
    snapshot = empty_snapshot("quota_unavailable")
    snapshot["fetched_at"] = datetime.now(timezone.utc).isoformat(timespec="seconds")
    for key, duration in (("five_hour", 300), ("weekly", 10080)):
        # Match by duration, not by primary/secondary ordering.
        matches = [w for w in (quota.get("primary"), quota.get("secondary"))
                   if isinstance(w, dict) and type(w.get("windowDurationMins")) is int
                   and w["windowDurationMins"] == duration]
        if len(matches) != 1:
            continue
        window = matches[0]
        used = finite_number(window.get("usedPercent"))
        reset = window.get("resetsAt")
        snapshot[key] = {
            "remaining_percent": None if used is None else 100 - min(100, max(0, used)),
            "resets_at": reset if type(reset) is int and 0 <= reset < 253402300800 else None,
        }
    complete = all(v is not None for key in ("five_hour", "weekly")
                   for v in snapshot[key].values())
    snapshot.update(status="ok" if complete else "unavailable",
                    error=None if complete else "quota_unavailable")
    return snapshot


def fetch_snapshot(timeout=TIMEOUT, cancel=None):
    """One bounded app-server session. Only this session's child is reaped."""
    child = None
    deadline = time.monotonic() + timeout
    try:
        child = subprocess.Popen(["codex", "app-server", "-c", 'model_provider="openai"'],
                                 stdin=subprocess.PIPE,
                                 stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
                                 bufsize=0)
        with selectors.DefaultSelector() as selector:
            selector.register(child.stdout, selectors.EVENT_READ)
            pending = bytearray()

            def response(request_id):
                while True:
                    if cancel is not None and cancel.is_set():
                        raise ReadError("cancelled")
                    remaining = deadline - time.monotonic()
                    if remaining <= 0:
                        raise ReadError("timeout")
                    if b"\n" not in pending:
                        if not selector.select(min(remaining, 0.1)):
                            continue
                        chunk = os.read(child.stdout.fileno(), 65536)
                        if not chunk:
                            raise ReadError("protocol_error")
                        pending.extend(chunk)
                        if len(pending) > 1024 * 1024:
                            raise ReadError("protocol_error")
                        continue
                    line, _, rest = pending.partition(b"\n")
                    pending[:] = rest
                    message = json.loads(line)
                    if not isinstance(message, dict):
                        raise ReadError("protocol_error")
                    if type(message.get("id")) is not int or message["id"] != request_id:
                        continue  # Notifications and unrelated responses carry no usage.
                    if "error" in message:
                        raise ReadError("read_error")
                    if not isinstance(message.get("result"), dict):
                        raise ReadError("protocol_error")
                    return message["result"]

            def send(message):
                child.stdin.write((json.dumps(message) + "\n").encode())
                child.stdin.flush()

            send({"id": 1, "method": "initialize", "params": {
                "clientInfo": {"name": "rex_usage", "version": "1.0"},
                "capabilities": {"explicitGatewayOauth": True}}})
            response(1)
            send({"method": "initialized"})
            send({"id": 2, "method": "account/read", "params": {"refreshToken": False}})
            account_result = response(2)
            if "account" not in account_result:
                raise ReadError("protocol_error")
            account = account_result["account"]
            if account is None:
                raise ReadError("login_required")
            if not isinstance(account, dict) or not isinstance(account.get("type"), str):
                raise ReadError("protocol_error")
            if account["type"] != "chatgpt":
                raise ReadError("subscription_required")
            send({"id": 3, "method": "account/rateLimits/read", "params": {}})
            return sanitize(response(3))
    except FileNotFoundError:
        return empty_snapshot("missing_cli")
    except ReadError as error:
        return empty_snapshot(error.args[0])
    except (ValueError, RecursionError):
        return empty_snapshot("protocol_error")
    except OSError:
        return empty_snapshot("read_error")
    finally:
        if child is not None:
            try:
                if child.poll() is None:
                    child.terminate()
                try:
                    child.wait(timeout=0.3)
                except subprocess.TimeoutExpired:
                    child.kill()
                    child.wait()
            finally:
                child.stdin.close()
                child.stdout.close()


def countdown(reset, now):
    if reset is None:
        return "Reset time unavailable"
    seconds = math.ceil(reset - now)
    if seconds <= 0:
        return "Reset due · refresh needed"
    days, seconds = divmod(seconds, 86400)
    hours, seconds = divmod(seconds, 3600)
    minutes = seconds // 60
    duration = (f"{days}d {hours}h" if days else f"{hours}h {minutes}m" if hours
                else f"{minutes}m" if minutes else "<1m")
    return "Resets in " + duration


DIGITS = {
    "0": ("█▀█", "█ █", "▀▀▀"), "1": ("▀█ ", " █ ", "▀▀▀"),
    "2": ("▀▀█", "█▀▀", "▀▀▀"), "3": ("▀▀█", " ▀█", "▀▀▀"),
    "4": ("█ █", "▀▀█", "  ▀"), "5": ("█▀▀", "▀▀█", "▀▀▀"),
    "6": ("█▀▀", "█▀█", "▀▀▀"), "7": ("▀▀█", "  █", "  ▀"),
    "8": ("█▀█", "█▀█", "▀▀▀"), "9": ("█▀█", "▀▀█", "▀▀▀"),
}


def quota_panel(window, label, width, now, large=False, stacked=False):
    percent = finite_number(window["remaining_percent"])
    if percent is not None:
        percent = min(100, max(0, percent))
    number = "—" if percent is None else f"{percent:g}"
    value = "unavailable" if percent is None else number + "% left"
    if stacked:
        gap = max(1, width - len(label) - len(value))
        rows = [[(label, "muted"), (" " * gap + value, "hero")]]
    else:
        rows = [[(label, "muted")]]
        if large and number.isascii() and number.isdigit() and len(number) * 4 + 6 <= width:
            for line in range(3):
                suffix = " % left" if line == 2 else ""
                rows.append([(" ".join(DIGITS[digit][line] for digit in number), "hero"),
                             (suffix, "muted")])
        else:
            rows.append([(value, "hero" if percent is not None else "muted")])
    # A fine half-cell end cap keeps the meter precise without a heavy block fill.
    units = 0 if percent is None else round(width * 2 * percent / 100)
    full, half = divmod(units, 2)
    filled = "━" * full + ("╸" if half else "")
    rows.append([(filled, "fill"), ("─" * max(0, width - len(filled)), "track")])
    rows.append([(countdown(window["resets_at"], now), "muted")])
    return rows


def presentation(snapshot, now=None, width=54, compact=False):
    """Monochrome instrument panel, responsive down to a narrow terminal."""
    now = time.time() if now is None else now
    width = max(0, min(80, int(width)))
    heading = "PLAN LIMITS"
    rows = [[("OPENAI", "title"),
             (" " * max(1, width - 6 - len(heading)) + heading, "muted")],
            [("─" * width, "track")], []]
    if width >= 40:
        left_width = (width - 5) // 2
        right_width = width - left_width - 5
        panels = [quota_panel(snapshot[key], label, size, now, large=not compact)
                  for key, label, size in (("five_hour", "5-HOUR", left_width),
                                          ("weekly", "WEEKLY", right_width))]
        # Missing or fractional values may use one text row instead of three digits.
        if len(panels[0]) != len(panels[1]):
            panels = [quota_panel(snapshot[key], label, size, now)
                      for key, label, size in (("five_hour", "5-HOUR", left_width),
                                              ("weekly", "WEEKLY", right_width))]
        for left, right in zip(*panels):
            used = sum(len(text) for text, _ in left)
            # Clip reset captions to their own column, not into the other meter.
            clipped_left, available = [], left_width
            for text, tone in left:
                clipped_left.append((text[:available], tone))
                available -= len(text[:available])
            rows.append(clipped_left + [(" " * max(0, left_width - used) + "  │  ", "track")] + right)
    else:
        for key, label in (("five_hour", "5-HOUR"), ("weekly", "WEEKLY")):
            rows.extend(quota_panel(snapshot[key], label, width, now, stacked=True))
            rows.append([])
    while rows and not rows[-1]:
        rows.pop()
    rows.extend([[], [("─" * width, "track")]])
    if snapshot["error"]:
        prefix = "STALE · " if snapshot["status"] == "stale" else ""
        rows.append([(prefix + MESSAGES.get(snapshot["error"], "Usage unavailable."), "warning")])
    clipped = []
    for row in rows:
        spans, remaining = [], width
        for text, tone in row:
            spans.append((text[:remaining], tone))
            remaining -= len(text[:remaining])
        clipped.append(spans)
    return clipped


def render(snapshot, now=None, width=54):
    return "\n".join("".join(text for text, _ in row)
                     for row in presentation(snapshot, now, width)).rstrip()


def terminal_styles(screen):
    import curses

    styles = {"text": curses.A_NORMAL, "title": curses.A_BOLD, "hero": curses.A_BOLD,
              "muted": curses.A_DIM, "track": curses.A_DIM,
              "fill": curses.A_NORMAL, "warning": curses.A_BOLD}
    if curses.has_colors():
        try:
            # Inherit the theme; visual hierarchy comes from weight, not color.
            curses.use_default_colors()
        except curses.error:
            pass
    screen.bkgd(" ", curses.A_NORMAL)
    return styles


def apply_result(previous, result):
    if result["status"] == "error" and previous and previous["fetched_at"]:
        return dict(previous, status="stale", error=result["error"])
    return result


def interactive(screen, cancel=None):
    import curses

    try:
        curses.curs_set(0)
    except curses.error:
        pass
    screen.timeout(100)
    styles = terminal_styles(screen)
    results = queue.Queue(maxsize=1)
    cancel = threading.Event() if cancel is None else cancel
    worker = None
    snapshot = None
    next_fetch = next_draw = 0.0
    try:
        while not cancel.is_set():
            now = time.monotonic()
            if worker is None and now >= next_fetch:
                worker = threading.Thread(
                    target=lambda: results.put(fetch_snapshot(cancel=cancel)))
                worker.start()
            try:
                result = results.get_nowait()
            except queue.Empty:
                pass
            else:
                worker.join()
                worker = None
                snapshot = apply_result(snapshot, result)
                next_fetch = now + REFRESH
                next_draw = 0
            if now >= next_draw:
                height, width = screen.getmaxyx()
                columns = max(0, min(64, width - 4))
                lines = (presentation(snapshot, width=columns, compact=height < 12) if snapshot else
                         [[("OPENAI", "title")], [("Fetching plan limits…", "muted")]])
                if len(lines) + 1 > height:
                    lines = [line for line in lines if line]
                if columns < 24 or len(lines) + 1 > height:
                    lines = [[("Resize popup to see plan limits", "muted")]]
                footer = [("r", "title"), (" refresh   ", "muted"),
                          ("q", "title"), (" close", "muted")]
                state = ("UPDATING" if worker is not None else
                         "STALE" if snapshot and snapshot["status"] == "stale" else "")
                if not state and snapshot and snapshot["status"] == "ok":
                    state = "LIVE · " + snapshot["fetched_at"][11:16] + " UTC"
                gap = columns - sum(len(text) for text, _ in footer) - len(state)
                if state and gap >= 2:
                    footer.append((" " * gap + state, "muted"))
                top = max(0, (height - len(lines) - 1) // 2)
                left = max(0, (width - columns) // 2)
                screen.erase()
                for row, spans in enumerate(lines + [footer], top):
                    if row >= height:
                        break
                    offset = 0
                    for text, tone in spans:
                        count = max(0, columns - offset)
                        try:
                            screen.addnstr(row, left + offset, text, count, styles[tone])
                        except curses.error:
                            pass
                        offset += min(count, len(text))
                screen.refresh()
                next_draw = now + 1
            key = screen.getch()
            if key in (ord("q"), ord("Q"), 27):
                break
            if key in (ord("r"), ord("R")):
                next_fetch = next_draw = 0
            elif key == curses.KEY_RESIZE:
                next_draw = 0
    finally:
        cancel.set()
        if worker is not None:
            worker.join()  # Cancellation interrupts the selector within 100 ms, then reaps.


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--once", action="store_true", help="print one plain-text snapshot")
    mode.add_argument("--json", action="store_true", help="print one sanitized JSON snapshot")
    args = parser.parse_args(argv)
    shutdown = Shutdown()
    previous = {}
    status = 1
    try:
        for signum in (signal.SIGTERM, signal.SIGHUP):
            previous[signum] = signal.signal(signum, shutdown.handle)
        if not args.once and not args.json and sys.stdin.isatty() and sys.stdout.isatty():
            try:
                import curses
            except ImportError:
                print("Curses unavailable; use --once or --json.", file=sys.stderr)
            else:
                try:
                    curses.wrapper(interactive, cancel=shutdown)
                except curses.error:
                    print("Interactive terminal unavailable; use --once or --json.", file=sys.stderr)
                else:
                    status = 0
        else:
            snapshot = fetch_snapshot(cancel=shutdown)
            if not shutdown.is_set():
                print(json.dumps(snapshot, allow_nan=False) if args.json else render(snapshot))
            status = 0 if snapshot["status"] == "ok" else 1
    except KeyboardInterrupt:
        status = 130
    finally:
        for signum, handler in previous.items():
            signal.signal(signum, handler)
    return 128 + shutdown.signum if shutdown.signum is not None else status


if __name__ == "__main__":
    sys.exit(main())
