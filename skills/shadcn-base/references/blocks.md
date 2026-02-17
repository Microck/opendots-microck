# Blocks

## Docs
- https://ui.shadcn.com/docs/blocks

## What Blocks Are
- Blocks can be single components or multi-file compositions (components, hooks, utils).

## Contribution Flow (Summary)
- Create a folder under `apps/www/registry/new-york/blocks`.
- Add block files (page, components, hooks, lib).
- Add block definition to `registry-blocks.ts`.
- Run `pnpm registry:build` and `pnpm registry:capture`.
- Submit a PR when ready.

## Categories
- Use `categories` to organize blocks; add new categories in `registry-categories.ts` when needed.
