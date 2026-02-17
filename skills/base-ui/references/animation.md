# Animation

## Data Attributes for CSS
- Use `data-open`/`data-closed` for keyframe animations.
- Use `data-starting-style`/`data-ending-style` for CSS transitions.

## JS Animation Libraries
- Base UI uses the Web Animations API via `getAnimations()` to detect animations.
- If your animation does not touch opacity, set opacity to `0.9999` to ensure detection.

## Mounting and Presence
- Many components unmount on close. Use `Portal keepMounted` when you need exit animations.
- With libraries like Framer Motion, render a `motion` element via the render prop and control `open` for presence.

## Checklist
- Ensure the animation target is the Popup element (or equivalent).
- Prefer `keepMounted` for smooth exit animations.
