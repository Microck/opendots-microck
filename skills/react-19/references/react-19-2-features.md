# React 19.1+ and 19.2 Features

Features added after the initial React 19.0 release.

## React 19.1 (March 2025)

### Owner Stacks

Enhanced debugging information showing component ownership hierarchy in error messages and stack traces.

- Better error messages with ownership context
- Improved stack traces showing which component created a problematic element
- Helps trace issues through component composition

---

## React 19.2 (October 2025)

### `<Activity>` Component

Hide and restore UI and internal state without unmounting. Think of it as "background tabs" for React.

```tsx
import { Activity } from 'react';

function App() {
  const [activeTab, setActiveTab] = useState('home');

  return (
    <div>
      <TabBar activeTab={activeTab} onChange={setActiveTab} />

      {/* State preserved when hidden */}
      <Activity mode={activeTab === 'home' ? 'visible' : 'hidden'}>
        <HomePage />
      </Activity>

      <Activity mode={activeTab === 'settings' ? 'visible' : 'hidden'}>
        <SettingsPage />
      </Activity>
    </div>
  );
}
```

#### Props

| Prop | Type | Description |
|------|------|-------------|
| `mode` | `'visible' \| 'hidden'` | Controls visibility. Defaults to `'visible'` |
| `children` | `ReactNode` | UI to show/hide |

#### Behavior

**When hidden:**
- Children are visually hidden (`display: none`)
- Effects are destroyed and cleaned up
- Children still re-render (at lower priority) when props change
- State is preserved

**When visible again:**
- Children revealed with previous state restored
- Effects re-created

#### vs Conditional Rendering

```tsx
// Conditional: State lost on toggle
{showSidebar && <Sidebar />}

// Activity: State preserved
<Activity mode={showSidebar ? 'visible' : 'hidden'}>
  <Sidebar />
</Activity>
```

#### Use Cases

**1. Tab Preservation**
```tsx
function TabContainer({ tabs, activeTab }) {
  return (
    <div>
      {tabs.map(tab => (
        <Activity
          key={tab.id}
          mode={tab.id === activeTab ? 'visible' : 'hidden'}
        >
          <TabContent tab={tab} />
        </Activity>
      ))}
    </div>
  );
}
```

**2. Pre-rendering**
```tsx
// Pre-render content likely to become visible
<Suspense fallback={<Skeleton />}>
  <Activity mode={isExpanded ? 'visible' : 'hidden'}>
    <ExpensiveContent /> {/* Loads data in background */}
  </Activity>
</Suspense>
```

**3. Improved Hydration**
```tsx
// Hidden Activity boundaries enable Selective Hydration
// Interactive elements hydrate before hidden content
<Activity mode={showDetails ? 'visible' : 'hidden'}>
  <HeavyDetails />
</Activity>
```

#### Caveats

**Media elements continue playing when hidden:**
```tsx
function VideoTab() {
  const ref = useRef<HTMLVideoElement>(null);

  // Use useLayoutEffect for immediate cleanup
  useLayoutEffect(() => {
    return () => {
      ref.current?.pause(); // Pause when hidden
    };
  }, []);

  return <video ref={ref} controls src="..." />;
}
```

**Text-only components don't render when hidden:**
```tsx
// Won't work - no DOM element to hide
<Activity mode="hidden">
  <ComponentReturningOnlyText />
</Activity>
```

---

### `useEffectEvent` Hook

Extract non-reactive logic from Effects without adding dependencies.

```tsx
import { useEffect, useEffectEvent } from 'react';

function ChatRoom({ roomId, theme }) {
  // This reads `theme` without making it a dependency
  const onConnected = useEffectEvent(() => {
    showNotification(`Connected to ${roomId}`, theme);
  });

  useEffect(() => {
    const connection = createConnection(roomId);
    connection.on('connected', () => {
      onConnected(); // Can call this without listing theme as dependency
    });
    connection.connect();
    return () => connection.disconnect();
  }, [roomId]); // theme is NOT a dependency
}
```

