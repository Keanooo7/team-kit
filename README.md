# team-kit

Our Claude Code setup for team hackathons: four people, one agent each, one shared public repo.

## What's in it

| | |
|---|---|
| `claude/team.md` | **The shared team file.** How we work together, how agents work, the event rules that affect code, plus the event itself (tracks, schedule, rubric, prizes). Every agent loads it on every turn, so keep it short. |
| `skills/` | Sponsor API references, loaded only when needed: `meta-model-api`, `gemini-argon`, `fetch-agentverse` |
| `commands/` | `/ship`: check, explain-back, your OK, push, announce. `/brief`: prep you for judges' Q&A on your area, then quiz you |
| `bin/agentchat` | Agents post status to Slack `#agents` (`merged`, `touched`, `contract`, `blocked`). Its hooks show each agent what teammates posted, block secrets from being written into files, and block force pushes |
| `template/CONTRACT.md` | The one file that gets committed: what we're building, the demo, owners, interfaces. Written together in hour 0 |
| `RUNBOOK.md` | How the humans work: hour 0, hourly syncs, freeze, rehearsal |

## How the instruction files layer

| Layer | Where | Who it's for | In the public repo? |
|---|---|---|---|
| Your personal global rules | `~/.claude/CLAUDE.md` | you | no |
| **Team rules + event** | `<project>/.claude/CLAUDE.md` → symlink to `claude/team.md` | all 4 agents | no (git-excluded) |
| **What we're building** | `<project>/CONTRACT.md` | all 4 agents | **yes**, written at the event |
| Your personal notes for this project (optional) | `<project>/CLAUDE.local.md` | you | no (git-excluded) |
| Sponsor API details | `<project>/.claude/skills/*` → symlinks | loaded on demand | no (git-excluded) |

Everything from the kit is **symlinked**, so after a `git pull` of team-kit, every project picks up the change on your next Claude Code session. No reinstall needed unless a new skill or command was added. Nothing pre-written lands in the project's git history. That matters because the rules disqualify presenting earlier work.

## One-time Slack setup (done)

The workspace, the `agentchat` app and `#agents` already exist. Edan DMs you the bot token and channel ID. For a new workspace: create an app at https://api.slack.com/apps → **From a manifest** → paste `slack-manifest.yaml` → install → copy the **Bot User OAuth Token** → `/invite @agentchat` in the channel.

## Each person, before Saturday

```bash
git clone https://github.com/EdanBarrios/team-kit ~/dev/team-kit
cd ~/dev/team-kit && cp .env.example .env    # token, channel ID, your name (lowercase)
bin/agentchat merged "test: hello from <name>"
```

## On the day

```bash
git clone <our public repo> && ~/dev/team-kit/install.sh <that folder>
```

Restart Claude Code in the project. That sets up the team file, skills, commands and hooks, and puts `agentchat` on your PATH.

**Optional:** to have an idle session wake on new messages, ask Claude to "run `agentchat watch` with the Monitor tool".

## Notes

- The hooks never block a prompt. If Slack is down, the inbox is just empty that turn.
- The secrets guard covers Claude's file edits. A key typed into a shell command still gets through. It's a seatbelt, not a vault.
- `test/test.sh` runs everything against a fake Slack. No token needed.
