---
name: meta-model-api
description: Meta Model API (Muse Wonder, Muse Spark, Muse Image, Muse Voice Transcribe, SAM 3.1) and Muse Code. Use when writing code that calls Muse models, pointing an OpenAI/Anthropic SDK or Claude Code at Meta's endpoint, or deciding how to qualify for the "Best use of Meta Model API" prize.
---

# Meta Model API

Source: the sponsor docs handed out for AIE (Nov 2026) and https://github.com/meta-models/meta-model-cookbook. Full API reference: https://dev.meta.ai/

## Basics

- Base URL `https://api.meta.ai/v1`. Auth: `Authorization: Bearer $MODEL_API_KEY` (format `LLM|{id}|{secret}`). Keys come from https://dev.meta.ai/. Keep the key in `.env`, never in code: this repo is public.
- **Drop-in compatible** with the OpenAI SDK, the Anthropic SDK and OpenAI-compatible agent CLIs. Change the base URL and the key; keep the rest of the code.
- Three request formats, same models and price: **Responses API** (`/v1/responses`: agentic, server-side state, reasoning replay), **Chat Completions** (OpenAI-style), and **Messages** (Anthropic-style).

## Models

| Model | Use |
|---|---|
| `muse-wonder-1.0` | Flagship, in preview. Long-horizon multi-file coding, sub-agents, parallel tool calls, 1M context. Set `reasoning: {effort: "high"}` for hard work. |
| `muse-spark-1.3` (also 1.2, 1.1) | Cheaper, same request shape. **Free during the preview.** `-contributor` variants are discounted. Check what contributor mode does with your data before sending anything private. |
| `muse-image-1.0` | Image generation and editing (`/v1/images/generations`, `/v1/images/edits`) |
| `muse-voice-transcribe-1.0` | Speech to text: realtime `wss://api.meta.ai/v1/asr/realtime`, files `POST /v1/asr/transcribe` |
| `sam-3.1` | Segmentation masks and boxes for images and video, from a text prompt |

Muse Wonder and Muse Spark take the same requests: swap the model string to switch.

## Code

```python
# OpenAI SDK
import os
from openai import OpenAI
client = OpenAI(base_url="https://api.meta.ai/v1", api_key=os.environ["MODEL_API_KEY"])
r = client.chat.completions.create(model="muse-spark-1.3", messages=[{"role": "user", "content": "hi"}])
print(r.choices[0].message.content)
```

```bash
# Responses API
curl -X POST https://api.meta.ai/v1/responses \
  -H "Authorization: Bearer $MODEL_API_KEY" -H "Content-Type: application/json" \
  -d '{"model":"muse-wonder-1.0","reasoning":{"effort":"high"},"input":"..."}'
```

For the Anthropic SDK, set its base URL to the Model API and pass the key. Check the "SDKs and libraries" page on dev.meta.ai for the exact Messages path before relying on it.

The API also supports parallel and streamed tool calls, tool search, search grounding with citations, structured output (schema-guaranteed JSON), prompt caching, token counting and computer use.

## Muse Code (Meta's terminal coding agent)

`curl -fsSL https://dev.meta.ai/install.sh | sh`, then run `muse`. It plans, edits and runs commands, with approvals and an OS sandbox on by default. The cookbook's `04_muse_code/` recipes cover: an append-only audit log with crash-safe resume, deterministic replay as a CI gate, staged approvals, provable sandboxing, guardrails the agent can't rewrite, subagent fan-out across worktrees, and a goal judge that won't close the turn until the acceptance checks pass.

## Prize strategy

- Meta's judges know the cookbook. **Rebuilding a recipe isn't creative.** The cookbook already has a PR-review and AI-slop bot (`03_use_cases/11`), a replay-based merge gate, a goal judge, and Ghidra on stripped binaries (`04_muse_code/11`).
- Recipes as building blocks inside a bigger system read as "best use". So does Muse being the model doing the core work, not a side call.
