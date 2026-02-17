# Theatre.js Production Deployment

## Exporting Animation State

### From Studio UI

1. Open Theatre.js Studio
2. Click project name in Outline panel
3. Click **Export** button
4. Save JSON file (e.g., `animation-state.json`)

### File Structure

```json
{
  "sheetsById": {
    "Main": {
      "staticOverrides": {
        "byObject": {
          "Box": {
            "position": { "x": 100, "y": 50 }
          }
        }
      },
      "sequence": {
        "tracksByObject": {
          "Box": {
            "trackData": { /* keyframes */ }
          }
        }
      }
    }
  }
}
```

## Loading State in Production

```tsx
import { getProject } from '@theatre/core'
import state from './animation-state.json'

// Production: load pre-exported state
const project = getProject('My Project', { state })
```

### Development vs Production

```tsx
import { getProject } from '@theatre/core'

let project: IProject

if (import.meta.env.DEV) {
  // Development: use Studio (state in localStorage)
  const studio = await import('@theatre/studio')
  studio.default.initialize()
  project = getProject('My Project')
} else {
  // Production: load exported state
  const state = await import('./animation-state.json')
  project = getProject('My Project', { state: state.default })
}
```

### Dynamic Import Pattern

```tsx
async function initTheatre() {
  const { getProject } = await import('@theatre/core')

  if (import.meta.env.DEV) {
    const studio = await import('@theatre/studio')
    const extension = await import('@theatre/r3f/dist/extension')
    studio.default.initialize()
    studio.default.extend(extension.default)
    return getProject('My Project')
  } else {
    const state = await import('./state.json')
    return getProject('My Project', { state: state.default })
  }
}
```

## Tree-Shaking Studio

Ensure Studio is not included in production bundle:

### Vite

```tsx
// Works automatically with import.meta.env.DEV
if (import.meta.env.DEV) {
  import('@theatre/studio').then(({ default: studio }) => {
    studio.initialize()
  })
}
```

### Next.js

```tsx
// pages/_app.tsx
if (process.env.NODE_ENV === 'development') {
  require('@theatre/studio').default.initialize()
}
```

### Webpack

```js
// webpack.config.js
module.exports = {
  resolve: {
    alias: {
      // Replace studio with empty module in production
      '@theatre/studio': process.env.NODE_ENV === 'production'
        ? false
        : '@theatre/studio'
    }
  }
}
```

## Assets Management

### Asset Types
- Images: `.png`, `.jpg`, `.webp`, `.hdr`
- Files: Any file type (v0.7+)

### Exporting Assets

1. Assets are stored separately from state JSON
2. Export assets from Studio
3. Place in public folder

### Loading Assets in Production

```tsx
import { getProject } from '@theatre/core'
import state from './state.json'

const project = getProject('My Project', {
  state,
  assets: {
    // Base URL for assets (no trailing slash)
    baseUrl: '/theatre-assets'
  }
})

// Get asset URL
const imageUrl = project.getAssetUrl(obj.value.texture)
```

### Asset Configuration

```tsx
getProject('My Project', {
  state,
  assets: {
    // Local assets
    baseUrl: '/assets/theatre',

    // CDN assets
    baseUrl: 'https://cdn.example.com/theatre-assets',
  }
})
```

## Versioning Animation State

### Git Workflow

```bash
# Track state file
git add animation-state.json

# Commit animation changes
git commit -m "Update intro animation timing"
```

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Copy animation state
  run: cp src/animation-state.json dist/

- name: Copy theatre assets
  run: cp -r public/theatre-assets dist/
```

## Performance Optimization

### Lazy Loading

```tsx
// Load Theatre.js only when needed
const TheatreScene = lazy(() => import('./TheatreScene'))

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <TheatreScene />
    </Suspense>
  )
}
```

### Preload State

```tsx
// Preload during idle time
if ('requestIdleCallback' in window) {
  requestIdleCallback(() => {
    import('./animation-state.json')
  })
}
```

## Multiple Projects

```tsx
// scenes/intro.ts
import introState from './intro-state.json'
export const introProject = getProject('Intro', { state: introState })

// scenes/gameplay.ts
import gameplayState from './gameplay-state.json'
export const gameplayProject = getProject('Gameplay', { state: gameplayState })
```

## Error Handling

```tsx
try {
  const project = getProject('My Project', { state })
  await project.ready
} catch (error) {
  console.error('Failed to load Theatre.js project:', error)
  // Fallback behavior
}
```

## State Schema Migrations

When animation structure changes:

```tsx
// migration.ts
export function migrateState(oldState: any): any {
  // Handle schema changes
  if (oldState.version < 2) {
    // Migrate old structure
    oldState.sheetsById.Main.staticOverrides.byObject.Box =
      oldState.sheetsById.Main.staticOverrides.byObject.OldBox
    delete oldState.sheetsById.Main.staticOverrides.byObject.OldBox
  }
  return oldState
}

// Usage
import rawState from './state.json'
const state = migrateState(rawState)
const project = getProject('My Project', { state })
```

## Debugging Production

### Verify State Loaded

```tsx
const project = getProject('My Project', { state })
await project.ready

console.log('Project ready:', project.isReady)

const sheet = project.sheet('Main')
const obj = sheet.object('Box', { x: 0 })
console.log('Initial values:', obj.value)
```

### Check Sequence Duration

```tsx
sheet.sequence.position = 0
console.log('Sequence length:', sheet.sequence.pointer.length)
```

## Checklist

- [ ] Export state JSON from Studio
- [ ] Place assets in correct public path
- [ ] Configure asset baseUrl in production
- [ ] Ensure Studio not imported in production
- [ ] Test animations play correctly
- [ ] Verify asset URLs resolve
- [ ] Check bundle size (Studio excluded)
- [ ] Test on production build locally
