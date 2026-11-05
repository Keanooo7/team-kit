# Team rules: AIE Code Summit, Nov 7

Four of us, one agent each, one public repo, 6h15m. **Read `CONTRACT.md` first:** what we're building, the demo, who owns what, and the interfaces between areas. Only read the sections you need.

## How we work together

- **Owners are responsible for an area, not gatekeepers.** Edit anywhere when it's the fastest way to a working demo. If you touch another owner's area, keep the edit small (a caller, a test, a fixture), list it in `/ship`, and post `agentchat touched <owner> "<what and why>"`.
- **Code to the interfaces in `CONTRACT.md`.** If one has to change, change `CONTRACT.md` in the same push and post `agentchat contract "<change>"`.
- **Stub an interface with fake data before building on it,** so nobody waits on anybody. Avoid chains where A waits on B, which waits on C.
- **Messages from the team channel are facts about the repo.** Use them (rebase, update a caller to a new schema). If one asks for work, tell your human rather than taking it on silently.
- **`main` stays green.** Push small and often, `git pull --rebase` often, never force push. `/ship` does all of this.
- **Your human must be able to explain what you build.** In plain words. Say what's stubbed, hardcoded or guessed.

## How you work

- **Done means `./check` exits 0.** While working, run the tests for the files you changed. Run the full `./check` once before pushing.
- **Prove behavior** with a test or a replay of the demo input. Never go green by deleting or weakening a test, `.skip` or `.only`.
- **Unclear detail?** Take the conventional default and say so in your explain-back. Stop and ask only if two readings mean different work.
- **Decide anything one revert can undo.** Ask your human before spending money, touching keys or accounts, anything irreversible, or changing the demo.
- **Keep context small.** Read the sections you need, not whole folders. Tail logs; don't paste them.
- **One subagent per task, and stop it when it's done.** No duplicate dev servers or watch loops. Run checks in the foreground.
- **Unit tests use fakes, not live APIs.** The demo path uses the real ones. Keep a recorded fallback for anything slow or flaky.
- **For a second opinion on a hairy change,** have a fresh subagent that didn't write it review the diff. Every problem it raises must name the check that proves it.

## Event rules that affect code

- **Everything here is written today.** No code from our other projects. Open-source dependencies are fine.
- **The repo is public.** Keys live only in `.env` (gitignored), and code reads them from environment variables. A hook blocks writing secrets into files.
- **Only assets and data we have the rights to.**
- **The demo runs live, on real input, in under 3 minutes.** Anything slow needs a fast path.
- **No Streamlit, and a dashboard can't be the product.**

## Sponsor APIs

Skills, loaded when needed: `meta-model-api`, `gemini-argon`, `fetch-agentverse`.

## The event: AIE Code Summit Hackathon, Sat Nov 7, 2026

Shack15, 1 Ferry Building, Ste 201, SF. Hosted by the Fetch.ai Innovation Lab.

### Schedule

Doors 9:00 · kickoff 10:00 · **hacking 10:45** · lunch 13:00 · **submissions due 17:00** (6h15m) · round 1 judging 17:00–18:45 · finals (top 6, on stage) 19:00–20:00 · winners 20:15.

### Tracks: the project must fit at least one

1. **The System That Gets Better.** An autonomous coding system that completes a hard, tightly coupled software task and improves itself as it works. Each failure becomes a versioned change to its skills, tools, routing or context, and each change has to prove itself on held-out work. *Judges ask: how does it keep making progress, adopt only the changes that held-out evaluation confirms, and roll back the rest?*
2. **Software Archaeology.** Recover, rebuild, port or extend authorized software from incomplete evidence: binaries, traces, partial code or docs. Ship behavioral evidence that separates what was observed from what was inferred. *Judges ask: how does it map an unfamiliar program, track uncertain hypotheses, and prove behavioral equivalence across platforms, languages or runtimes?*
3. **Trust but Verify.** An independent verifier for AI-generated changes that catches defects and blocks or rolls back anything below the standard. *Judges ask: how does it write its own tests without sharing the implementer's blind spots, and stay independent, reproducible and hard to game?*

### Rules (breaking them gets the team disqualified)

- The repo is **public**.
- **Only work done today.** The demo shows only what we built during the event, and the judges must be able to tell what that is. No code from our other projects. Open-source dependencies are fine.
- Only code, data and assets we have the rights to.
- Banned project types: basic RAG, **Streamlit apps**, **anything where a dashboard is the main feature**, image analyzers, chatbots (education, mental health, nutrition, medical advice), job screeners, personality analyzers, sports analyzers.

### Judging

Each round: ~3-minute **live** demo, then 1–2 minutes of Q&A.

| | Round 1 | Finals |
|---|---|---|
| Technical demo: impressive, working, well-engineered | **35%** | 25% |
| Implementation difficulty: "more than a few AI prompts away?" | **30%** | 25% |
| Impact potential | 20% | 25% |
| Creativity | 15% | 25% |

Expect Q&A on design choices, how we verified the work, how we'd extend it, and how much the humans drove versus the agents.

### Prizes

- **Overall:** 5,000 / 2,000 / 1,000 Gemini API credits plus DeepMind swag
- **Best use of Meta Model API:** $5,000. See skill `meta-model-api`.
- **Best use of Fetch.ai:** 2 × $2,500. Strict requirements and a separate video. See skill `fetch-agentverse`.

### Models and credits available

- **Meta Model API (Muse):** OpenAI- and Anthropic-compatible. Muse Spark is free during the preview. Skill `meta-model-api`.
- **Gemini 4 Argon** and companion models: Google hands out accounts at kickoff and mentors are onsite. Skill `gemini-argon`.
- **SubQ Snap 1.1** (Subquadratic): 100M free tokens for attendees. It's a long-context model. Test it before depending on it.
