# React 19 TypeScript Changes

Breaking changes to `@types/react` and `@types/react-dom` with migration paths.

## Installation

```bash
npm install --save-exact @types/react@^19.0.0 @types/react-dom@^19.0.0
```

## Codemods

Run all TypeScript codemods at once:

```bash
npx types-react-codemod@latest preset-19 ./src
```

Individual codemods:

```bash
# Ref callback returns
npx types-react-codemod@latest no-implicit-ref-callback-return ./src

# useRef argument
npx types-react-codemod@latest refobject-defaults ./src

# ReactElement props
npx types-react-codemod@latest react-element-default-any-props ./src

# JSX namespace
npx types-react-codemod@latest scoped-jsx ./src
```

---

## Breaking Changes

### 1. Ref Callback Return Values

Ref callbacks must not return values (except cleanup functions).

```tsx
// React 18: Worked (but buggy pattern)
<div ref={current => (instance = current)} />

// React 19: TypeScript error - implicit return
<div ref={current => (instance = current)} />
//                   ^^^^^^^^^^^^^^^^^^^^ Error

// Fix: Use block body
<div ref={current => { instance = current; }} />

// Cleanup functions ARE allowed
<div ref={current => {
  // setup
  return () => { /* cleanup */ };
}} />
```

### 2. useRef Requires Argument

```tsx
// React 18: Worked
const ref = useRef<HTMLDivElement>();
ref.current // HTMLDivElement | undefined

// React 19: Error - argument required
const ref = useRef<HTMLDivElement>(); // Error!

// Fix: Provide initial value
const ref = useRef<HTMLDivElement>(null);
ref.current // HTMLDivElement | null

// Or use undefined explicitly
const ref = useRef<HTMLDivElement | undefined>(undefined);
```

### 3. Refs Are Mutable by Default

```tsx
// React 18: RefObject was read-only for non-null initial
const ref = useRef<number>(0);
ref.current = 1; // Error in React 18

// React 19: All refs are mutable
const ref = useRef<number>(0);
ref.current = 1; // OK

// Type is now consistently RefObject<T>
// (MutableRefObject removed)
```

### 4. ReactElement Props Default to `unknown`

```tsx
// React 18
type Props = ReactElement['props']; // any

// React 19
type Props = ReactElement['props']; // unknown

// Fix: Specify props type
type Props = ReactElement<{ id: string }>['props']; // { id: string }

// Or handle unknown
function processElement(element: ReactElement) {
  const props = element.props as { id?: string };
  // ...
}
```

### 5. Global JSX Namespace Removed

```tsx
// React 18: Global namespace
declare global {
  namespace JSX {
    interface IntrinsicElements {
      'my-element': { myProp: string };
    }
  }
}

// React 19: Module scoped
declare module 'react' {
  namespace JSX {
    interface IntrinsicElements {
      'my-element': { myProp: string };
    }
  }
}
```

Module depends on `tsconfig.json`:

| jsx setting | Module to augment |
|-------------|-------------------|
| `react-jsx` | `react/jsx-runtime` |
| `react-jsxdev` | `react/jsx-dev-runtime` |
| `react` or `preserve` | `react` |

### 6. useReducer Typing

```tsx
// React 18: Explicit Reducer type
useReducer<React.Reducer<State, Action>>(reducer, initialState);

// React 19: Rely on inference (recommended)
useReducer(reducer, initialState);

// Or new tuple syntax
useReducer<State, [Action]>(reducer, initialState);

// Or annotate function
useReducer((state: State, action: Action) => state, initialState);
```

---

## Removed Types

These types no longer exist in `@types/react@19`:

| Removed Type | Migration |
|--------------|-----------|
| `ReactChild` | `ReactElement \| number \| string` |
| `ReactFragment` | `Iterable<ReactNode>` |
| `ReactNodeArray` | `ReadonlyArray<ReactNode>` |
| `ReactText` | `number \| string` |
| `VoidFunctionComponent` | `FunctionComponent` |
| `VFC` | `FC` |
| `StatelessComponent` | `FunctionComponent` |
| `SFC` | `FC` |

