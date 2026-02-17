# Styling

## Core Ideas
- Base UI is unstyled and does not bundle CSS; you own the styling.
- Use `className` or `style` as strings or functions that receive component state.
- Use data attributes (like `data-open`, `data-disabled`, etc.) and CSS variables for stateful styling.

## Practical Patterns
- Tailwind: map data attributes to variant classes.
- CSS Modules or plain CSS: target `[data-*]` attributes and variables.
- CSS-in-JS: use render-state functions to compute styles.
- All of the above are compatible with Base UI.

## Checklist
- Confirm `className` accepts a function `(state) => string` when you need state-driven styles.
- Prefer data attributes for stateful styling and transitions.
- Keep default styles minimal so accessibility states (focus/disabled) remain visible.
