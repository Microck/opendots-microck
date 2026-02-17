# Accessibility

## Defaults
- Base UI components are designed to be accessible by default with ARIA roles and keyboard behavior.
- Base UI follows WAI-ARIA patterns and is tested across modern platforms.

## Focus and Keyboard
- Preserve focus management and keyboard navigation when using render props.
- Ensure focus-visible styles remain present after custom styling.

## Labels and Errors
- Provide visible labels and accessible descriptions for form fields.
- Use `Field.Label`, `Field.Description`, and `Field.Error` for accessible form content.

## Testing
- Test keyboard-only navigation and screen readers for custom compositions.
- Validate color contrast and focus rings in your theme.
