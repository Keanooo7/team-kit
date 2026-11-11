---
name: archil
description: Archil sandboxes, forks, pause/resume, disks, checkpoints and branches: measured numbers, doc facts and gotchas. Use before writing any code that calls the archil SDK or the disk CLI.
---

# Archil: what we measured and what bites

Python SDK `archil` 0.21.0, Node `disk` 1.12.0. Docs: https://docs.archil.com/llms.txt

## Measured on Nov 9 (laptop → aws-us-east-1, 1 vCPU, 1 GiB, python:3.13)

| Step | Time |
|---|---|
| Create sandbox | 3.82 s |
| First exec | 2.35 s |
| Warm exec | 0.47 s |
| Fork of a running sandbox | 3.79 s |
| Two forks in parallel | 3.79 s wall |
| First exec in a fork | 0.53–0.60 s |
| Pause / resume | 0.73 s / 0.39 s |

- Forks keep running processes and memory: same PIDs, a counter kept counting.
- Writes in one fork don't show up in another or in the parent.
- From Archil's RL guide: a fork of a **stopped** sandbox starts in about 1 s, but it cold-boots (no memory).

## From the docs

- `fork(checkpoint=...)`: only the current session's checkpoint and the one before it are accepted.
- Running, paused or stopped sandboxes can be forked; forks of forks are allowed; a paused source isn't touched.
- Sandboxes with extra disk mounts must be stopped before forking; only the root disk is branched.
- `expose_port(port)` returns a public hostname. `create_port_token(port)` gives private access via the `X-Archil-Token` header.
- Firewall: `network.egress = {default: "deny", allow: [...]}`. `drain_on_pause` lets in-flight HTTPS finish before a snapshot.
  Custom policies need a paid plan; Free uses a managed allowlist that includes model provider APIs.
- Plans: Free = 5 concurrent sandboxes, sessions ≤ 30 min, 1 vCPU-hour + 2 GiB-hours a month. Developer = $10 minimum,
  20 concurrent, $0.055/vCPU-hour + $0.020/GiB-hour. Pausing stops compute charges.

## Gotchas

- API keys are region-scoped. The Nov 9 test key only worked in `aws-us-east-1` (401 elsewhere).
- The macOS mount needs macOS 26. Use the SDK or `npx disk` instead.
- The `disk` CLI has no sandbox commands. Fork is SDK-only.
- Background processes started via `exec` die when it returns. Use `run()`.

## Still unknown (spike: `~/dev/archil-playground/spike_checkpoints.py`)

- T1: do paused sandboxes count toward the concurrency cap?
- T2: fork-of-paused-child timing.
- T3: is an exposed port reachable from a phone?
- T4: can a sandbox reach api.anthropic.com?

## Disks: checkpoints and branches (docs, Nov 10)

- Checkpoints are made with the `archil` CLI on a **mounted** disk (`archil checkpoints create <mount> <name>`), ~15 ms. Mounting needs Linux, so do it inside a sandbox, not on a Mac.
- A branch is made by naming any checkpoint, ~35 ms regardless of disk size. Branches can be mounted (`--branch`), several at once on separate VMs.
- Branches and checkpoints **cannot be deleted**. BYOB disks cannot use them.
