# Utilities

## CSPProvider
- Wrap your app to provide a nonce for inline `<style>` elements created by Base UI.
- Use `disableStyleElements` for ScrollArea and Select (when aligning items with the trigger).
- Note: CSP `style-src-attr` still blocks inline style attributes.

## DirectionProvider and RTL
- Wrap your app with `DirectionProvider` or set `dir` on a parent element.
- Use `useDirection` for portals to preserve direction in mounted trees.

## mergeProps
- Merges `className`, `style`, and event handlers from right to left.
- `className` becomes a single string; `style` objects are merged.
- Event handlers run in order (right to left).
- Refs are not merged; combine refs manually if needed.
- Use `preventBaseUIHandler` to stop Base UI handlers for React synthetic events.
- Use `mergePropsN` when merging more than five objects.

## useRender
- Use for robust render-prop composition (similar to `asChild`).
- Merges props and supports multiple refs.
- Provides typing helpers for custom components.
