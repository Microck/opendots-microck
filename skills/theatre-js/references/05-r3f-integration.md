# Theatre.js React Three Fiber Integration

## Installation

```bash
npm install @theatre/core @theatre/studio @theatre/r3f
npm install three @react-three/fiber
```

## Setup

```tsx
import { Canvas } from '@react-three/fiber'
import { SheetProvider, editable as e } from '@theatre/r3f'
import { getProject } from '@theatre/core'
import studio from '@theatre/studio'
import extension from '@theatre/r3f/dist/extension'

// Initialize Studio with R3F extension (dev only)
if (import.meta.env.DEV) {
  studio.initialize()
  studio.extend(extension)
}

// Create project and sheet
const project = getProject('My 3D Project')
const sheet = project.sheet('Scene')
```

## SheetProvider

Wraps your scene to connect to Theatre.js:

```tsx
function App() {
  return (
    <Canvas>
      <SheetProvider sheet={sheet}>
        {/* All editable components go here */}
        <Scene />
      </SheetProvider>
    </Canvas>
  )
}
```

## Editable Components

Use `e.` prefix to make Three.js objects editable:

```tsx
import { editable as e } from '@theatre/r3f'

function Scene() {
  return (
    <>
      {/* Editable mesh */}
      <e.mesh theatreKey="Cube">
        <boxGeometry args={[1, 1, 1]} />
        <meshStandardMaterial color="orange" />
      </e.mesh>

      {/* Editable lights */}
      <e.pointLight
        theatreKey="MainLight"
        position={[10, 10, 10]}
        intensity={1}
      />

      <e.ambientLight theatreKey="Ambient" intensity={0.5} />

      {/* Editable group */}
      <e.group theatreKey="Group">
        <e.mesh theatreKey="Child1">
          <sphereGeometry />
          <meshStandardMaterial />
        </e.mesh>
      </e.group>
    </>
  )
}
```

### Available Editable Elements

```tsx
// Lights
<e.ambientLight theatreKey="..." />
<e.directionalLight theatreKey="..." />
<e.pointLight theatreKey="..." />
<e.spotLight theatreKey="..." />
<e.hemisphereLight theatreKey="..." />

// Objects
<e.mesh theatreKey="..." />
<e.group theatreKey="..." />
<e.line theatreKey="..." />
<e.points theatreKey="..." />

// Camera (special)
import { PerspectiveCamera } from '@theatre/r3f'
<PerspectiveCamera theatreKey="Camera" makeDefault />
```

## theatreKey Prop

**Required** for all editable components:

```tsx
// ✅ Unique keys
<e.mesh theatreKey="Player" />
<e.mesh theatreKey="Enemy" />

// ❌ Missing key - won't be editable
<e.mesh />

// ❌ Duplicate keys - conflict!
<e.mesh theatreKey="Box" />
<e.mesh theatreKey="Box" />  // Same object!
```

### Dynamic Keys

```tsx
function Enemy({ id }) {
  return (
    <e.mesh theatreKey={`Enemy-${id}`}>
      <boxGeometry />
      <meshStandardMaterial />
    </e.mesh>
  )
}

// Usage
{enemies.map(enemy => (
  <Enemy key={enemy.id} id={enemy.id} />
))}
```

## Editable Camera

```tsx
import { PerspectiveCamera } from '@theatre/r3f'

function Scene() {
  return (
    <>
      <PerspectiveCamera
        theatreKey="MainCamera"
        makeDefault  // Use as default camera
        position={[0, 5, 10]}
        fov={75}
      />
    </>
  )
}
```

### Camera with Orbit Controls

```tsx
import { OrbitControls } from '@react-three/drei'
import { PerspectiveCamera } from '@theatre/r3f'

function Scene() {
  return (
    <>
      <PerspectiveCamera
        theatreKey="Camera"
        makeDefault
        position={[0, 5, 10]}
      />
      <OrbitControls />
    </>
  )
}
```

## Custom Editable Components

Wrap custom components with `editable()`:

```tsx
import { editable } from '@theatre/r3f'

// Your custom component
function MyCustomMesh({ color, ...props }) {
  return (
    <mesh {...props}>
      <boxGeometry />
      <meshStandardMaterial color={color} />
    </mesh>
  )
}

// Make it editable
const EditableCustomMesh = editable(MyCustomMesh, 'mesh')

// Usage
<EditableCustomMesh theatreKey="Custom" color="red" />
```

