---
description: Prep your human to explain their area to judges, then quiz them
---

My human has to explain our area of this project to judges in a 1–2 minute Q&A, without looking at code. Find the workstream they own in `docs/DIRECTION.md` (ask if it's unclear). Read the code, then give them:

1. **How it works:** trace one real demo input through the area, end to end, in about 5 lines with `file:line` references.
2. **Design choices:** the 2–3 that matter, and for each, the alternative we didn't pick and why.
3. **How we know it's correct:** the actual tests and checks, and what they would catch.
4. **What's fake:** anything stubbed, hardcoded, mocked or demo-only. Be blunt. Judges ask about this.
5. **Hardest part:** the thing that's more than "a few AI prompts away", in one or two sentences.
6. **Likely judge questions** with one-line answers: design choices, how we verified it, how we'd extend it, and how much the humans drove versus the agents.

Then quiz them: ask 3 of those questions one at a time, without showing the answers. After each answer, say what was right and correct what wasn't. If they can't answer something, that's a gap to fix before judging. Say so.
