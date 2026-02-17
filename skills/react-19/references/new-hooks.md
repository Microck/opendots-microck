# React 19 New Hooks

Complete API reference for hooks introduced in React 19.

## useActionState

Manages form state with async actions, providing pending state and error handling.

```tsx
import { useActionState } from 'react';

const [state, formAction, isPending] = useActionState(action, initialState, permalink?);
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `action` | `(prevState, formData) => newState` | Async function called on form submit |
| `initialState` | `any` | Initial state value |
| `permalink` | `string` (optional) | URL for progressive enhancement |

### Returns

| Value | Type | Description |
|-------|------|-------------|
| `state` | `any` | Current state (last return value from action) |
| `formAction` | `function` | Action to pass to `<form action={}>` |
| `isPending` | `boolean` | `true` while action is executing |

### Complete Example

```tsx
'use client';
import { useActionState } from 'react';
import { updateUser } from './actions';

interface FormState {
  error: string | null;
  success: boolean;
}

function ProfileForm({ userId }: { userId: string }) {
  const [state, formAction, isPending] = useActionState<FormState, FormData>(
    async (prevState, formData) => {
      try {
        await updateUser(userId, {
          name: formData.get('name') as string,
          email: formData.get('email') as string,
        });
        return { error: null, success: true };
      } catch (e) {
        return { error: (e as Error).message, success: false };
      }
    },
    { error: null, success: false }
  );

  return (
    <form action={formAction}>
      <input name="name" disabled={isPending} />
      <input name="email" type="email" disabled={isPending} />

      <button type="submit" disabled={isPending}>
        {isPending ? 'Saving...' : 'Save'}
      </button>

      {state.error && <p className="error">{state.error}</p>}
      {state.success && <p className="success">Saved!</p>}
    </form>
  );
}
```

### With Server Actions

```tsx
// actions.ts
'use server';

export async function createPost(prevState: any, formData: FormData) {
  const title = formData.get('title') as string;

  if (!title) {
    return { error: 'Title is required' };
  }

  await db.posts.create({ title });
  revalidatePath('/posts');
  return { error: null };
}

// component.tsx
'use client';
import { useActionState } from 'react';
import { createPost } from './actions';

function NewPostForm() {
  const [state, formAction, isPending] = useActionState(createPost, { error: null });

  return (
    <form action={formAction}>
      <input name="title" />
      <button disabled={isPending}>Create</button>
      {state.error && <span>{state.error}</span>}
    </form>
  );
}
```

### Progressive Enhancement

With `permalink`, forms work before JavaScript loads:

```tsx
const [state, formAction] = useActionState(
  serverAction,
  initialState,
  '/api/submit' // Fallback URL for no-JS
);
```

---

## useOptimistic

Shows optimistic UI updates that revert on error.

```tsx
import { useOptimistic } from 'react';

const [optimisticState, addOptimistic] = useOptimistic(state, updateFn);
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `state` | `T` | Current actual state |
| `updateFn` | `(currentState, optimisticValue) => newState` | Produces optimistic state |

### Returns

| Value | Type | Description |
|-------|------|-------------|
| `optimisticState` | `T` | Current state (optimistic during action, actual otherwise) |
| `addOptimistic` | `(optimisticValue) => void` | Trigger optimistic update |

### Complete Example

```tsx
import { useOptimistic, useTransition } from 'react';

interface Todo {
  id: string;
  text: string;
  completed: boolean;
  pending?: boolean;
}

function TodoList({ todos, toggleTodo }: {
  todos: Todo[];
  toggleTodo: (id: string) => Promise<void>;
}) {
  const [isPending, startTransition] = useTransition();

  const [optimisticTodos, addOptimisticTodo] = useOptimistic(
    todos,
    (state, { id, completed }: { id: string; completed: boolean }) =>
      state.map(todo =>
        todo.id === id
          ? { ...todo, completed, pending: true }
          : todo
      )
  );

  async function handleToggle(id: string, currentCompleted: boolean) {
    addOptimisticTodo({ id, completed: !currentCompleted });
    startTransition(async () => {
      await toggleTodo(id); // On error, optimistic state reverts
    });
  }

  return (
    <ul>
      {optimisticTodos.map(todo => (
        <li
          key={todo.id}
          style={{ opacity: todo.pending ? 0.6 : 1 }}
        >
          <input
            type="checkbox"
            checked={todo.completed}
            onChange={() => handleToggle(todo.id, todo.completed)}
            disabled={todo.pending}
          />
          {todo.text}
        </li>
      ))}
    </ul>
  );
}
```

### With Form Actions

```tsx
function LikeButton({ postId, initialLikes }: { postId: string; initialLikes: number }) {
  const [optimisticLikes, addOptimisticLike] = useOptimistic(
    initialLikes,
    (current, increment: number) => current + increment
  );

  async function handleLike(formData: FormData) {
    addOptimisticLike(1);
    await likePost(postId); // Reverts on error
  }

  return (
    <form action={handleLike}>
      <button type="submit">{optimisticLikes} Likes</button>
    </form>
  );
}
```

---

## use

Reads resources (promises, context) during render. Can be called conditionally.

