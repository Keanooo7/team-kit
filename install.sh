#!/usr/bin/env bash
# Wire the team kit into a project repo. Everything is linked from the kit and excluded from the
# project's git, so a `git pull` of the kit updates every teammate and nothing pre-written lands in
# the public repo. The one exception is CONTRACT.md, a blank template the team fills in at the event.
# Safe to re-run.
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
PROJ="${1:?usage: install.sh /path/to/project}"
PROJ="$(cd "$PROJ" && pwd)"

git -C "$PROJ" rev-parse --git-dir >/dev/null 2>&1 || { echo "install: $PROJ is not a git repo"; exit 1; }
ENVF="${AGENTCHAT_ENV_FILE:-$KIT/.env}"
[ -f "$ENVF" ] || { echo "install: create $ENVF first (cp .env.example .env)"; exit 1; }
grep -q '^AGENTCHAT_NAME=..*' "$ENVF" || { echo "install: set AGENTCHAT_NAME in $ENVF"; exit 1; }

chmod +x "$KIT/bin/agentchat"
EXCLUDED=()

# 1. agentchat on PATH so agents can call it by name
if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$KIT/bin/agentchat" "$HOME/.local/bin/agentchat"
  echo "linked agentchat -> ~/.local/bin/agentchat"
else
  echo "NOTE: put $KIT/bin on your PATH so agents can run 'agentchat'"
fi

mkdir -p "$PROJ/.claude/commands" "$PROJ/.claude/skills"

# 2. team rules + event knowledge: .claude/CLAUDE.md is a symlink to the kit's team.md.
#    (One file on purpose: @imports that resolve outside the project are skipped silently.)
rm -f "$PROJ/.claude/CLAUDE.md" "$PROJ/.claude/team-knowledge"
ln -sfn "$KIT/claude/team.md" "$PROJ/.claude/CLAUDE.md"
EXCLUDED+=(.claude/CLAUDE.md)

# 3. slash commands and skills, symlinked
for f in "$KIT"/commands/*.md; do
  ln -sfn "$f" "$PROJ/.claude/commands/$(basename "$f")"
  EXCLUDED+=(".claude/commands/$(basename "$f")")
done
for d in "$KIT"/skills/*/; do
  name="$(basename "$d")"
  ln -sfn "${d%/}" "$PROJ/.claude/skills/$name"
  EXCLUDED+=(".claude/skills/$name")
done

# 4. hooks in .claude/settings.local.json, merged with whatever is there
python3 -I - "$PROJ/.claude/settings.local.json" "$KIT/bin/agentchat" <<'PY'
import json, sys
from pathlib import Path
path, bin_ = Path(sys.argv[1]), sys.argv[2]
s = json.loads(path.read_text()) if path.exists() else {}
hooks = s.setdefault("hooks", {})
for event in list(hooks):  # drop every earlier agentchat entry, then add the current ones
    hooks[event] = [e for e in hooks[event] if "agentchat" not in json.dumps(e)]
    if not hooks[event]:
        del hooks[event]
hooks.setdefault("UserPromptSubmit", []).append(
    {"hooks": [{"type": "command", "command": f"'{bin_}' hook-inbox", "timeout": 10}]})
hooks.setdefault("PreToolUse", []).append(
    {"matcher": "Edit|Write|MultiEdit|NotebookEdit|Bash",
     "hooks": [{"type": "command", "command": f"'{bin_}' hook-guard", "timeout": 5}]})
path.write_text(json.dumps(s, indent=2) + "\n")
print(f"hooks -> {path}")
PY
EXCLUDED+=(.claude/settings.local.json CLAUDE.local.md)

# 5. keep all of it out of git (common dir, so worktrees share one exclude file)
GITCOMMON="$(cd "$PROJ" && cd "$(git rev-parse --git-common-dir)" && pwd)"
mkdir -p "$GITCOMMON/info"
EXCL="$GITCOMMON/info/exclude"
for p in "${EXCLUDED[@]}"; do
  grep -qxF "$p" "$EXCL" 2>/dev/null || echo "$p" >> "$EXCL"
done
echo "excluded ${#EXCLUDED[@]} kit paths from git"

# 6. the one shared, committed file: a blank contract, only if the repo has none yet
if [ -e "$PROJ/CONTRACT.md" ]; then
  echo "kept existing CONTRACT.md"
else
  cp "$KIT/template/CONTRACT.md" "$PROJ/CONTRACT.md"
  echo "added CONTRACT.md: fill it in together, then commit it"
fi

echo "done. Restart Claude Code in $PROJ so it picks up the rules, skills and hooks."
