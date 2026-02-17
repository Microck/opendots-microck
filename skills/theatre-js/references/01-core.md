# Theatre.js Core API

## Project

```tsx
import { getProject } from '@theatre/core'

// Development (with Studio)
const project = getProject('My Project')

// Production (with exported state)
import state from './animation-state.json'
const project = getProject('My Project', { state })
```

### Project Properties

```tsx
project.ready      // Promise<void> - resolves when loaded
project.isReady    // boolean
project.address    // { projectId: string }
```

### Project Methods

```tsx
// Create or get a sheet
const sheet = project.sheet('SheetName')

// Sheet with instance ID (for multiple instances)
const sheet1 = project.sheet('Character', 'instance-1')
const sheet2 = project.sheet('Character', 'instance-2')

// Get asset URL (v0.6+)
const url = project.getAssetUrl(assetHandle)
```

## Sheet

Container for objects and sequences.

```tsx
const sheet = project.sheet('Main')
```

### Sheet Properties

```tsx
sheet.sequence     // Sequence object
sheet.project      // Parent project
sheet.address      // { projectId, sheetId, sheetInstanceId }
```

### Sheet Methods

```tsx
// Create object with props
const obj = sheet.object('Box', {
  position: { x: 0, y: 0 },
  scale: 1,
  opacity: 1
})

// Create object with custom types
import { types } from '@theatre/core'
const obj = sheet.object('Light', {
  intensity: types.number(1, { range: [0, 10] }),
  color: types.rgba({ r: 1, g: 1, b: 1, a: 1 })
})

// Detach object (v0.5.1+)
sheet.detachObject('Box')
```

## Object

Animatable entity with typed props.

```tsx
const obj = sheet.object('Card', {
  x: 0,
  y: 0,
  rotation: 0
})
```

### Object Properties

```tsx
obj.value          // Current values: { x: 0, y: 0, rotation: 0 }
obj.props          // Pointer to props (for useVal)
obj.initialValue   // Override default values
obj.sheet          // Parent sheet
obj.project        // Parent project
obj.address        // { projectId, sheetId, objectKey }
```

### Object Methods

```tsx
// Subscribe to value changes
const unsubscribe = obj.onValuesChange((values) => {
  console.log(values.x, values.y, values.rotation)
})

// Later: unsubscribe
unsubscribe()
```

### Listening to Changes

```tsx
// All props at once
obj.onValuesChange((values) => {
  element.style.transform = `translate(${values.x}px, ${values.y}px)`
})

// Single prop with useVal (React)
import { useVal } from '@theatre/react'
const x = useVal(obj.props.x)

// Single prop with onChange (vanilla)
import { onChange } from '@theatre/core'
onChange(obj.props.x, (x) => {
  console.log('x changed to', x)
})
```

## Sequence

Timeline with keyframes and playback control.

```tsx
const seq = sheet.sequence
```

### Sequence Properties

```tsx
seq.position       // Current time in seconds (get/set)
seq.pointer        // Pointer for reactive subscriptions
```

### Playback Methods

```tsx
// Basic play
seq.play()

// Play with options
seq.play({
  iterationCount: 1,           // Number of times (Infinity for loop)
  range: [0, 5],               // Start/end in seconds
  rate: 1,                     // Playback speed (1 = normal, 2 = 2x)
  direction: 'normal',         // 'normal' | 'reverse' | 'alternate' | 'alternateReverse'
})

// Pause
seq.pause()

// Seek to position
seq.position = 2.5  // Jump to 2.5 seconds
```

### Await Completion

```tsx
// Play returns a Promise
await seq.play({ iterationCount: 1 })
console.log('Animation finished!')

// Chain animations
await sheet1.sequence.play()
await sheet2.sequence.play()
```

### Audio Sync

```tsx
// Attach audio to sequence
await seq.attachAudio({
  source: audioElement,  // HTMLAudioElement or AudioBuffer
  // Optional: custom AudioContext
  audioContext: myAudioContext
})

// Now sequence syncs with audio
seq.play()
```

## Pointers and Reactivity

```tsx
import { val, onChange } from '@theatre/core'

// Read current value
const currentX = val(obj.props.x)

// Subscribe to changes
const unsub = onChange(obj.props.x, (newX) => {
  console.log('x is now', newX)
})

// With RAF driver for animation loop sync
onChange(obj.props.x, (x) => {
  // Called in sync with requestAnimationFrame
}, rafDriver)
```

## Multiple Sheet Instances

Use for animating multiple characters/objects with the same structure:

```tsx
// Same sheet structure, different instances
const enemy1Sheet = project.sheet('Enemy', 'enemy-1')
const enemy2Sheet = project.sheet('Enemy', 'enemy-2')

// Each has independent animation state
const enemy1 = enemy1Sheet.object('Body', { x: 0 })
const enemy2 = enemy2Sheet.object('Body', { x: 100 })

// Animate independently
enemy1Sheet.sequence.play()
enemy2Sheet.sequence.play({ rate: 0.5 })
```

## Waiting for Project Ready

```tsx
// Async/await
await project.ready
const sheet = project.sheet('Main')

// Or check sync
if (project.isReady) {
  // Safe to use
}

// Promise chain
project.ready.then(() => {
  sheet.sequence.play()
})
```
