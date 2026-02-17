# Global OpenCode Rules

## Skill and MCP Discovery

Before EVERY task, I MUST check available skills and MCPs to determine if any are relevant:

1. **Check skills first** - Review available skills from the skill tool description that match the task domain
2. **Check MCPs second** - Review available MCPs that could assist with the task
3. **Apply matching skills/MCPs** - Load and use any relevant skills; prefer MCPs over manual approaches

Decision rule:
- If a relevant skill exists, load it with the `skill` tool and follow its workflow
- If a relevant MCP exists for the task domain, prefer its tools over generic/manual approaches
- If multiple skills apply, use all that are relevant
- If no relevant skill/MCP exists (or it would clearly add overhead without benefit), proceed normally

When I use skills and/or MCPs, explicitly name them in the response (names only, no long dumps).

## Diagram Defaults

- Mermaid diagrams: use the `pretty-mermaid` skill for rendering/theming (SVG or ASCII). Avoid the plain `mermaid-diagrams` skill unless the user explicitly asks for unstyled Mermaid or Mermaid syntax-only output.
- Isometric architecture diagrams: use the `fossflow-diagrams` skill and output FossFLOW/Isoflow compact JSON (per the skill's canonical LLM generation guide). Do not substitute Mermaid for these.

When you need information from the internet:
- Use BOTH tools in parallel and reconcile results:
  - Perplexity WebUI MCP (`perplexity-webui`): default to `pplx_ask` for fast lookups; use `pplx_deep_research` only when you explicitly need long-form synthesis.
  - Kagi Search MCP (`kagi-search`): use it as a second source of truth and to find alternate links/results.
- Do not use built-in web tools (`webfetch`, `websearch`, `codesearch`). They are disabled.
- Do not use `google_search`.
- Do not use Mintlify MCP (it is disabled in config).

## Hallucination Guardrails

- If I'm not sure about an external fact (APIs, versions, CLI flags, error meanings, pricing/limits, ToS changes, etc.), I MUST search before answering.
- Default verification workflow:
  - Run Perplexity (`pplx_ask`) and Kagi (`kagi-search`) in parallel.
  - Prefer primary sources (official docs, release notes, upstream repo) over blog posts.
  - If sources disagree: say so, show both, and ask a targeted question if needed.
- If I cannot verify quickly:
  - Say "not sure" explicitly.
  - Provide a best-effort hypothesis labeled as such.
  - Provide concrete steps to verify (commands to run, links to check).
- Never invent citations/links. If I cite something, it must come from the searches I ran.

## Workspace Verification

- For anything about THIS repo/workspace, verify by reading files / grepping / running commands.
- Do not guess file paths, config keys, or runtime behavior if it can be checked locally.

## Configurancy (Keeping Specs + Code In Sync)

When agents can change many files quickly, the scarce asset is the system's self-knowledge. Treat explicit contracts (specs, invariants, suites) as first-class.

- Contract-first changes: if a change affects observable behavior (public API, protocol, persistence format, CLI flags, error semantics), update the contract artifact first, then propagate code until enforcement is green.
- Spec hierarchy (prefer highest available ground truth):
  1. External oracle (system outside ours: RFCs, Postgres, reference corpus)
  2. Reference model (executable spec mirroring the oracle)
  3. Conformance suite (tests all implementations must pass)
  4. Prose rationale (why; trade-offs; what was tried/abandoned)
- Drift is a failure mode: if an oracle exists, add/keep differential tests against it; treat spec-oracle drift as CI failure, not folklore.
- Behavior-change discipline: if a "bug fix" requires changing the shared mental model, it's a behavior change; document it and add enforcement.
- Bidirectional review:
  - Doc -> Code: if a spec claims an invariant, point to enforcement (tests/types/runtime assertions).
  - Code -> Doc: if a test/type encodes a non-obvious invariant, ensure it's reflected in the contract layer.
- Require a structured configurancy delta for non-trivial behavior changes (PR body, RFC, or commit message):
  ```yaml
  config_delta:
    affordances:
      - add: "..."
      - modify: "..."
      - remove: "..."
    invariants:
      - add: "..."
      - strengthen: "..."
      - weaken: "..."
    constraints:
      - add: "..."
      - modify: "..."
      - remove: "..."
    rationale:
      - "..."
    enforcement:
      - conformance: "test_name"
      - types: "type/interface"
      - runtime: "metric/assert/log"
  ```
- 30-day test: keep a small set of system-behavior questions/scenarios; if an agent can't answer from the contract layer (without reading implementation), treat it as a configurancy gap.
- Suite design matters: choose enforcement that matches the failure mode (deterministic scenarios, property/fuzz, history-based checkers, model checking, differential testing).
- Runtime truth maintenance for critical invariants: where feasible, encode invariants as production metrics/assertions/alerts and tie critical ones to SLOs/error budgets.

## Browser Access / Debugging

- If debugging a Next.js app:
  - Prefer `next-devtools` for Next.js-specific diagnostics (routes, compile/runtime errors).
  - Use `next-devtools_browser_eval` when you need a real rendered browser check (hydration/client errors, navigation flows).
- For general web automation (any site/app) and multi-step UI flows, use `agent-browser-mcp`.

## Browser Automation

- Prefer `agent-browser-mcp` for browser automation.
- If you must use the CLI, use `agent-browser` via shell commands.

Core workflow:
1. `agent-browser open <url>`
2. `agent-browser snapshot -i --json`
3. Interact using refs: `agent-browser click @e1`, `agent-browser fill @e2 "text"`
4. Re-snapshot after navigation/DOM changes

## Raw GitHub Content

For raw GitHub files (raw.githubusercontent.com URLs), use `curl` directly instead of browser automation:
```bash
curl -s <raw-github-url>
```
This is more reliable for fetching raw file content.

## Commit Identity

- When creating git commits for this user, always use:
  - Name: `Microck`
  - Email: `contact@micr.dev`
- Apply this via per-command environment variables (for example, `GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL`, `GIT_COMMITTER_NAME`, `GIT_COMMITTER_EMAIL`) and do not modify git config.
