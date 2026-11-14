#!/usr/bin/env bash
# End-to-end test of the kit against a fake Slack. No token, touches nothing outside a temp dir.
set -euo pipefail
KIT="$(cd "$(dirname "$0")/.." && pwd)"; AC="$KIT/bin/agentchat"
T="$(mktemp -d)"; PORT=$((20000 + RANDOM % 20000))
python3 -I "$KIT/test/fake_slack.py" "$PORT" & SRV=$!; trap 'kill $SRV 2>/dev/null; wait $SRV 2>/dev/null || true; rm -rf "$T"' EXIT; sleep 0.5
export AGENTCHAT_API="http://127.0.0.1:$PORT" AGENTCHAT_STATE="$T/state" SLACK_BOT_TOKEN=x AGENTCHAT_CHANNEL=C1
pass() { echo "ok   $1"; }; fail() { echo "FAIL $1"; exit 1; }

# install into a throwaway repo (PATH without ~/.local/bin so no symlink is made)
git init -q "$T/proj"; printf 'AGENTCHAT_NAME=bob\n' > "$T/env"
inst() { AGENTCHAT_ENV_FILE="$T/env" PATH=/usr/bin:/bin:$(dirname "$(command -v python3)") "$KIT/install.sh" "$T/proj" >/dev/null; }
inst; inst  # re-run must be safe
P="$T/proj"
python3 -I -c "import json,sys; h=json.load(open(sys.argv[1]))['hooks']; assert len(h['UserPromptSubmit'])==1 and len(h['PreToolUse'])==1 and 'Bash' in h['PreToolUse'][0]['matcher']" "$P/.claude/settings.local.json" && pass "install is idempotent"
[ "$(readlink "$P/.claude/CLAUDE.md")" = "$KIT/claude/team.md" ] && grep -q "Submissions due\|submissions due" "$P/.claude/CLAUDE.md" && pass "team rules + event knowledge linked as .claude/CLAUDE.md"
[ -L "$P/.claude/commands/ship.md" ] && [ -L "$P/.claude/commands/brief.md" ] && [ ! -e "$P/.claude/skills/*" ] && pass "commands symlinked, no stray skill link"
[ ! -e "$P/CONTRACT.md" ] && [ ! -e "$P/CLAUDE.md" ] && pass "nothing from the kit lands in the repo"
[ "$(grep -c '(team-kit)' "$P/CLAUDE.local.md")" = 1 ] && grep -q "You work for \*\*bob\*\*" "$P/CLAUDE.local.md" && pass "CLAUDE.local.md names the human, once after re-install"
echo "my own note" >> "$P/CLAUDE.local.md"; inst; grep -qx "my own note" "$P/CLAUDE.local.md" && [ "$(grep -c '(team-kit)' "$P/CLAUDE.local.md")" = 1 ] && pass "re-install keeps personal notes"
(cd "$P" && git add -A && [ -z "$(git diff --cached --name-only)" ]) && pass "git sees nothing from the kit"
(cd "$P" && git reset -q)

# posting
AGENTCHAT_NAME=alice "$AC" merged "verifier: scores diffs" | grep -q "posted: \[alice\] MERGED: verifier: scores diffs" && pass "merged"
AGENTCHAT_NAME=alice "$AC" blocked bob "need /score schema" >/dev/null && pass "blocked"
AGENTCHAT_NAME=alice "$AC" touched bob "renamed score() arg" | grep -q "TOUCHED bob's area: renamed score() arg" && pass "touched"
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

# guard hook
g() { echo "$1" | "$AC" hook-guard; }
g '{"tool_name":"Write","tool_input":{"file_path":"/x/app.py","content":"KEY = \"sk-ant-api03-abcdefghijklmnop\""}}' | grep -q '"deny"' && pass "blocks a key written into code"
g '{"tool_name":"Edit","tool_input":{"file_path":"/x/cfg.ts","new_string":"const k = \"LLM|123456|abcdefghijkl\""}}' | grep -q '"deny"' && pass "blocks a Meta key in an edit"
g '{"tool_name":"MultiEdit","tool_input":{"file_path":"/x/a.py","edits":[{"old_string":"a","new_string":"AIzaSyA1234567890abcdefghijklmnopqrstuv"}]}}' | grep -q '"deny"' && pass "checks MultiEdit edits"
[ -z "$(g '{"tool_name":"Write","tool_input":{"file_path":"/x/.env","content":"SLACK_BOT_TOKEN=xoxb-1234567890-abcdef"}}')" ] && pass "allows keys in .env"
[ -z "$(g '{"tool_name":"Write","tool_input":{"file_path":"/x/app.py","content":"key = os.environ[\"MODEL_API_KEY\"]"}}')" ] && pass "allows reading keys from env"
g '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}' | grep -q '"deny"' && pass "blocks git push --force"
g '{"tool_name":"Bash","tool_input":{"command":"git push -f"}}' | grep -q '"deny"' && pass "blocks git push -f"
g '{"tool_name":"Bash","tool_input":{"command":"git push origin +main"}}' | grep -q '"deny"' && pass "blocks git push +ref"
[ -z "$(g '{"tool_name":"Bash","tool_input":{"command":"git pull --rebase origin main && ./check && git push origin HEAD:main"}}')" ] && pass "allows the /ship push"
[ -z "$(g '{"tool_name":"Bash","tool_input":{"command":"git push origin feature-fix"}}')" ] && pass "allows a branch named with f"
echo "all passed"
