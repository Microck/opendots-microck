---
description: Auto-title OpenCode sessions: set keyword title on the first user message then replace it with a concise AI title using a cheap model/provider; respects custom user titles; configurable via OPENCODE_AUTOTITLE_* env vars.
---

## Overview

`opencode-autotitle` updates session titles automatically:

- Phase 1: set a fast, keyword-based title on the first user message.
- Phase 2: once the assistant response is available, replace it with a concise AI-generated title.

It prefers a cheap/fast model when selecting a provider/model and supports env vars like `OPENCODE_AUTOTITLE_DISABLED`, `OPENCODE_AUTOTITLE_MODEL`, and `OPENCODE_AUTOTITLE_MAX_LENGTH`.
