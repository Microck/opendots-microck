# Theatre.js Prop Types

## Basic Props (Inferred)

When you pass plain values, Theatre.js infers the type:

```tsx
const obj = sheet.object('Box', {
  // Inferred types
  x: 0,              // number
  y: 100,            // number
  visible: true,     // boolean
  label: 'Hello',    // string
  position: {        // compound (nested object)
    x: 0,
    y: 0,
    z: 0
  }
})
```

## Explicit Types

Import `types` for advanced configuration:

```tsx
import { types } from '@theatre/core'
```

### Number

```tsx
types.number(defaultValue, options?)

const obj = sheet.object('Light', {
  // Basic
  intensity: types.number(1),

  // With range (UI slider bounds)
  brightness: types.number(0.5, { range: [0, 1] }),

  // With nudge multiplier (scrubbing sensitivity)
  rotation: types.number(0, {
    range: [-180, 180],
    nudgeMultiplier: 0.1  // Finer control
  }),

  // Large values
  distance: types.number(1000, {
    range: [0, 10000],
    nudgeMultiplier: 10
  })
})
```

### Boolean

```tsx
types.boolean(defaultValue)

const obj = sheet.object('Toggle', {
  visible: types.boolean(true),
  enabled: types.boolean(false)
})
```

### String

```tsx
types.string(defaultValue, options?)

const obj = sheet.object('Text', {
  content: types.string('Hello World'),

  // Multiline (v0.6+)
  description: types.string('', { multiline: true })
})
```

### String Literal (Enum/Menu)

```tsx
types.stringLiteral(defaultValue, choices, options?)

const obj = sheet.object('Settings', {
  // Dropdown menu (default)
  easing: types.stringLiteral('easeInOut', {
    linear: 'Linear',
    easeIn: 'Ease In',
    easeOut: 'Ease Out',
    easeInOut: 'Ease In-Out'
  }),

  // Radio buttons
  size: types.stringLiteral('medium', {
    small: 'Small',
    medium: 'Medium',
    large: 'Large'
  }, { as: 'radio' })
})

// Type-safe access
const easing = obj.value.easing  // 'linear' | 'easeIn' | 'easeOut' | 'easeInOut'
```

### RGBA Color

```tsx
types.rgba(defaultValue?)

const obj = sheet.object('Material', {
  // Default white
  color: types.rgba(),

  // Custom default (values 0-1)
  tint: types.rgba({ r: 1, g: 0.5, b: 0, a: 1 }),

  // Transparent
  overlay: types.rgba({ r: 0, g: 0, b: 0, a: 0.5 })
})

// Access values
const { r, g, b, a } = obj.value.color  // Each 0-1

// Convert to CSS
const cssColor = `rgba(${r * 255}, ${g * 255}, ${b * 255}, ${a})`

// Convert to Three.js
new THREE.Color(r, g, b)
```

### Compound (Nested Objects)

```tsx
types.compound(props, options?)

const obj = sheet.object('Transform', {
  position: types.compound({
    x: types.number(0),
    y: types.number(0),
    z: types.number(0)
  }),

  rotation: types.compound({
    x: types.number(0, { range: [-180, 180] }),
    y: types.number(0, { range: [-180, 180] }),
    z: types.number(0, { range: [-180, 180] })
  }),

  // Collapsed by default in UI
  advanced: types.compound({
    pivot: types.compound({ x: 0, y: 0 }),
    skew: types.number(0)
  }, { collapsed: true })
})
```

### Image Asset (v0.6+)

```tsx
types.image(defaultValue, options?)

const obj = sheet.object('Sprite', {
  texture: types.image(''),  // Empty default

  // With default image path
  background: types.image('/images/default-bg.png')
})

// Get URL for use
const textureUrl = project.getAssetUrl(obj.value.texture)
```

### File Asset (v0.7+)

```tsx
types.file(defaultValue, options?)

const obj = sheet.object('Audio', {
  soundFile: types.file(''),

  // Filter by extension
  model: types.file('', {
    accept: '.glb,.gltf'
  })
})
```

## Compound Patterns

### Vector3

```tsx
const vector3 = (x = 0, y = 0, z = 0) => types.compound({
  x: types.number(x),
  y: types.number(y),
  z: types.number(z)
})

const obj = sheet.object('Cube', {
  position: vector3(0, 1, 0),
  rotation: vector3(),
  scale: vector3(1, 1, 1)
})
```

### Transform

```tsx
const transform = () => types.compound({
  position: types.compound({
    x: types.number(0),
    y: types.number(0),
    z: types.number(0)
  }),
  rotation: types.compound({
    x: types.number(0, { range: [-180, 180] }),
    y: types.number(0, { range: [-180, 180] }),
    z: types.number(0, { range: [-180, 180] })
  }),
  scale: types.compound({
    x: types.number(1, { range: [0.01, 10] }),
    y: types.number(1, { range: [0.01, 10] }),
    z: types.number(1, { range: [0.01, 10] })
  })
})

const obj = sheet.object('Player', {
  transform: transform()
})
```

### Material

```tsx
const pbrMaterial = () => types.compound({
  color: types.rgba({ r: 1, g: 1, b: 1, a: 1 }),
  metalness: types.number(0, { range: [0, 1] }),
  roughness: types.number(0.5, { range: [0, 1] }),
  emissive: types.rgba({ r: 0, g: 0, b: 0, a: 1 }),
  emissiveIntensity: types.number(0, { range: [0, 10] })
})
```

## Applying to Three.js

```tsx
const obj = sheet.object('Mesh', {
  position: types.compound({ x: 0, y: 0, z: 0 }),
  rotation: types.compound({ x: 0, y: 0, z: 0 }),
  color: types.rgba({ r: 1, g: 0.5, b: 0, a: 1 })
})

obj.onValuesChange(({ position, rotation, color }) => {
  mesh.position.set(position.x, position.y, position.z)
  mesh.rotation.set(
    THREE.MathUtils.degToRad(rotation.x),
    THREE.MathUtils.degToRad(rotation.y),
    THREE.MathUtils.degToRad(rotation.z)
  )
  mesh.material.color.setRGB(color.r, color.g, color.b)
  mesh.material.opacity = color.a
})
```

## Type Inference

Theatre.js provides TypeScript inference:

```tsx
const obj = sheet.object('Config', {
  count: types.number(5),
  mode: types.stringLiteral('auto', { auto: 'Auto', manual: 'Manual' }),
  enabled: types.boolean(true)
})

// obj.value is typed as:
// {
//   count: number
//   mode: 'auto' | 'manual'
//   enabled: boolean
// }
```
