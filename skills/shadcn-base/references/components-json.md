# components.json

## Docs
- https://ui.shadcn.com/docs/components-json

## Purpose
- Optional configuration file for the CLI.
- Required only if you use the CLI; copy/paste does not need it.

## Key Fields (see docs for full schema)
- `$schema`: JSON Schema for components.json (`https://ui.shadcn.com/schema.json`).
- `style`: component style preset; `default` is deprecated, use `new-york`.
- `tailwind.config`: path to Tailwind config; leave blank for Tailwind v4.
- `tailwind.css`: path to the CSS file importing Tailwind.
- `tailwind.baseColor`: base palette; cannot change after initialization.
- `tailwind.cssVariables`: true for CSS variables, false for utility classes; cannot change without reinstall.
- `tailwind.prefix`: prefix for Tailwind utilities.
- `rsc`: enable React Server Components; adds `use client` for client components.
- `tsx`: true for TSX; false for JSX output.
- `aliases`: `components`, `ui`, `utils`, `lib`, `hooks` paths.
- `registries`: named registry URLs and auth headers.

## Notes
- The CLI uses aliases plus your tsconfig/jsconfig paths to place generated files.
- Changing cssVariables later requires reinstalling components.
