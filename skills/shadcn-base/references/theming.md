# Theming

## Docs
- https://ui.shadcn.com/docs/theming
- Colors: https://ui.shadcn.com/docs/theming/colors
- Typography: https://ui.shadcn.com/docs/theming/typography

## Core Ideas
- Use CSS variables (recommended) or utility classes via `tailwind.cssVariables` in components.json.
- Tokens follow background/foreground conventions in the theme layer.

## Constraints
- `tailwind.baseColor` cannot be changed after initialization; reinstall is required.
- Changing `tailwind.cssVariables` later requires reinstall.

## Guidance
- Align light/dark palettes with your dark mode strategy.
