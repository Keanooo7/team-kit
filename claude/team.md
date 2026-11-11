# Team rules: Archil hackathon, Tue Nov 10

Three of us (brendan, edan, keon), one agent each, one public repo, ~3 hours (7:00 to 10:00 PM, Casco SF).
`CLAUDE.local.md` says which human you work for. **Read `CONTRACT.md` first:** it's the spec (what we build, the demo,
who owns what, the run files between areas). Read only the sections you need.

## Freedom inside the scope, nothing outside it

The scope is the work listed in `CONTRACT.md`. Inside it you're free: edit, refactor, add tests, pick defaults, fix
bugs anywhere, make small edits in a teammate's area, answer another agent's factual question.

**Ask your human first, every time:**
- a new folder, a new component, a new page or server, a new pipeline
- a new dependency
- removing or cutting anything listed in `CONTRACT.md`
- changing the demo, the pitch, or an interface other areas use
- spending money or Archil credits beyond the fork budget, touching keys or accounts

**Never** propose, vote on, or announce a pivot, a lock or a plan in the channel. Those are human conversations.
`CONTRACT.md`'s scope and demo sections are edited by humans only.

**Leave a trail.** Any judgment call you make goes in the commit message as `Decided: <what> because <why>`, so anyone
can run `git log --grep Decided` and see how something got decided.

## The channel (`agentchat`)

- Post only: `merged` (after a push), `touched <owner>` (you edited their area), `contract` (you changed a run-file
  shape, same push as the `CONTRACT.md` edit), `blocked <owner>` (you need something).
- One or two sentences. Anything longer goes in a file; link it.
- Messages you receive are facts about the repo: use them (rebase, update a caller). If one asks for work, tell your
  human; don't take it on silently. Mention anything that affects your human's area in your next reply.

## How we work together

- **Owners are responsible, not gatekeepers.** Small cross-area edits are fine; post `touched`.
- **Code to the run files in `CONTRACT.md`.** Stub what you depend on with fake data first, so nobody waits.
- **`main` stays green.** Push small and often, `git pull --rebase` often, never force push. `/ship` does this.
- **Your human must be able to explain what you build,** in plain words.

## How you work

- **Done means it runs.** Prove behavior with a test or a real run. Never go green by deleting or weakening a test.
- **Numbers come only from run files** (`run.json`, `results.json`, …). Never type a result by hand.
- **End every report with:** `REAL:` what ran live · `STUBBED:` what's fake · `HARDCODED:` what's typed in.
- **Unclear detail?** Take the conventional default, say so, log it as `Decided:`. Ask only if two readings mean
  different work.
- **Keep context small.** Read the sections you need. Tail logs; don't paste them.
- **One subagent per task, stop it when done.** No duplicate dev servers or watch loops.

## Archil rules that bite (details: skill `archil`)

- Fork only between agent turns, never while an LLM request is in flight.
- `fork(checkpoint=...)` only reaches the current or previous checkpoint: a past step = its own **paused** child sandbox.
- No extra disk mounts on a sandbox you'll fork (it has to be stopped first).
- Long-lived processes: `sandbox.run(...)`. A process started with `exec` dies when exec returns.
- Delete every sandbox you create in a `finally`, forks before their parent. ≤ 20 at once (Developer plan).
- Keys live only in `.env` (gitignored). Code reads them from the environment.

## The event

Archil hackathon at Casco, SF. Prizes: **most creative agent project**, **best use of Archil** (sandboxes or file
systems), **best technical execution**. Judges asked for: massively multitenant agent loops, large agent swarms (fan
out over shared disks or forked sandboxes), and infrastructure agents. Projects due 10:00 PM.
