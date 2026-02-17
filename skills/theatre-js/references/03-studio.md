# Theatre.js Studio

## Initialization

```tsx
import studio from '@theatre/studio'

// Basic initialization
studio.initialize()

// With options
studio.initialize({
  usePersistentStorage: true,  // Save to localStorage (default: true)
})
```

### Development-Only

```tsx
// Vite
if (import.meta.env.DEV) {
  studio.initialize()
}

// Next.js
if (process.env.NODE_ENV === 'development') {
  studio.initialize()
}

// Create React App
if (process.env.NODE_ENV !== 'production') {
  studio.initialize()
}
```

## Extensions

Extend Studio with additional functionality:

```tsx
// React Three Fiber extension
import extension from '@theatre/r3f/dist/extension'
studio.extend(extension)

// Multiple extensions
studio.extend(extension1)
studio.extend(extension2)
```

## Keyboard Shortcuts

### Playback
| Shortcut | Action |
|----------|--------|
| `Space` | Play/Pause |
| `Enter` | Play from start |

### Timeline
| Shortcut | Action |
|----------|--------|
| `←` / `→` | Move playhead by frame |
| `Shift + ←` / `→` | Move playhead by 10 frames |
| `Home` | Go to start |
| `End` | Go to end |

### Selection
| Shortcut | Action |
|----------|--------|
| `A` | Select all keyframes |
| `Delete` / `Backspace` | Delete selected |
| `Ctrl/Cmd + C` | Copy keyframes |
| `Ctrl/Cmd + V` | Paste keyframes |
| `Ctrl/Cmd + D` | Duplicate |

### View
| Shortcut | Action |
|----------|--------|
| `F` | Focus on selection |
| `Shift + drag` on timeline | Create focus range |
| `Alt + click` focus range | Clear focus range |

### General
| Shortcut | Action |
|----------|--------|
| `Ctrl/Cmd + Z` | Undo |
| `Ctrl/Cmd + Shift + Z` | Redo |
| `Escape` | Deselect / Close panel |

## Studio UI Panels

### Outline Panel (Left)
- Shows project hierarchy
- Projects → Sheets → Objects
- Click to select, expand/collapse

### Details Panel (Right)
- Shows selected object's props
- Edit values directly
- Right-click prop → "Sequence" to animate

### Sequence Editor (Bottom)
- Timeline with keyframes
- Drag keyframes to reposition
- Click connector → Edit easing curve
- Double-click keyframe → Edit value

## Creating Keyframes

1. Select object in Outline or viewport
2. In Details panel, right-click property
3. Select "Sequence" (or "Sequence all" for compound)
4. In Sequence Editor:
   - Move playhead to desired time
   - Change value in Details panel
   - Keyframe auto-created

## Editing Keyframes

### Move
- Drag keyframe horizontally

### Edit Value
- Click keyframe → inline editor popup
- Type new value

### Delete
- Select keyframe(s)
- Press `Delete` or right-click → Delete

### Copy/Paste
- Right-click keyframe → Copy
- Move playhead
- Right-click empty area → Paste

## Easing Curves

### Tween Editor
Click the line between two keyframes to open:
- Preset curves (ease-in, ease-out, etc.)
- Bezier handle controls
- Custom curve drawing

### Multi-Track Editor
For complex curves:
- Shows curve visualization
- Drag handles to shape curve
- Fine-grained control

## Focus Range

Isolate a section of the timeline:

1. Hold `Shift`
2. Drag across top bar of timeline
3. Playback loops within range
4. `Alt + click` range to clear

## Aggregate Keyframes

When compound props have keyframes at same position:
- Shows single "aggregate" keyframe
- Moving it moves all children
- Click to expand/edit individually

## Export/Import State

### Export
1. Click project name in Outline
2. Click "Export" button
3. Save JSON file

### Import (Production)
```tsx
import state from './theatre-state.json'

const project = getProject('My Project', { state })
```

## Studio API

```tsx
// Get current selection
const selection = studio.selection

// Listen to selection changes
studio.onSelectionChange((newSelection) => {
  console.log('Selected:', newSelection)
})

// Create a pane (custom UI)
const pane = studio.createPane('myPane')
pane.render(() => <MyCustomUI />)

// Transaction (batch changes)
studio.transaction(({ set }) => {
  set(obj.props.x, 10)
  set(obj.props.y, 20)
})

// Scrub (preview without committing)
const scrub = studio.scrub()
scrub.capture(({ set }) => {
  set(obj.props.x, 10)
})
// Later: scrub.commit() or scrub.discard()
```

## Hiding Studio UI

```tsx
// Programmatically hide/show
studio.ui.hide()
studio.ui.show()

// Check visibility
const isVisible = studio.ui.isHidden
```

## Persistent Storage

Studio saves state to localStorage by default:
- Keyframes and values persist across reloads
- Export to JSON for production

To disable:
```tsx
studio.initialize({
  usePersistentStorage: false
})
```
