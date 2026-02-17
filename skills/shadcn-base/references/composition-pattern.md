# Composition Pattern (Base UI Only)

## Paradigm (Clear and Precise)
This skill follows a consumer-owned UI model:

1) Foundation: **Headless/unstyled primitives** with a **copy-and-own distribution** model.
   - Base UI provides the primitives and behaviors.
   - shadcn/ui delivers **styled components** that are copied into the consumer’s codebase.
   - The consumer owns the source and controls styling and API decisions.

2) Composition style:
   - **Compound Component Pattern** (composition via nested subcomponents).
   - **Composition over Inheritance** (principle).
   - **Variant-driven styling** (CVA or equivalent) applied inside the copied components.

3) Render model:
   - **Render-prop substitution** is the primary composition mechanism.
   - Base UI’s `useRender` enables `render` props in custom components.

## Rule (Base UI Choice)
Use Base UI composition only: `render` prop and `useRender`.
Prefer render props over slots because Base UI uses render-based composition.

## Allowed
- Render prop composition (`render={...}`) for element substitution.
- `useRender` for custom components that accept a `render` prop.
- Compound components (e.g., `Card`, `CardHeader`, `CardContent`).
- Variant-driven styling (CVA or similar) inside the copied component code.

## Disallowed
- Radix Slot / `asChild` patterns.
- Radix-only primitives or APIs.

## Rationale
The Base UI edition of shadcn/ui must use Base UI primitives and render-based composition. Slot/asChild is Radix-specific and produces the wrong API surface for this skill.

## Evidence (Docs + Research)
Use these references when explaining the paradigm or justifying API choices:

- React docs on composition over inheritance: https://legacy.reactjs.org/docs/composition-vs-inheritance.html
- Base UI `useRender` (render props): https://base-ui.com/react/utils/use-render
- shadcn/ui “not a component library” and copy-and-own distribution: https://ui.shadcn.com/docs
- Compound component pattern (reference): https://www.patterns.dev/react/compound-pattern
- CVA (variant-driven styling) docs: https://www.npmjs.com/package/class-variance-authority
- Component-based software engineering research: https://hrcak.srce.hr/44741

## Cross-Reference
- Base UI skill: skills/base-ui
- Vercel composition guidance: /Users/jbm/.agents/skills/vercel-composition-patterns