### Editable with Additional Props

```tsx
import { editable } from '@theatre/r3f'
import { types } from '@theatre/core'

const EditableCube = editable(
  ({ color, ...props }) => (
    <mesh {...props}>
      <boxGeometry />
      <meshStandardMaterial color={color} />
    </mesh>
  ),
  'mesh',
  // Additional Theatre.js props
  {
    color: types.rgba({ r: 1, g: 0.5, b: 0, a: 1 })
  }
)

<EditableCube theatreKey="ColorCube" />
```

## Accessing Sheet Objects

```tsx
import { useCurrentSheet } from '@theatre/r3f'
import { useVal } from '@theatre/react'

function AnimationController() {
  const sheet = useCurrentSheet()

  const play = () => sheet.sequence.play({ iterationCount: Infinity })
  const pause = () => sheet.sequence.pause()

  return (
    <Html>
      <button onClick={play}>Play</button>
      <button onClick={pause}>Pause</button>
    </Html>
  )
}
```

## Manual Object Creation in R3F

For complex scenarios, create objects manually:

```tsx
import { useCurrentSheet } from '@theatre/r3f'
import { types } from '@theatre/core'
import { useVal } from '@theatre/react'
import { useMemo } from 'react'

function CustomAnimatedMesh() {
  const sheet = useCurrentSheet()

  const obj = useMemo(() =>
    sheet.object('CustomMesh', {
      wobble: types.number(0, { range: [0, 1] }),
      color: types.rgba({ r: 1, g: 0, b: 0, a: 1 })
    }),
    [sheet]
  )

  const wobble = useVal(obj.props.wobble)
  const color = useVal(obj.props.color)

  return (
    <mesh scale={[1 + wobble * 0.2, 1, 1]}>
      <boxGeometry />
      <meshStandardMaterial
        color={`rgb(${color.r * 255}, ${color.g * 255}, ${color.b * 255})`}
      />
    </mesh>
  )
}
```

## Sequence Playback

```tsx
function Scene() {
  useEffect(() => {
    // Auto-play on mount
    sheet.sequence.play({
      iterationCount: Infinity,
      range: [0, 5]
    })

    return () => sheet.sequence.pause()
  }, [])

  return (
    <SheetProvider sheet={sheet}>
      {/* scene content */}
    </SheetProvider>
  )
}
```

## Studio Transform Controls

When Studio is initialized with R3F extension:
- Select objects in 3D viewport
- Drag gizmos to transform
- Changes reflect in Studio panel

## Refresh on Hot Reload

```tsx
// Vite example
if (import.meta.hot) {
  import.meta.hot.accept(() => {
    // Studio maintains state across HMR
  })
}
```

## Production Build

```tsx
// Remove studio in production
const project = import.meta.env.DEV
  ? getProject('My Project')
  : getProject('My Project', { state: productionState })

// Only extend in dev
if (import.meta.env.DEV) {
  studio.initialize()
  studio.extend(extension)
}
```

## Common Patterns

### Animated Scene Intro

```tsx
function Scene() {
  useEffect(() => {
    project.ready.then(() => {
      sheet.sequence.play({ iterationCount: 1 })
    })
  }, [])

  return (
    <SheetProvider sheet={sheet}>
      <e.group theatreKey="Intro">
        <e.mesh theatreKey="Logo">
          <planeGeometry />
          <meshBasicMaterial map={logoTexture} />
        </e.mesh>
      </e.group>
    </SheetProvider>
  )
}
```

### Character with Multiple Parts

```tsx
function Character({ id }) {
  const characterSheet = project.sheet('Character', id)

  return (
    <SheetProvider sheet={characterSheet}>
      <e.group theatreKey="Root">
        <e.mesh theatreKey="Body" />
        <e.mesh theatreKey="Head" />
        <e.group theatreKey="LeftArm">
          <e.mesh theatreKey="UpperArm" />
          <e.mesh theatreKey="LowerArm" />
        </e.group>
      </e.group>
    </SheetProvider>
  )
}
```