```tsx
import { use } from 'react';

const value = use(resource);
```

### With Promises

```tsx
import { use, Suspense } from 'react';

// Promise must be created outside render (cached)
async function fetchUser(id: string) {
  const res = await fetch(`/api/users/${id}`);
  return res.json();
}

function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise); // Suspends until resolved

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}

// Parent component
function UserPage({ userId }: { userId: string }) {
  // Create promise at this level, not inside UserProfile
  const userPromise = fetchUser(userId);

  return (
    <Suspense fallback={<Skeleton />}>
      <UserProfile userPromise={userPromise} />
    </Suspense>
  );
}
```

### With Context (Conditional)

```tsx
import { use, createContext } from 'react';

const ThemeContext = createContext<'light' | 'dark'>('light');

function ConditionalTheme({ showTheme }: { showTheme: boolean }) {
  // useContext cannot be called conditionally - use() can!
  if (!showTheme) {
    return <div>No theme</div>;
  }

  const theme = use(ThemeContext);
  return <div className={theme}>Themed content</div>;
}
```

### Key Differences from useContext

| Feature | useContext | use |
|---------|------------|-----|
| Conditional calling | Not allowed | Allowed |
| After early returns | Not allowed | Allowed |
| In loops | Not allowed | Allowed (same context) |
| With promises | Not supported | Supported (suspends) |

### Important Rules

```tsx
// Promises must be cached/stable - NOT created in render
function Bad({ id }) {
  const data = use(fetch(`/api/${id}`)); // Creates new promise each render
}

function Good({ id }) {
  const dataPromise = useMemo(() => fetchData(id), [id]);
  const data = use(dataPromise); // Stable promise reference
}

// Better: Create promise in parent
function Parent({ id }) {
  const promise = fetchData(id); // Created once per render cycle
  return (
    <Suspense fallback={<Loading />}>
      <Child dataPromise={promise} />
    </Suspense>
  );
}
```

---

## useFormStatus

Reads status of parent `<form>` element. Must be rendered inside a form.

```tsx
import { useFormStatus } from 'react-dom';

const { pending, data, method, action } = useFormStatus();
```

### Returns

| Value | Type | Description |
|-------|------|-------------|
| `pending` | `boolean` | `true` while form is submitting |
| `data` | `FormData \| null` | Form data being submitted |
| `method` | `string` | HTTP method (`'get'` or `'post'`) |
| `action` | `function \| string \| null` | Action function or URL |

### Complete Example

```tsx
import { useFormStatus } from 'react-dom';

function SubmitButton({ children }: { children: React.ReactNode }) {
  const { pending } = useFormStatus();

  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Submitting...' : children}
    </button>
  );
}

function FormProgress() {
  const { pending, data } = useFormStatus();

  if (!pending) return null;

  return (
    <div className="progress">
      Submitting {data?.get('email')}...
    </div>
  );
}

function ContactForm() {
  async function handleSubmit(formData: FormData) {
    'use server';
    await sendEmail(formData);
  }

  return (
    <form action={handleSubmit}>
      <input name="email" type="email" required />
      <textarea name="message" required />
      <FormProgress />
      <SubmitButton>Send Message</SubmitButton>
    </form>
  );
}
```

### Common Pattern: Reusable Submit Button

```tsx
// components/SubmitButton.tsx
'use client';
import { useFormStatus } from 'react-dom';
import { ButtonHTMLAttributes } from 'react';

interface Props extends ButtonHTMLAttributes<HTMLButtonElement> {
  pendingText?: string;
}

export function SubmitButton({
  children,
  pendingText = 'Submitting...',
  ...props
}: Props) {
  const { pending } = useFormStatus();

  return (
    <button type="submit" disabled={pending} {...props}>
      {pending ? pendingText : children}
    </button>
  );
}
```

### Important: Must Be Inside Form

```tsx
// This will NOT work - useFormStatus is outside the form
function BadExample() {
  const { pending } = useFormStatus(); // Always returns { pending: false }!

  return (
    <form action={action}>
      <button disabled={pending}>Submit</button>
    </form>
  );
}

// This works - component using useFormStatus is inside form
function GoodExample() {
  return (
    <form action={action}>
      <StatusAwareButton /> {/* useFormStatus called inside */}
    </form>
  );
}
```

---

## useDeferredValue (Updated)

React 19 adds `initialValue` parameter for better UX during initial render.

```tsx
import { useDeferredValue } from 'react';

// New in React 19: initialValue parameter
const deferredValue = useDeferredValue(value, initialValue);
```

### New initialValue Parameter

```tsx
function SearchResults({ query }: { query: string }) {
  // First render: returns '' (initial)
  // Subsequent: returns deferred query
  const deferredQuery = useDeferredValue(query, '');

  return (
    <Suspense fallback={<Skeleton />}>
      <Results query={deferredQuery} />
    </Suspense>
  );
}
```

### Comparison

```tsx
// React 18: No initial value, shows stale content first
const deferred = useDeferredValue(value);

// React 19: Can show placeholder on first render
const deferred = useDeferredValue(value, placeholder);
```
