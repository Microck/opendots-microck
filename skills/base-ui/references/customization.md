# Customization and Events

## Change Handlers
- Many handlers follow `onOpenChange(open, eventDetails)` or `onValueChange(value, eventDetails)`.
- `eventDetails` includes a `reason` string describing why the change happened.

## Event Control
- Use `preventBaseUIHandler(event)` to stop Base UI handlers for React synthetic events.
- Use `allowPropagation` in `eventDetails` when you want native bubbling (for example, allow `Escape` to bubble).
- Use `cancel` in `eventDetails` to stop a Base UI event at the source when supported.

## Controlled vs Uncontrolled
- Prefer controlled props (`open`, `value`, etc.) when you need external state coordination.
- Use uncontrolled state for simpler components and local UI state.
