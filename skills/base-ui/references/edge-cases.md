# Edge Cases and Gotchas

- **Portals**: Add `isolation: isolate` to your layout root to avoid stacking issues.
- **iOS 26 Safari**: Set `body { position: relative; }` for backdrop components.
- **CSP**: `style-src-attr` still blocks inline style attributes even with CSPProvider.
- **mergeProps**: Refs are not merged; handle ref composition manually.
- **preventBaseUIHandler**: Only works with React synthetic events.
- **Render prop**: Custom elements must forward refs and spread props or focus/keyboard breaks.
- **Animation**: Use `keepMounted` for exit animations; `getAnimations()` requires opacity changes.
- **RTL**: Set `dir` on the DOM in addition to DirectionProvider for correct layout.
