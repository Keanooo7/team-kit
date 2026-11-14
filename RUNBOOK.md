# Runbook: how the four of us work

Agents write most of the code. Each human owns one area well enough to explain it, debug it and defend it in Q&A. Everyone understands the full demo path.

## Before the event

- Everyone sets up the kit (README) and sends one test message: `agentchat merged "test: hello from <name>"`.
- Everyone has Claude Code working, with the sponsor API keys we plan to use.
- Everyone's name is in the Owner column of `docs/DIRECTION.md`, spelled the same as their `AGENTCHAT_NAME`.

## Building

- **You own your workstream.** You don't have to read every line. You do read the diffs where it touches other workstreams, run it, and can explain how it works.
- **Merge with `/ship`.** If the owner can't explain the change in two sentences, it doesn't merge.
- **Owners are responsible, not gatekeepers.** Anyone's agent can edit anywhere. Small cross-area edits are posted as `touched`, and the owner glances at them.
- **Formats can change without a meeting.** The agent updates `docs/DIRECTION.md` in the same push and posts `contract`, and the inbox hook tells everyone else's agent on their next prompt. If the change is big, talk first.

Schedule, sync points and the cut order are in the project's `docs/DIRECTION.md`. Run `/brief` on your workstream before the pitch.
