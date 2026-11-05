# Contract

The humans write this together in hour 0. Agents read it and code to it. Any change to an interface updates this file in the same push, then runs `agentchat contract "<what changed>"`. Keep it short: every agent reads it.

## What we're building

<Three sentences: what it does, how it differs from what people use today, who would use it tomorrow.>

## The demo (3 minutes)

<The exact steps on stage, with real inputs. Build only what this needs.>

1.
2.
3.

## Owners

An owner is responsible for an area: they can explain it, they review edits to it, and they answer judges' questions about it. Anyone can edit anywhere. Small edits in someone else's area get an `agentchat touched <owner> "..."`.

| Path | Owner | What it does |
|---|---|---|
| `src/<area>/` | <name> | |
| `src/<area>/` | <name> | |
| `src/<area>/` | <name> | |
| `demo/` | <name> | Demo script, sample inputs, pitch |

Use the same names as everyone's `AGENTCHAT_NAME`.

## Interfaces

One section per arrow between areas: who calls whom, the exact shape, and a real sample. Stub every interface with fake data first, so all four areas can build in parallel from minute one.

### <area A> → <area B>

- **Call:** <function signature, endpoint, file or queue>
- **Input:**
- **Output:**
- **Sample:**

```json
```

## Check

`./check` must pass on `main` at all times. It runs:

-

## Git

Everyone pushes to `main` with `/ship`: check, explain-back, human OK, rebase, check, push. No long-lived branches.

## Out of scope

<What we're deliberately not building today.>
