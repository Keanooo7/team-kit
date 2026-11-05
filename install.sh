#!/usr/bin/env bash
# Install the team kit into a project repo: hooks, slash commands, and (first time only) the
# CONTRACT.md and CLAUDE.md templates. Safe to re-run.
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
PROJ="${1:?usage: install.sh /path/to/project}"
PROJ="$(cd "$PROJ" && pwd)"

[ -d "$PROJ/.git" ] || { echo "install: $PROJ is not a git repo"; exit 1; }
ENVF="${AGENTCHAT_ENV_FILE:-$KIT/.env}"
[ -f "$ENVF" ] || { echo "install: create $ENVF first (cp .env.example .env)"; exit 1; }
grep -q '^AGENTCHAT_NAME=..*' "$ENVF" || { echo "install: set AGENTCHAT_NAME in $ENVF"; exit 1; }

chmod +x "$KIT/bin/agentchat"

# 1. agentchat on PATH so agents can call it by name
if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$KIT/bin/agentchat" "$HOME/.local/bin/agentchat"
  echo "linked agentchat -> ~/.local/bin/agentchat"
else
  echo "NOTE: put $KIT/bin on your PATH so agents can run 'agentchat'"
fi

# 2. slash commands (personal, not committed)
mkdir -p "$PROJ/.claude/commands"
cp "$KIT/commands/"*.md "$PROJ/.claude/commands/"

# 3. hooks in .claude/settings.local.json (personal, not committed), merged with what's there
python3 -I - "$PROJ/.claude/settings.local.json" "$KIT/bin/agentchat" <<'PY'
import json, sys
from pathlib import Path
path, bin_ = Path(sys.argv[1]), sys.argv[2]
s = json.loads(path.read_text()) if path.exists() else {}
hooks = s.setdefault("hooks", {})
def put(event, entry):
    keep = [e for e in hooks.get(event, []) if "agentchat" not in json.dumps(e)]
    hooks[event] = keep + [entry]
put("UserPromptSubmit", {"hooks": [{"type": "command", "command": f"'{bin_}' hook-inbox", "timeout": 10}]})
put("PreToolUse", {"matcher": "Edit|Write|MultiEdit|NotebookEdit",
                   "hooks": [{"type": "command", "command": f"'{bin_}' hook-owners", "timeout": 5}]})
path.write_text(json.dumps(s, indent=2) + "\n")
print(f"hooks -> {path}")
PY

# 4. keep personal files out of git
EXCL="$PROJ/.git/info/exclude"
for p in .claude/settings.local.json .claude/commands/ship.md .claude/commands/brief.md; do
  grep -qxF "$p" "$EXCL" 2>/dev/null || echo "$p" >> "$EXCL"
done

# 5. shared templates, only if the repo doesn't have them yet (the first teammate commits them)
for f in CONTRACT.md CLAUDE.md; do
  if [ -e "$PROJ/$f" ]; then
    echo "kept existing $f"
  else
    cp "$KIT/template/$f" "$PROJ/$f"
    echo "added $f (commit it so the team shares it)"
  fi
done

echo "done. Restart Claude Code in $PROJ so it picks up the hooks."
