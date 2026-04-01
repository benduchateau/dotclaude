---
name: Telegram and Discord channel plugins
description: Channel plugin setup for Telegram (@duchatsclaude_bot) and Discord. Both configured, outbound works. Inbound Telegram notifications flaky (session restart usually fixes).
type: reference
---

## Channel Plugins

Both Telegram and Discord channel plugins are installed and configured. Config lives at `~/.claude/channels/{telegram,discord}/`.

### Telegram
- **Bot:** @duchatsclaude_bot
- **Token:** stored in `~/.claude/channels/telegram/.env`
- **Allowed sender:** `7706509046` (Ben's Telegram ID)
- **DM policy:** `pairing`
- **Status (as of 2026-03-31):** Outbound works (reply tool sends messages). Inbound notifications intermittently fail to surface in the conversation.

### Discord
- **Bot application ID:** `1484504030037409802`
- **Token:** stored in `~/.claude/channels/discord/.env`
- **Allowed sender:** `347658546143428620`
- **DM policy:** `pairing`
- **Status (as of 2026-03-31):** Configured and paired. Discord pairing approved.

### Key Knowledge
- **`--channels` flag** is required when launching Claude Code to boot channel MCP servers. Without it, tokens sit in `.env` doing nothing.
- **Combined launch:** `claude --channels plugin:discord@claude-plugins-official,plugin:telegram@claude-plugins-official`
- **MCP notification vs tool call:** Outbound (reply tool) uses request/response and is reliable. Inbound uses MCP notifications (server-push), which can silently fail if the pipe was established before the bot's polling loop was ready. A session restart usually fixes this.
- **Turn-gated delivery:** Inbound notifications only surface between assistant turns, not during a response. Send a message, then press Enter in Claude Code.
- **Discord requires:** Message Content Intent enabled in Developer Portal, bot invited to a shared server.
- **Telegram token colon issue:** The colon in BotFather tokens (`123:AAG...`) can break the `/telegram:configure` skill's argument parser. Save the token directly to `.env` if the skill fails.
