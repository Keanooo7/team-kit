# Contract

The humans write this together in hour 0, and only the humans change it, together. Agents read it and code to it. After a change, run `agentchat contract "<what changed>"`.

## What we're building

<Three sentences: what it does, how it differs from what people use today, who would use it tomorrow.>

## The demo (3 minutes)

<The exact steps on stage, with real inputs. Build only what this needs.>

1.
2.
3.

## Owners

Each person owns a directory. Agents asking to edit outside their human's area is on purpose: it means two humans need to talk.

| Path | Owner | What it does |
|---|---|---|
| `src/<area>/` | <name> | |
| `src/<area>/` | <name> | |
| `src/<area>/` | <name> | |
| `demo/` | <name> | Demo script, sample inputs, pitch |

Names must match each person's `AGENTCHAT_NAME`.

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
