---
name: gemini-argon
description: Gemini 4 Argon and Google's companion models and managed agents (Interactions API, thinking_level, background runs, Antigravity sandbox agent, Flash subagents, Deep Research). Use when writing code that calls Gemini at the AIE hackathon.
---

# Gemini 4 Argon

Source: Google's "1-day hackathon builder guide" for AIE (Nov 2026). For full, current API details, also install Google's official skill: `npx skills add google-gemini/gemini-skills --skill gemini-api-dev`. Docs: https://ai.google.dev/gemini-api/docs. Accounts are handed out at kickoff, and Google mentors are onsite.

## Rules

- Use the **Interactions API** with `google-genai` (Python) or `@google/genai` **≥ 2.3.0**. Server-side state goes through `previous_interaction_id`.
- Set `generation_config.thinking_level` to `"low"` (routing, extraction), `"medium"` (the default) or `"high"` (multi-file debugging, design, security).
- **Don't send** `thinking_budget`, `temperature`, `top_p`, `top_k` or `cached_content`. They're deprecated or ignored. Caching is implicit and gives 95% off cached input.
- Output is capped at 64K by default. For more, set `background=True` and a higher `max_output_tokens`, then poll.
- For "high" thinking, set HTTP timeouts to 15–20 minutes, or run in the background.
- Price through Nov 30: $2 per 1M tokens in, $10 per 1M out.

```python
from google import genai
client = genai.Client()
it = client.interactions.create(model="gemini-4-argon", input="...",
                                generation_config={"thinking_level": "medium"})
print(it.output_text)

# long output: background + poll
import time
it = client.interactions.create(model="gemini-4-argon", input="...", background=True,
                                generation_config={"max_output_tokens": 262144, "thinking_level": "high"})
while it.status in ("in_progress", "queued"):
    time.sleep(5); it = client.interactions.get(id=it.id)
```

## Managed agent: a hosted sandbox in one call

```python
it = client.interactions.create(
    agent="antigravity-preview-09-2026",
    agent_config={"type": "antigravity", "model": "gemini-4-argon"},
    input="...", environment="remote",
)
```

Argon plans, writes code, runs tests, searches the web and calls MCP tools inside a Google-hosted Linux sandbox. Register secrets with `client.credentials.create` and restrict outbound traffic with `environment={"type": "remote", "network": {"allowlist": [...]}}`, so secrets never enter the model's context.

## Companion models

| ID | Job |
|---|---|
| `gemini-3.8-flash` | Fast parallel subagents, codebase exploration, boilerplate tests |
| `gemini-3.5-flash-lite` | Lowest-latency routing, classification, guardrails |
| `deep-research-preview-04-2026` | Background multi-step web research with citations |
| `gemini-3.8-live` | Realtime voice and vision |
| `gemini-3.5-transcribe`, `-transcribe-live` | Speech to text with speaker labels |
| `gemini-3.8-flash-tts` | Text to speech |
| `gemini-nano-banana-2.1` | Images: UI assets, sprites, text rendering |
| `gemini-omni-1.1-flash`, `lyria-3.5` | Video with audio, music |
| `gemma-4-31b-it` | Open weights, local |

## Google's tests for a strong 1-day project (likely what their judges look for)

1. A specific problem for a real person you can name.
2. Work that needed the model: long-horizon coding, **autonomous verification loops**, multi-file synthesis, multi-agent orchestration.
3. People stay in control of actions that touch external systems, money or private data.
4. **Runs live, on real inputs, in under 3 minutes.**
