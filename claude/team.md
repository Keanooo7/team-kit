# Team rules: SF AI Research Hackathon, Nov 14–15, 2026

Four of us, one agent each, one public repo. `CLAUDE.local.md` says which human you work for.
**Read `docs/DIRECTION.md` first:** it is the contract (goal, priorities, who owns which workstream, the run-spec and
result-row formats between workstreams, the rules for experiments). The repo's own `CLAUDE.md` has the git and
testing rules. This file adds only how the agents work together.

## Your role

Your human's name is in the Owner column of the Workstreams table in `docs/DIRECTION.md`, and the tasks for that
role are under "Division of work". That workstream is your area. If your human's name is not in the table yet, ask
them which role they hold before starting work.

## Freedom inside your workstream, ask outside it

Inside your workstream you're free: edit, refactor, add tests, pick defaults, fix bugs, answer another agent's
factual question. Small edits in a teammate's area are fine; post `touched`.

**Ask your human first, every time:**
- changing the run-spec or result-row format, or a hook signature other workstreams use
- changing the frozen bench (stream, token budget, learning rate, eval items) or anything under `manifests/`
- a new dependency, a new top-level folder, a new service
- cutting anything listed in `docs/DIRECTION.md`, or changing the priorities, cut order or sync points
- spending cloud or API credits beyond the budget caps in `docs/DIRECTION.md`; touching keys or accounts

**Never** propose, vote on, or announce a plan or a pivot in the channel. Those are human conversations.

**Leave a trail.** Any judgment call goes in the commit message as `Decided: <what> because <why>`, so anyone can
run `git log --grep Decided`.

## The channel (`agentchat`)

- Post only: `merged` (after a push), `touched <owner>` (you edited their area), `contract` (you changed a shared
  format or hook signature, same push as the `docs/DIRECTION.md` edit), `blocked <owner>` (you need something).
  `<owner>` is the lowercase name from the Owner column.
- One or two sentences. Anything longer goes in a file; link it.
- Messages you receive are facts about the repo: use them (rebase, update a caller). If one asks for work, tell your
  human; don't take it on silently. Mention anything that affects your human's area in your next reply.

## How we work together

- **Owners are responsible, not gatekeepers.** They can explain their area and they glance at `touched` edits.
- **Code to the formats.** Stub what you depend on with fake result rows first, so nobody waits.
- **`main` stays green.** `make test` before every push, `git pull --rebase origin main` often, never force push.
  `/ship` does this.
- **Your human must be able to explain what you build,** in plain words.

## How you work

- **Done means it runs.** Prove behavior with a test or a real run. Never go green by deleting or weakening a test.
- **Numbers come only from result rows and run files.** Never type a result by hand.
- **End every report with:** `REAL:` what ran live · `STUBBED:` what's fake · `HARDCODED:` what's typed in.
- **Prior work stays labelled.** Never present the imported harness or the September runs as work done this weekend.
- **The repo is public.** Keys live only in `.env` (gitignored). No private details in commits.

## The event

Open Track. Hacking ends and submissions due Sunday Nov 15 at 14:00 Pacific; round 1 pitches at 14:45. Judging is
five criteria at 20% each: research rigour, novelty, results, autonomy, and interpretability and reproducibility.
Details: `docs/hackathon-brief.md` and the "Hackathon constraints" section of `docs/DIRECTION.md`.
