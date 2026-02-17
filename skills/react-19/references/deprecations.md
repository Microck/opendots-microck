# React 19 Deprecations & Removed APIs

Complete guide to deprecated and removed features with migration paths.

## Deprecations (Future Removal)

These APIs still work in React 19 but will be removed in a future version.

### forwardRef

**Status:** Deprecated - use `ref` as prop instead

```tsx
// React 18: Required forwardRef wrapper
import { forwardRef } from 'react';

const Input = forwardRef<HTMLInputElement, InputProps>((props, ref) => {
  return <input ref={ref} {...props} />;
});

// React 19: ref is just a prop
function Input({ ref, ...props }: InputProps & { ref?: React.Ref<HTMLInputElement> }) {
  return <input ref={ref} {...props} />;
}

// Usage unchanged
<Input ref={inputRef} placeholder="Enter text" />
```

**Codemod:**
```bash
npx codemod@latest react/19/replace-forward-ref
```

### Context.Provider

**Status:** Deprecated - use Context directly as provider

```tsx
const ThemeContext = createContext('light');

// React 18: Required .Provider
<ThemeContext.Provider value="dark">
  {children}
</ThemeContext.Provider>

// React 19: Context is the provider
<ThemeContext value="dark">
  {children}
</ThemeContext>
```

### element.ref Access

**Status:** Deprecated - use `element.props.ref` instead

```tsx
// React 18
const ref = element.ref;

// React 19
const ref = element.props.ref;
```

### react-test-renderer

**Status:** Deprecated - migrate to Testing Library

```tsx
// Deprecated
import TestRenderer from 'react-test-renderer';

// Recommended
import { render, screen } from '@testing-library/react';
```

### ReactDOM.useFormState

**Status:** Renamed to `useActionState` (moved to `react`)

```tsx
// React 18 (react-dom)
import { useFormState } from 'react-dom';

// React 19 (react)
import { useActionState } from 'react';
```

---

## Removed APIs (Breaking Changes)

These APIs no longer exist in React 19 and will throw errors.

### ReactDOM.render / ReactDOM.hydrate

**Removed in:** React 19
**Deprecated in:** React 18.0 (March 2022)

```tsx
// Removed
import { render, hydrate } from 'react-dom';

render(<App />, document.getElementById('root'));
hydrate(<App />, document.getElementById('root'));

// Migration
import { createRoot, hydrateRoot } from 'react-dom/client';

// Client rendering
const root = createRoot(document.getElementById('root')!);
root.render(<App />);

// Hydration (SSR)
hydrateRoot(document.getElementById('root')!, <App />);
```

**Codemod:**
```bash
npx codemod@latest react/19/replace-reactdom-render
```

### unmountComponentAtNode

**Removed in:** React 19

```tsx
// Removed
import { unmountComponentAtNode } from 'react-dom';
unmountComponentAtNode(document.getElementById('root'));

// Migration
const root = createRoot(document.getElementById('root')!);
root.render(<App />);
// Later:
root.unmount();
```

### ReactDOM.findDOMNode

**Removed in:** React 19
**Deprecated in:** React 16.6 (October 2018)

```tsx
// Removed
import { findDOMNode } from 'react-dom';

class MyComponent extends Component {
  componentDidMount() {
    const node = findDOMNode(this);
    node.scrollIntoView();
  }
}

// Migration: Use refs
function MyComponent() {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    ref.current?.scrollIntoView();
  }, []);

  return <div ref={ref}>Content</div>;
}
```

### String Refs

**Removed in:** React 19
**Deprecated in:** React 16.3 (March 2018)

```tsx
// Removed
class MyComponent extends Component {
  componentDidMount() {
    this.refs.input.focus();
  }
  render() {
    return <input ref="input" />;
  }
}

// Migration: Callback refs or useRef
class MyComponent extends Component {
  input: HTMLInputElement | null = null;

  componentDidMount() {
    this.input?.focus();
  }
  render() {
    return <input ref={el => this.input = el} />;
  }
}

// Or with hooks
function MyComponent() {
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  return <input ref={inputRef} />;
}
```

**Codemod:**
```bash
npx codemod@latest react/19/replace-string-ref
```

### Legacy Context (contextTypes, getChildContext)

**Removed in:** React 19
**Deprecated in:** React 16.6 (October 2018)

