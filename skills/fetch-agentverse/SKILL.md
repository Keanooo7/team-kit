---
name: fetch-agentverse
description: Fetch.ai uAgents, Agentverse, ASI:One and the Agent Chat Protocol, plus the AIE "Best use of Fetch.ai" prize requirements. Use when building or registering a Fetch.ai agent, making it reachable from ASI:One, or checking whether the project qualifies for the Fetch prize.
---

# Fetch.ai: uAgents, Agentverse and ASI:One

Source: the Fetch.ai Innovation Lab page for AIE (Nov 2026).

- **Agentverse:** the marketplace where agents are registered and found.
- **ASI:One:** Fetch's LLM chat. It routes a user's request to the best-matching Agentverse agent.
- **Agent Chat Protocol (ACP):** what makes an agent reachable from ASI:One.

## Prize requirements (all mandatory)

- [ ] At least one agent registered on **Agentverse**, categorized under **Innovation Lab**
- [ ] It implements the **Agent Chat Protocol**
- [ ] It's discoverable and usable directly through **ASI:One**
- [ ] It does meaningful tool execution or multi-agent orchestration, not a thin API wrapper or a chatbot
- [ ] **The whole primary workflow happens inside an ASI:One conversation. No custom frontend.**
- [ ] Public repo with run instructions. The README lists each agent's name and address and carries:
      `![tag:innovationlab](https://img.shields.io/badge/innovationlab-3D8BD3)`
      `![tag:hackathon](https://img.shields.io/badge/hackathon-5F43F1)`
- [ ] A **3–5 minute demo video**, submitted through the "AIE Code Summit ASI:One Submission Agent"

Bonus: multi-agent collaboration; the **Payment Protocol** with a credible way to make money; **ASI1 Interactive Cards** (forms, carousels, review screens); reliability and recovery from failed tool calls; real-time data; an agent that could keep running after the event.

Fetch judging: functionality 25%, use of Fetch tech 20%, creativity 20%, impact 20%, UX and presentation 15%. Judges: Sana Wajid (COO, Innovation Lab) and Rajashekar Vennavelli (Senior AI Engineer). Fetch mentors are onsite.

## Chat Protocol skeleton

`pip install uagents uagents-core`

```python
from datetime import datetime
from uuid import uuid4
from uagents import Agent, Context, Protocol
from uagents_core.contrib.protocols.chat import (
    ChatAcknowledgement, ChatMessage, EndSessionContent, StartSessionContent,
    TextContent, chat_protocol_spec,
)

agent = Agent()  # set name/seed/port/mailbox per the Agentverse guide
chat = Protocol(spec=chat_protocol_spec)

def reply(text):
    return ChatMessage(timestamp=datetime.utcnow(), msg_id=uuid4(),
                       content=[TextContent(type="text", text=text)])

@chat.on_message(ChatMessage)
async def on_msg(ctx: Context, sender: str, msg: ChatMessage):
    await ctx.send(sender, ChatAcknowledgement(timestamp=datetime.utcnow(),
                                               acknowledged_msg_id=msg.msg_id))
    for item in msg.content:
        if isinstance(item, TextContent):
            result = ...  # do the real work here
            await ctx.send(sender, reply(result))
        elif isinstance(item, (StartSessionContent, EndSessionContent)):
            pass

@chat.on_message(ChatAcknowledgement)
async def on_ack(ctx: Context, sender: str, msg: ChatAcknowledgement):
    pass

agent.include(chat, publish_manifest=True)
if __name__ == "__main__":
    agent.run()
```

## Guides (on the Innovation Lab docs)

- Create an agent with uAgents · Communication between two uAgents · **ASI:One-compatible uAgents** · ASI:One API · Connect a local agent to Agentverse · Integrate the ASI:One LLM
- Agentverse MCP server: `https://mcp.agentverse.ai/sse`, lite version `https://mcp-lite.agentverse.ai/mcp`
- Innovation Lab GitHub repo and past hackathon projects (look for examples)

## Cost/benefit

The ASI:One-only UX and the separate video cost real time in a 6h build. Go for it only if the core product naturally works as an agent you message and that acts. Decide in hour 0, not at 4pm.
