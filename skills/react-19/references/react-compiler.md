# React Compiler

React Compiler is a build-time tool that automatically optimizes React applications.

## What It Does

1. **Skips cascading re-renders** - Child components don't re-render when parent state changes (unless their props changed)
2. **Memoizes expensive calculations** - Automatically caches computations used during rendering
3. **Optimizes callback functions** - Inline arrow functions in JSX no longer break memoization

## Before vs After

### Without React Compiler (Manual Optimization)

```tsx
import { useMemo, useCallback, memo } from 'react';

// Wrap component in memo
const ExpensiveList = memo(function ExpensiveList({ items, onSelect }) {
  // Memoize expensive computation
  const processed = useMemo(() => {
    return items
      .filter(item => item.active)
      .sort((a, b) => a.name.localeCompare(b.name));
  }, [items]);

  // Memoize callback
  const handleClick = useCallback((id) => {
    onSelect(id);
  }, [onSelect]);

  return (
    <ul>
      {processed.map(item => (
        // Bug: This inline function breaks memoization!
        <li key={item.id} onClick={() => handleClick(item.id)}>
          {item.name}
        </li>
      ))}
    </ul>
  );
});
```

### With React Compiler (Automatic)

```tsx
// No imports needed for memoization
function ExpensiveList({ items, onSelect }) {
  // Compiler memoizes this automatically
  const processed = items
    .filter(item => item.active)
    .sort((a, b) => a.name.localeCompare(b.name));

  // Compiler handles this
  const handleClick = (id) => {
    onSelect(id);
  };

  return (
    <ul>
      {processed.map(item => (
        // Compiler optimizes inline functions correctly
        <li key={item.id} onClick={() => handleClick(item.id)}>
          {item.name}
        </li>
      ))}
    </ul>
  );
}
```

## When Manual Memoization Is Still Useful

React Compiler doesn't replace all use cases for `useMemo`/`useCallback`:

### 1. Effect Dependencies

```tsx
function SearchResults({ query }) {
  // Need stable reference for effect dependency
  const searchParams = useMemo(
    () => ({ query, timestamp: Date.now() }),
    [query]
  );

  useEffect(() => {
    fetchResults(searchParams);
  }, [searchParams]); // Stable dependency
}
```

### 2. Sharing Across Components

React Compiler memoizes per-component. For shared expensive calculations:

```tsx
// Compiler doesn't share memoization across components
function ComponentA({ data }) {
  const expensive = processData(data); // Computed here
  return <Child result={expensive} />;
}

function ComponentB({ data }) {
  const expensive = processData(data); // Computed again!
  return <Other result={expensive} />;
}

// Solution: Lift to shared hook or context
function useProcessedData(data) {
  return useMemo(() => processData(data), [data]);
}
```

### 3. Explicit Control

When you need precise control over when recalculation happens:

```tsx
function Chart({ data, config }) {
  // Force recalculation only when data changes, not config
  const chartData = useMemo(() => transformData(data), [data]);
  // config changes won't trigger expensive transform
}
```

## Installation

### Next.js (15.3.1+)

```js
// next.config.js
module.exports = {
  experimental: {
    reactCompiler: true,
  },
};
```

### Vite

```bash
npm install babel-plugin-react-compiler
```

```js
// vite.config.js
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [
    react({
      babel: {
        plugins: ['babel-plugin-react-compiler'],
      },
    }),
  ],
});
```

### Babel

```bash
npm install babel-plugin-react-compiler
```

```js
// babel.config.js
module.exports = {
  plugins: ['babel-plugin-react-compiler'],
};
```

### Metro (React Native)

```js
// metro.config.js
const { getDefaultConfig } = require('@react-native/metro-config');

const config = getDefaultConfig(__dirname);

config.transformer.babelTransformerPath = require.resolve(
  './compiler-transformer.js'
);

module.exports = config;
```

## React Version Compatibility

React Compiler works with:
- React 19 (full support)
- React 18 (supported)
- React 17 (supported with configuration)

```js
// For React 17
module.exports = {
  plugins: [
    ['babel-plugin-react-compiler', { target: '17' }],
  ],
};
```

## Incremental Adoption

### Opt-in Mode

Only compile specific components:

```tsx
// Only this component is compiled
'use memo';
function OptimizedComponent() {
  // ...
}
```

### Opt-out Mode

Compile everything except specific components:

```tsx
// Skip compilation for this component
'use no memo';
function LegacyComponent() {
  // ...
}
```

## What Gets Optimized

| Code Pattern | Optimized? |
|--------------|------------|
| Inline arrow functions in JSX | Yes |
| Expensive calculations in components | Yes |
| Event handlers defined in component | Yes |
| Variables derived from props/state | Yes |
| Code outside components | No |
| Calculations shared across components | No (per-component only) |

## Rules of React

React Compiler requires following the [Rules of React](https://react.dev/reference/rules):

1. **Components must be pure** - Same inputs = same output
2. **Props and state are immutable** - Don't mutate
3. **Hook calls must be unconditional** - Same order every render
4. **Only call hooks at the top level** - Not in loops/conditions

### ESLint Plugin

```bash
npm install eslint-plugin-react-compiler
```

```js
// eslint.config.js
import reactCompiler from 'eslint-plugin-react-compiler';

export default [
  {
    plugins: {
      'react-compiler': reactCompiler,
    },
    rules: {
      'react-compiler/react-compiler': 'error',
    },
  },
];
```

## Debugging

### Check if Component is Compiled

```tsx
// In React DevTools, compiled components show:
// "This component has been auto-memoized"
```

### Compiler Errors vs Runtime Errors

- **Compiler errors:** Violations of Rules of React (fix the code)
- **Runtime errors:** Logic bugs (unrelated to compiler)

### Common Issues

1. **Mutating props/state:**
   ```tsx
   // Bad - compiler can't optimize
   function Bad({ items }) {
     items.push(newItem); // Mutation!
   }

   // Good
   function Good({ items }) {
     const newItems = [...items, newItem]; // New array
   }
   ```

2. **Side effects in render:**
   ```tsx
   // Bad
   function Bad({ id }) {
     fetch(`/api/${id}`); // Side effect in render
   }

   // Good
   function Good({ id }) {
     useEffect(() => {
       fetch(`/api/${id}`);
     }, [id]);
   }
   ```

## Performance Focus

React Compiler optimizes **update performance** (re-renders), not initial render:

- **Cascading re-renders:** Parent state change doesn't re-render unaffected children
- **Expensive calculations:** Only recalculated when dependencies change

For initial render performance, consider:
- Code splitting
- Lazy loading
- Server Components
