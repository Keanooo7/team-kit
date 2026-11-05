#!/usr/bin/env bash
# End-to-end test of the kit against a fake Slack. No token, touches nothing outside a temp dir.
set -euo pipefail
KIT="$(cd "$(dirname "$0")/.." && pwd)"; AC="$KIT/bin/agentchat"
T="$(mktemp -d)"; PORT=$((20000 + RANDOM % 20000))
python3 -I "$KIT/test/fake_slack.py" "$PORT" & SRV=$!; trap 'kill $SRV 2>/dev/null; wait $SRV 2>/dev/null; rm -rf "$T"' EXIT; sleep 0.5
export AGENTCHAT_API="http://127.0.0.1:$PORT" AGENTCHAT_STATE="$T/state" SLACK_BOT_TOKEN=x AGENTCHAT_CHANNEL=C1
pass() { echo "ok   $1"; }; fail() { echo "FAIL $1"; exit 1; }

# install into a throwaway repo (PATH without ~/.local/bin so no symlink is made)
git init -q "$T/proj"; printf 'AGENTCHAT_NAME=bob\n' > "$T/env"
AGENTCHAT_ENV_FILE="$T/env" PATH=/usr/bin:/bin:$(dirname "$(command -v python3)") "$KIT/install.sh" "$T/proj" >/dev/null
AGENTCHAT_ENV_FILE="$T/env" PATH=/usr/bin:/bin:$(dirname "$(command -v python3)") "$KIT/install.sh" "$T/proj" >/dev/null  # re-run is safe
python3 -I -c "import json,sys; h=json.load(open(sys.argv[1]))['hooks']; assert len(h['UserPromptSubmit'])==1 and len(h['PreToolUse'])==1" "$T/proj/.claude/settings.local.json" && pass "install is idempotent"
[ -f "$T/proj/CONTRACT.md" ] && [ -f "$T/proj/.claude/commands/ship.md" ] && grep -qx .claude/settings.local.json "$T/proj/.git/info/exclude" && pass "install copies files and excludes personal ones"

# posting
AGENTCHAT_NAME=alice "$AC" merged "verifier: scores diffs" | grep -q "posted: \[alice\] MERGED: verifier: scores diffs" && pass "merged"
AGENTCHAT_NAME=alice "$AC" blocked bob "need /score schema" >/dev/null && pass "blocked"
"$AC" bogus 2>/dev/null && fail "bad usage should exit nonzero" || pass "bad usage rejected"
curl -s "$AGENTCHAT_API/_human?text=lunch%20is%20here" >/dev/null

# inbox hook: first prompt sees backlog, labels humans, hides own posts, second prompt sees only new
AGENTCHAT_NAME=bob "$AC" merged "bob's own post" >/dev/null
OUT=$(echo '{"session_id":"s1"}' | AGENTCHAT_NAME=bob "$AC" hook-inbox)
echo "$OUT" | grep -q "BLOCKED on bob: need /score schema" && echo "$OUT" | grep -q "\[keon (human)\] lunch is here" && pass "inbox shows teammates + humans"
echo "$OUT" | grep -q "bob's own" && fail "inbox showed own post" || pass "inbox hides own posts"
OUT=$(echo '{"session_id":"s1"}' | AGENTCHAT_NAME=bob "$AC" hook-inbox); [ -z "$OUT" ] && pass "inbox empty when nothing new"
AGENTCHAT_NAME=alice "$AC" contract "score is now 0-100" >/dev/null
OUT=$(echo '{"session_id":"s1"}' | AGENTCHAT_NAME=bob "$AC" hook-inbox); echo "$OUT" | grep -q "CONTRACT CHANGE: score is now 0-100" && ! echo "$OUT" | grep -q MERGED && pass "inbox shows only new messages"
OUT=$(echo '{"session_id":"s1"}' | AGENTCHAT_API=http://127.0.0.1:1 AGENTCHAT_NAME=bob "$AC" hook-inbox; echo "rc=$?"); [ "$OUT" = "rc=0" ] && pass "inbox silent and exit 0 when Slack is down"

# owners hook
cat > "$T/proj/CONTRACT.md" <<'MD'
## Owners
| Path | Owner | What it does |
|---|---|---|
| `src/verifier/` | alice | |
| `src/verifier/ui/` | bob | |
| `demo/` | bob, keon | |
MD
own() { printf '{"tool_input":{"file_path":"%s"},"cwd":"%s"}' "$T/proj/$1" "$T/proj" | CLAUDE_PROJECT_DIR="$T/proj" AGENTCHAT_NAME=bob "$AC" hook-owners; }
own src/verifier/core.py | grep -q '"ask"' && pass "asks when editing another owner's area"
[ -z "$(own src/verifier/ui/app.tsx)" ] && pass "longest prefix wins (own subdir)"
[ -z "$(own demo/script.md)" ] && pass "co-owned dir allowed"
[ -z "$(own README.md)" ] && pass "unowned file allowed"
own CONTRACT.md | grep -q '"ask"' && pass "CONTRACT.md always asks"
echo "all passed"
