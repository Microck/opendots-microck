# Theatre.js React Integration

## Installation

```bash
npm install @theatre/react
```

## useVal Hook

Subscribe to Theatre.js values reactively:

```tsx
import { useVal } from '@theatre/react'
import { getProject } from '@theatre/core'

const project = getProject('My Project')
const sheet = project.sheet('Main')
const obj = sheet.object('Box', { x: 0, y: 0, opacity: 1 })

function Box() {
  // Subscribe to single prop
  const x = useVal(obj.props.x)
  const y = useVal(obj.props.y)
  const opacity = useVal(obj.props.opacity)

  return (
    <div
      style={{
        transform: `translate(${x}px, ${y}px)`,
        opacity
      }}
    >
      Box
    </div>
  )
}
```

### useVal with Nested Props

```tsx
const obj = sheet.object('Transform', {
  position: { x: 0, y: 0, z: 0 }
})

function Component() {
  // Individual nested values
  const x = useVal(obj.props.position.x)
  const y = useVal(obj.props.position.y)

  // Or entire compound
  const position = useVal(obj.props.position)
  // position = { x: 0, y: 0, z: 0 }
}
```

### useVal with Sequence

```tsx
function PlaybackPosition() {
  const position = useVal(sheet.sequence.pointer.position)
  return <div>Current time: {position.toFixed(2)}s</div>
}
```

## usePrism Hook

Create derived reactive values:

```tsx
import { usePrism } from '@theatre/react'
import { val } from '@theatre/dataverse'

function Component() {
  const derivedValue = usePrism(() => {
    const x = val(obj.props.x)
    const y = val(obj.props.y)
    return Math.sqrt(x * x + y * y)  // Distance from origin
  }, [])

  return <div>Distance: {derivedValue}</div>
}
```

### With Dependencies

```tsx
function Component({ multiplier }) {
  const scaledX = usePrism(() => {
    return val(obj.props.x) * multiplier
  }, [multiplier])  // Re-run when multiplier changes
}
```

### Prism Hooks Inside usePrism

```tsx
import { prism } from '@theatre/dataverse'

function Component() {
  const value = usePrism(() => {
    // Memoize expensive computation
    const expensive = prism.memo('expensive', () => {
      return computeExpensiveValue()
    }, [])

    // Run side effects
    prism.effect('logger', () => {
      console.log('Value changed')
      return () => console.log('Cleanup')
    }, [])

    return expensive * val(obj.props.scale)
  }, [])
}
```

## Dataverse Primitives

### Atom (State Container)

```tsx
import { Atom } from '@theatre/dataverse'
import { useVal } from '@theatre/react'

// Create atom (typically outside component)
const appState = new Atom({
  count: 0,
  user: { name: 'Guest' }
})

function Counter() {
  const count = useVal(appState.pointer.count)

  const increment = () => {
    appState.setByPointer(
      appState.pointer.count,
      (prev) => prev + 1
    )
  }

  return (
    <button onClick={increment}>
      Count: {count}
    </button>
  )
}
```

### Atom Methods

```tsx
// Read
const value = appState.get()  // Full state
const count = appState.getByPointer(appState.pointer.count)

// Write
appState.set({ count: 5, user: { name: 'Alice' } })
appState.setByPointer(appState.pointer.count, 10)
appState.setByPointer(appState.pointer.count, (prev) => prev + 1)

// Subscribe (outside React)
const unsub = appState.onChangeByPointer(
  appState.pointer.count,
  (newCount) => console.log(newCount)
)
```

## Patterns

### Animating React Components

```tsx
const obj = sheet.object('Card', {
  x: 0,
  y: 0,
  rotation: 0,
  scale: 1
})

function AnimatedCard({ children }) {
  const x = useVal(obj.props.x)
  const y = useVal(obj.props.y)
  const rotation = useVal(obj.props.rotation)
  const scale = useVal(obj.props.scale)

  return (
    <div
      style={{
        transform: `
          translate(${x}px, ${y}px)
          rotate(${rotation}deg)
          scale(${scale})
        `
      }}
    >
      {children}
    </div>
  )
}
```

### Controlling Playback

```tsx
function PlaybackControls() {
  const position = useVal(sheet.sequence.pointer.position)

  const play = () => sheet.sequence.play()
  const pause = () => sheet.sequence.pause()
  const reset = () => { sheet.sequence.position = 0 }

  return (
    <div>
      <span>{position.toFixed(2)}s</span>
      <button onClick={play}>Play</button>
      <button onClick={pause}>Pause</button>
      <button onClick={reset}>Reset</button>
    </div>
  )
}
```

### Multiple Objects

```tsx
// Create objects array
const items = [0, 1, 2].map((i) =>
  sheet.object(`Item-${i}`, { x: i * 100, opacity: 1 })
)

function ItemList() {
  return (
    <>
      {items.map((obj, i) => (
        <AnimatedItem key={i} theatreObject={obj} />
      ))}
    </>
  )
}

function AnimatedItem({ theatreObject }) {
  const x = useVal(theatreObject.props.x)
  const opacity = useVal(theatreObject.props.opacity)

  return (
    <div style={{ transform: `translateX(${x}px)`, opacity }}>
      Item
    </div>
  )
}
```

### Conditional Animation

```tsx
function ConditionalAnimation({ isActive }) {
  const obj = useMemo(() =>
    isActive
      ? sheet.object('Active', { scale: 1 })
      : null,
    [isActive]
  )

  const scale = useVal(obj?.props.scale) ?? 1

  useEffect(() => {
    return () => {
      if (obj) sheet.detachObject('Active')
    }
  }, [obj])

  return <div style={{ transform: `scale(${scale})` }} />
}
```

## Theatric (Simplified Controls)

For quick prototyping without full Theatre.js setup:

```tsx
import { useControls, types } from 'theatric'

function Component() {
  const { color, speed, enabled } = useControls({
    color: '#ff0000',
    speed: types.number(1, { range: [0, 10] }),
    enabled: true
  })

  return (
    <div style={{ color }}>
      Speed: {speed}, Enabled: {enabled.toString()}
    </div>
  )
}
```

### Theatric with Buttons

```tsx
import { useControls, button } from 'theatric'

function Component() {
  const { count, $get, $set } = useControls({
    count: 0,
    increment: button(() => {
      $set(v => v.count, $get(v => v.count) + 1)
    }),
    reset: button(() => {
      $set(v => v.count, 0)
    })
  })

  return <div>Count: {count}</div>
}
```

### Initialize Theatric with State

```tsx
import { initialize, useControls } from 'theatric'
import state from './theatric-state.json'

// Initialize once at app start
initialize({ state })

function App() {
  const controls = useControls({ /* ... */ })
}
```
