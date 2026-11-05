---
description: Check, explain the change, wait for your human's OK, push to main, tell the team
---

Ship the current work to `main`. Do these in order and stop at the first failure.

1. Run `./check` (or the command under "Check" in `CONTRACT.md`). If it fails, fix it or stop and report. Never ship red.
2. Look at what's going out: `git fetch origin`, then `git diff origin/main --stat` and the diff itself.
3. Write the explain-back for your human. Keep it short:
   - **What changed:** at most two sentences, in plain words.
   - **Interfaces:** which `CONTRACT.md` interfaces this uses. If it changes one, update `CONTRACT.md` in this push.
   - **Outside my area:** any files changed in another owner's area, and why.
   - **How I know it works:** the check output, plus what you ran and what you saw.
   - **Not sure about:** anything you guessed, stubbed or hardcoded.
4. **Stop and wait.** Continue only after your human replies OK. If they can't follow the explain-back, it doesn't ship yet: explain it until they can.
5. Commit, then `git pull --rebase origin main`, run `./check` again, then `git push origin HEAD:main`.
6. Post to the team:
   - `agentchat merged "<area>: <what changed, one sentence>"`
   - for each other owner whose area you touched: `agentchat touched <owner> "<what and why>"`
   - if an interface changed: `agentchat contract "<the change>"`
