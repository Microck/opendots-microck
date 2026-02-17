# Overview

shadcn/ui is a set of open, composable components distributed as code, plus a CLI and registry system. It is not a traditional component library.
It provides styled, copy-and-own components built on top of Base UI’s headless primitives.

## Official Entry Points (Canonical)
- Docs home: https://ui.shadcn.com/docs
- Base UI components list: use this skill’s `references/components.md`
- Full entry-point list: `references/links.md`

## Base UI vs Radix Docs (Critical)
- `https://ui.shadcn.com/docs/components/base` is **not** a valid index page (404).
- `https://ui.shadcn.com/docs/components/**` are **Radix** examples and must not be used for Base UI.
- This skill’s `references/components.md` is the Base UI source of truth.
- If you discover a component under `/docs/components/<name>`, convert it to Base UI by inserting `/base/` after `/components/` (e.g., `/components/alert-dialog` → `/components/base/alert-dialog`).
