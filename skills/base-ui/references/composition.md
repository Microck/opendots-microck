# Composition and render Prop

## Render Prop
- Use `render` to swap the underlying element or wrap it in a custom component.
- Always forward refs and spread all props in custom components.
- You can nest render props for compound components when needed.

## Guidance
- Prefer render prop composition for `asChild`-style behavior.
- Use `useRender` (see `references/utils.md`) for complex ref/prop merging.
- Validate focus and keyboard behavior after replacing elements.
