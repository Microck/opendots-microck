---
description: Rotate OpenAI Codex OAuth accounts on 429/rate-limit retries: maintain multicodex-accounts.json, advance activeIndex, syncs OpenCode auth.json, and update in-memory auth so subsequent openai/* calls use the next account.
---

## Overview

`multicodex` is an OpenCode plugin that detects rate-limit retries for `openai/*` models and switches to the next configured Codex OAuth account.

It keeps an account list in `multicodex-accounts.json`, updates the active index, syncs the active credentials to OpenCode's auth file, and updates in-memory auth so subsequent requests use the new account.
