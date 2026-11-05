# team-kit

Setup for four people each running Claude Code on one shared repo.

- **`agentchat`**: agents post status to one Slack channel. Only three kinds of message: merged, blocked, contract change.
- **Inbox hook**: every time you prompt your agent, it sees what teammates posted since its last turn, labelled as information, not instructions.
- **Owners hook**: if your agent tries to edit another owner's area (from the table in `CONTRACT.md`), or `CONTRACT.md` itself, it has to ask you first.
- **`/ship`**: check, explain-back, your OK, push, announce.
- **`/brief`**: prep you to explain your area to judges, then quiz you.
- **`template/`**: `CONTRACT.md` and team `CLAUDE.md`. **`RUNBOOK.md`**: how the humans work.

This is our own dev tooling. It's never part of the demo, and its files stay out of the project's git (except the two templates, which the team fills in at the event).

## One-time setup (one person)

1. Go to https://api.slack.com/apps, then **Create New App → From a manifest**. Pick the workspace and paste `slack-manifest.yaml`.
2. **Install to Workspace**, then copy the **Bot User OAuth Token** (`xoxb-…`).
3. Make a channel, e.g. `#agents`, and run `/invite @agentchat` in it. Copy the channel ID (channel name → bottom of the About tab, starts with `C`).
4. DM the token and channel ID to the team. Never put them in a repo.

## Each person

```bash
git clone <team-kit repo> ~/dev/team-kit
cd ~/dev/team-kit
cp .env.example .env              # fill in the token, channel ID, and your name
./install.sh ~/dev/<project>      # hooks + commands; adds CONTRACT.md/CLAUDE.md if missing
agentchat merged "test: hello from <name>"
```

Restart Claude Code in the project. Your next prompt shows the other people's test messages.

**Optional, when you're away from the keyboard:** ask Claude to "run `agentchat watch` with the Monitor tool". The session then wakes on new messages instead of waiting for your next prompt.

## Notes

- The hooks never block you. If Slack is down or rate-limited, the inbox just stays empty that turn.
- The owners hook only covers Claude's Edit and Write tools. A shell command can still write anywhere. It's a speed bump, not a wall.
- Your own agent's posts are filtered out of your inbox. Humans posting in the channel show up too, labelled `(human)`.
- `test/test.sh` runs the whole kit against a fake Slack. No token needed.
