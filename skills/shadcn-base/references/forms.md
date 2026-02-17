# Field Patterns (Form Fields)

Use the Field family to compose accessible field blocks with labels, help text, and errors.
See Base UI Field docs: https://ui.shadcn.com/docs/components/base/field
See Base UI skill: skills/base-ui

## Core Structure
- `Field` wraps a single control.
- `FieldLabel` links to the control via `htmlFor`.
- `FieldDescription` provides helper text.
- `FieldError` renders validation messages.

Minimal structure (per docs):
- Field → FieldLabel → control → FieldDescription → FieldError.

## Grouping
- Wrap related fields in `FieldGroup` and use `FieldSet` + `FieldLegend` for semantic grouping.
- Use `FieldSeparator` to visually divide grouped fields.

## Layout
- Default orientation stacks label, control, and helper text.
- Set `orientation="horizontal"` for side‑by‑side label/control.
- Set `orientation="responsive"` for container‑aware layouts; use `@container/field-group` on `FieldGroup`.

## Validation
- Apply `data-invalid` on `Field` for error state styling.
- Apply `aria-invalid` on the control for assistive tech.
- Place `FieldError` immediately after the control or inside `FieldContent` to align errors.

## Choice Cards
- Wrap `Field` components inside `FieldLabel` to create selectable groups (Radio, Checkbox, Switch).
