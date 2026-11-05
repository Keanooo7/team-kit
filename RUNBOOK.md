# Runbook: how the four of us work

Agents write most of the code. Each human owns one area well enough to explain it, debug it and defend it in Q&A. Everyone understands the full demo path.

## Before the event

- Everyone sets up the kit (README) and sends one test message: `agentchat merged "test: hello from <name>"`.
- Everyone has Claude Code working, with the sponsor API keys we plan to use.

## Hour 0: 10:45–11:30, humans only

- One person creates the **public** repo and invites everyone, and everyone clones it and runs `~/dev/team-kit/install.sh <repo>` (1 minute).
- Write `CONTRACT.md` together: the pitch, the demo steps, owners and interfaces. Keep it short.
- **Test:** each of us can explain every area and every arrow between them. If someone can't, the contract isn't done.
- Stub every interface with fake data before writing real logic, so all four areas can build in parallel.
- Name one person as demo owner. They own the demo script, sample inputs and pitch, and they call the feature freeze.

## Building

- **You own your area.** You don't have to read every line. You do read the diffs where it touches other areas, run it, and can explain how it works.
- **Merge with `/ship`.** If the owner can't explain the change in two sentences, it doesn't merge.
- **Owners are responsible, not gatekeepers.** Anyone's agent can edit anywhere. Small cross-area edits are posted as `touched`, and the owner glances at them. No relaying through each other just to get things in sync: that's what sank us at Argon 4.
- **Interfaces can change without a meeting.** The agent updates `CONTRACT.md` in the same push and posts `contract`, and the inbox hook tells everyone else's agent on their next prompt. If the change is big (it changes the demo or someone's whole area), talk first.
- **Every hour, on the hour: a 5-minute sync.** Each person demos their piece live, from `main`. A demo, not a description. That's how we all keep up.

## Endgame

| Time | |
|---|---|
| 3:30 | Full demo path runs end to end on `main`, even if it's ugly |
| 4:00 | **Feature freeze.** After this, only fixes to the demo path |
| 4:15 | Everyone runs `/brief` on their area and gets quizzed |
| 4:30 | Two full rehearsals, timed at 3 minutes, with someone asking judge questions |
| 4:50 | Submit. Public repo, README says what was built today |

## In Q&A

Judges ask about design choices, how we verified it, how we'd extend it, and how much we drove the agents. The owner of the area in question answers.