```tsx
// Removed
import PropTypes from 'prop-types';

class Parent extends Component {
  static childContextTypes = {
    theme: PropTypes.string,
  };
  getChildContext() {
    return { theme: 'dark' };
  }
  render() {
    return <Child />;
  }
}

class Child extends Component {
  static contextTypes = {
    theme: PropTypes.string,
  };
  render() {
    return <div>{this.context.theme}</div>;
  }
}

// Migration: createContext
const ThemeContext = createContext('light');

function Parent() {
  return (
    <ThemeContext value="dark">
      <Child />
    </ThemeContext>
  );
}

function Child() {
  const theme = useContext(ThemeContext);
  return <div>{theme}</div>;
}
```

### propTypes

**Removed in:** React 19 (silently ignored)

```tsx
// No longer works (silently ignored)
import PropTypes from 'prop-types';

function Button({ label }) {
  return <button>{label}</button>;
}

Button.propTypes = {
  label: PropTypes.string.isRequired,
};

// Migration: TypeScript
interface ButtonProps {
  label: string;
}

function Button({ label }: ButtonProps) {
  return <button>{label}</button>;
}
```

**Codemod:**
```bash
npx codemod@latest react/prop-types-typescript
```

### defaultProps (Function Components)

**Removed in:** React 19 (for function components only)
**Note:** Class components still support `defaultProps`

```tsx
// Removed for function components
function Button({ size }) {
  return <button className={size}>Click</button>;
}
Button.defaultProps = {
  size: 'medium',
};

// Migration: ES6 default parameters
function Button({ size = 'medium' }) {
  return <button className={size}>Click</button>;
}

// TypeScript
interface ButtonProps {
  size?: 'small' | 'medium' | 'large';
}

function Button({ size = 'medium' }: ButtonProps) {
  return <button className={size}>Click</button>;
}

// Class components still work
class Button extends Component {
  static defaultProps = { size: 'medium' }; // Still supported
}
```

### React.createFactory

**Removed in:** React 19
**Deprecated in:** React 16.13 (February 2020)

```tsx
// Removed
import { createFactory } from 'react';

const div = createFactory('div');
const element = div({ className: 'box' }, 'Hello');

// Migration: JSX
const element = <div className="box">Hello</div>;

// Or createElement
import { createElement } from 'react';
const element = createElement('div', { className: 'box' }, 'Hello');
```

### Module Pattern Factories

**Removed in:** React 19
**Deprecated in:** React 16.9 (August 2019)

```tsx
// Removed
function FactoryComponent() {
  return {
    render() {
      return <div>Hello</div>;
    }
  };
}

// Migration: Regular component
function Component() {
  return <div>Hello</div>;
}
```

### react-dom/test-utils

**Removed in:** React 19

```tsx
// Removed
import { act } from 'react-dom/test-utils';

// Migration: Import from react
import { act } from 'react';
```

**Codemod:**
```bash
npx codemod@latest react/19/replace-act-import
```

### react-test-renderer/shallow

**Removed in:** React 19

```bash
# If you still need shallow rendering
npm install react-shallow-renderer --save-dev
```

```tsx
// Changed import
import ShallowRenderer from 'react-shallow-renderer';
```

**Recommendation:** Migrate to `@testing-library/react`

### UMD Builds

**Removed in:** React 19

```html
<!-- Removed -->
<script src="https://unpkg.com/react@19/umd/react.production.min.js"></script>

<!-- Migration: ESM -->
<script type="module">
  import React from 'https://esm.sh/react@19';
  import ReactDOM from 'https://esm.sh/react-dom@19/client';
</script>
```

---

## Removed Unstable APIs

| API | Status |
|-----|--------|
| `unstable_flushControlled` | Removed |
| `unstable_createEventHandle` | Removed |
| `unstable_renderSubtreeIntoContainer` | Removed |
| `unstable_runWithPriority` | Removed |

---

## Pre-Upgrade Checklist

1. **Upgrade to React 18.3 first** - Shows deprecation warnings for removed APIs
2. **Run codemods:**
   ```bash
   npx codemod@latest react/19/migration-recipe
   ```
3. **Fix TypeScript errors:**
   ```bash
   npx types-react-codemod@latest preset-19 ./src
   ```
4. **Test thoroughly** - Especially error handling and hydration