```tsx
// Before
import { ReactChild, VFC } from 'react';

const MyComponent: VFC<Props> = (props) => { /* ... */ };
function render(child: ReactChild) { /* ... */ }

// After
import { FC, ReactElement } from 'react';

const MyComponent: FC<Props> = (props) => { /* ... */ };
function render(child: ReactElement | number | string) { /* ... */ }
```

---

## Moved Types

### PropTypes Related

```bash
npm install prop-types
```

```tsx
// Before (from react)
import { Requireable, Validator } from 'react';

// After (from prop-types)
import { Requireable, Validator } from 'prop-types';
```

### Class Component Types

```bash
npm install create-react-class
```

```tsx
// Before (from react)
import { ComponentSpec, Mixin } from 'react';

// After (from create-react-class)
import { ComponentSpec, Mixin } from 'create-react-class';
```

---

## New Patterns

### Typing ref as Prop

```tsx
// React 19: ref is just a prop
interface InputProps {
  placeholder?: string;
  ref?: React.Ref<HTMLInputElement>;
}

function Input({ placeholder, ref }: InputProps) {
  return <input placeholder={placeholder} ref={ref} />;
}

// Or with ComponentProps
type InputProps = React.ComponentProps<'input'>;

function Input(props: InputProps) {
  return <input {...props} />;
}
```

### Typing useActionState

```tsx
import { useActionState } from 'react';

interface FormState {
  error: string | null;
  success: boolean;
}

function Form() {
  const [state, formAction, isPending] = useActionState<FormState, FormData>(
    async (prevState, formData) => {
      // prevState is FormState
      // formData is FormData
      // must return FormState
      return { error: null, success: true };
    },
    { error: null, success: false }
  );

  // state: FormState
  // formAction: (formData: FormData) => void
  // isPending: boolean
}
```

### Typing useOptimistic

```tsx
import { useOptimistic } from 'react';

interface Message {
  id: string;
  text: string;
  pending?: boolean;
}

function Messages({ messages }: { messages: Message[] }) {
  const [optimistic, addOptimistic] = useOptimistic<
    Message[],
    Omit<Message, 'pending'>
  >(
    messages,
    (state, newMessage) => [
      ...state,
      { ...newMessage, pending: true }
    ]
  );
}
```

### Typing use()

```tsx
import { use } from 'react';

// With Promise
function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise); // user: User
  return <div>{user.name}</div>;
}

// With Context
const ThemeContext = createContext<'light' | 'dark'>('light');

function ThemedComponent() {
  const theme = use(ThemeContext); // theme: 'light' | 'dark'
  return <div className={theme}>...</div>;
}
```

### Typing Server Actions

```tsx
// actions.ts
'use server';

interface ActionResult<T> {
  data?: T;
  error?: string;
}

export async function createUser(
  prevState: ActionResult<User> | null,
  formData: FormData
): Promise<ActionResult<User>> {
  const name = formData.get('name') as string;

  if (!name) {
    return { error: 'Name required' };
  }

  const user = await db.users.create({ name });
  return { data: user };
}
```

---

## JSX Import

```tsx
// React 18: Could use global JSX
const element: JSX.Element = <div />;

// React 19: Import explicitly
import type { JSX } from 'react';

const element: JSX.Element = <div />;

// Or use ReactElement
import type { ReactElement } from 'react';

const element: ReactElement = <div />;
```

---

## Quick Migration Checklist

- [ ] Update `@types/react` and `@types/react-dom` to ^19.0.0
- [ ] Run `npx types-react-codemod@latest preset-19 ./src`
- [ ] Fix ref callback implicit returns: `=> (x = y)` → `=> { x = y; }`
- [ ] Add arguments to `useRef()` calls
- [ ] Replace removed types (`ReactChild`, `VFC`, etc.)
- [ ] Update JSX namespace augmentations to module scope
- [ ] Import `JSX` type from `'react'` if used
- [ ] Update `ReactElement` prop access to handle `unknown`