#### The Problem It Solves

```tsx
// Without useEffectEvent: theme change reconnects!
useEffect(() => {
  const connection = createConnection(roomId);
  connection.on('connected', () => {
    showNotification(`Connected to ${roomId}`, theme);
  });
  connection.connect();
  return () => connection.disconnect();
}, [roomId, theme]); // theme causes unnecessary reconnection

// With useEffectEvent: theme change does NOT reconnect
const onConnected = useEffectEvent(() => {
  showNotification(`Connected to ${roomId}`, theme);
});

useEffect(() => {
  const connection = createConnection(roomId);
  connection.on('connected', onConnected);
  connection.connect();
  return () => connection.disconnect();
}, [roomId]); // Only roomId - theme changes don't reconnect
```

#### Rules

1. **Only call from inside Effects** - Not in render, event handlers, or other hooks
2. **Don't pass to other components** - Keep them local to the Effect
3. **Always reads latest values** - No stale closures

#### Common Patterns

**Analytics without re-triggering:**
```tsx
function Page({ url }) {
  const { items } = useContext(CartContext);

  const onVisit = useEffectEvent((visitedUrl) => {
    logAnalytics(visitedUrl, items.length); // reads latest items
  });

  useEffect(() => {
    onVisit(url);
  }, [url]); // items changes don't re-trigger
}
```

**Event handlers in Effects:**
```tsx
function ChatRoom({ roomId, isMuted }) {
  const onMessage = useEffectEvent((message) => {
    if (!isMuted) {
      playSound();
    }
    addMessage(message);
  });

  useEffect(() => {
    const connection = createConnection(roomId);
    connection.on('message', onMessage);
    return () => connection.disconnect();
  }, [roomId]); // isMuted changes don't reconnect
}
```

---

### `cacheSignal` (Server Components)

Notification mechanism for RSC cache lifetime expiration.

```tsx
// In Server Component
import { cacheSignal } from 'react';

async function DataComponent() {
  const signal = cacheSignal();

  const data = await fetchWithSignal('/api/data', { signal });

  return <div>{data}</div>;
}
```

Used internally by frameworks to manage RSC cache invalidation.

---

### Resume APIs for SSR Streams

New APIs for resuming server-side rendering streams.

**Web Streams:**
```tsx
import { resume, resumeAndPrerender } from 'react-dom/static';

// Resume a prerender to continue streaming
const stream = await resume(prerenderResult, options);

// Resume and generate complete HTML
const { prelude } = await resumeAndPrerender(prerenderResult, options);
```

**Node Streams:**
```tsx
import {
  resumeToPipeableStream,
  resumeAndPrerenderToNodeStream
} from 'react-dom/static';

// Resume to pipeable stream
const { pipe } = await resumeToPipeableStream(prerenderResult, options);

// Resume and generate complete HTML
const { prelude } = await resumeAndPrerenderToNodeStream(prerenderResult, options);
```

---

### Other 19.2 Changes

**Batched Suspense Reveals:**
- Multiple Suspense boundaries revealing at similar times are batched together
- Smoother visual transitions, less layout thrashing

**Performance Tracks in DevTools:**
- React now adds performance marks to browser DevTools timeline
- Easier profiling of React rendering phases

**useId Format Change:**
- IDs now use underscores (`_`) instead of colons (`:`)
- Better compatibility with CSS selectors
- Example: `:r1:` → `_r1_`

---

## Version Compatibility

| Feature | Minimum Version |
|---------|-----------------|
| `<Activity>` | 19.2.0 |
| `useEffectEvent` | 19.2.0 |
| `cacheSignal` | 19.2.0 |
| Resume APIs | 19.2.0 |
| Owner Stacks | 19.1.0 |
| Performance tracks | 19.2.0 |
| Batched Suspense | 19.2.0 |
