"""Minimal fake of the three Slack Web API methods agentchat uses."""
import json, sys, time
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs
MSGS = []
class H(BaseHTTPRequestHandler):
    def log_message(self, *a): pass
    def reply(self, body):
        b = json.dumps(body).encode(); self.send_response(200)
        self.send_header("Content-Type", "application/json"); self.end_headers(); self.wfile.write(b)
    def do_POST(self):
        d = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
        ts = f"{time.time():.6f}"; time.sleep(0.002)
        MSGS.append({"type": "message", "ts": ts, "text": d["text"], "bot_id": "B1"})
        self.reply({"ok": True, "ts": ts})
    def do_GET(self):
        u = urlparse(self.path); q = {k: v[0] for k, v in parse_qs(u.query).items()}
        if u.path.endswith("conversations.history"):
            ms = [m for m in MSGS if "oldest" not in q or float(m["ts"]) > float(q["oldest"])]
            ms = sorted(ms, key=lambda m: -float(m["ts"]))[: int(q.get("limit", 100))]
            self.reply({"ok": True, "messages": ms})
        elif u.path.endswith("users.info"):
            self.reply({"ok": True, "user": {"profile": {"display_name": "keon"}}})
        elif u.path.endswith("_human"):  # test helper: inject a human message
            ts = f"{time.time():.6f}"; time.sleep(0.002)
            MSGS.append({"type": "message", "ts": ts, "text": q["text"], "user": "U9"}); self.reply({"ok": True})
        else:
            self.reply({"ok": False, "error": "unknown_method"})
HTTPServer(("127.0.0.1", int(sys.argv[1])), H).serve_forever()
