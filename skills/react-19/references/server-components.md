# React Server Components & Server Actions

React 19 stabilizes Server Components and Server Actions/Functions.

## Server Components

Components that run **only on the server** - never shipped to the client.

### Characteristics

| Feature | Server Component | Client Component |
|---------|-----------------|------------------|
| Runs on | Server only | Server (SSR) + Client |
| Bundle size | Zero JS sent | JS sent to client |
| Can use | async/await, fs, db | useState, useEffect, events |
| Default in | App Router (Next.js) | Must add `'use client'` |

### Basic Pattern

```tsx
// Server Component (default) - no directive needed
// Can be async, access database, file system directly
export default async function ProductPage({ params }) {
  const product = await db.products.find(params.id);
  const reviews = await db.reviews.findMany({ productId: params.id });

  return (
    <main>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      {/* Client component for interactivity */}
      <AddToCartButton productId={product.id} />
      <ReviewList reviews={reviews} />
    </main>
  );
}

// Client Component - needs directive
'use client';

export function AddToCartButton({ productId }) {
  const [isPending, setIsPending] = useState(false);

  return (
    <button
      onClick={() => addToCart(productId)}
      disabled={isPending}
    >
      Add to Cart
    </button>
  );
}
```

### Data Fetching

```tsx
// Server Component - fetch directly, no useEffect needed
async function UserProfile({ userId }) {
  // This runs on the server
  const user = await fetch(`https://api.example.com/users/${userId}`);
  const posts = await fetch(`https://api.example.com/users/${userId}/posts`);

  return (
    <div>
      <h1>{user.name}</h1>
      <PostList posts={posts} />
    </div>
  );
}

// Parallel data fetching
async function Dashboard() {
  // Fetch in parallel
  const [user, stats, notifications] = await Promise.all([
    getUser(),
    getStats(),
    getNotifications(),
  ]);

  return (
    <div>
      <UserCard user={user} />
      <StatsPanel stats={stats} />
      <NotificationList notifications={notifications} />
    </div>
  );
}
```

### Composition Pattern

```tsx
// Server Component as layout
async function ProductLayout({ children }) {
  const categories = await getCategories();

  return (
    <div className="layout">
      <Sidebar categories={categories} />
      <main>{children}</main>
    </div>
  );
}

// Pass Server Component as child to Client Component
function ClientWrapper({ children }) {
  'use client';
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div>
      <button onClick={() => setIsOpen(!isOpen)}>Toggle</button>
      {isOpen && children} {/* Server Component passed as children */}
    </div>
  );
}

// Usage
<ClientWrapper>
  <ServerComponent /> {/* Rendered on server, passed to client */}
</ClientWrapper>
```

---

## Server Actions / Server Functions

Functions that run **only on the server**, callable from client.

### Defining Server Actions

```tsx
// Option 1: Inline in Server Component
async function Page() {
  async function createPost(formData: FormData) {
    'use server';
    const title = formData.get('title');
    await db.posts.create({ title });
    revalidatePath('/posts');
  }

  return (
    <form action={createPost}>
      <input name="title" />
      <button type="submit">Create</button>
    </form>
  );
}

// Option 2: Separate file (recommended)
// actions.ts
'use server';

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string;

  if (!title) {
    return { error: 'Title required' };
  }

  await db.posts.create({ title });
  revalidatePath('/posts');
  return { success: true };
}

export async function deletePost(id: string) {
  await db.posts.delete(id);
  revalidatePath('/posts');
}
```

### Using in Client Components

```tsx
'use client';

import { createPost, deletePost } from './actions';
import { useActionState } from 'react';

function PostForm() {
  const [state, formAction, isPending] = useActionState(createPost, null);

  return (
    <form action={formAction}>
      <input name="title" disabled={isPending} />
      <button disabled={isPending}>
        {isPending ? 'Creating...' : 'Create'}
      </button>
      {state?.error && <p className="error">{state.error}</p>}
    </form>
  );
}

function DeleteButton({ postId }) {
  return (
    <form action={() => deletePost(postId)}>
      <button type="submit">Delete</button>
    </form>
  );
}
```

### With useOptimistic

```tsx
'use client';

import { useOptimistic } from 'react';
import { likePost } from './actions';

function LikeButton({ postId, initialLikes }) {
  const [optimisticLikes, addOptimistic] = useOptimistic(
    initialLikes,
    (current, increment: number) => current + increment
  );

  async function handleLike() {
    addOptimistic(1);
    await likePost(postId);
  }

  return (
    <form action={handleLike}>
      <button type="submit">{optimisticLikes} likes</button>
    </form>
  );
}
```

### Non-Form Usage

Server Actions can be called outside forms:

```tsx
'use client';

import { updateTheme } from './actions';

function ThemeToggle() {
  async function handleClick() {
    await updateTheme('dark');
  }

  return <button onClick={handleClick}>Dark Mode</button>;
}
```

### With Transitions

```tsx
'use client';

import { useTransition } from 'react';
import { publishPost } from './actions';

function PublishButton({ postId }) {
  const [isPending, startTransition] = useTransition();

  function handlePublish() {
    startTransition(async () => {
      await publishPost(postId);
    });
  }

  return (
    <button onClick={handlePublish} disabled={isPending}>
      {isPending ? 'Publishing...' : 'Publish'}
    </button>
  );
}
```

---

## Directives

### 'use server'

Marks function as Server Action (runs only on server).

```tsx
// At file level - all exports are server actions
'use server';

export async function action1() { /* ... */ }
export async function action2() { /* ... */ }

// Or inline in component
async function Component() {
  async function serverAction() {
    'use server';
    // Server-only code
  }
}
```

### 'use client'

Marks component boundary as client-side.

```tsx
'use client';

// Everything in this file runs on client
export function InteractiveComponent() {
  const [state, setState] = useState();
  // ...
}
```

### When to Use Each

| Scenario | Directive |
|----------|-----------|
| Database operations | `'use server'` |
| File system access | `'use server'` |
| API keys/secrets | `'use server'` |
| useState, useEffect | `'use client'` |
| Event handlers (onClick) | `'use client'` |
| Browser APIs | `'use client'` |
| Static UI without interactivity | None (Server Component) |

---

## Static Site Generation

New APIs for static rendering:

```tsx
import { prerender } from 'react-dom/static';

// Generate static HTML
async function generateStaticPage() {
  const { prelude } = await prerender(<App />, {
    bootstrapScripts: ['/main.js'],
  });

  return new Response(prelude, {
    headers: { 'content-type': 'text/html' },
  });
}

// With Node.js streams
import { prerenderToNodeStream } from 'react-dom/static';

async function handler(req, res) {
  const { prelude } = await prerenderToNodeStream(<App />, {
    bootstrapScripts: ['/main.js'],
  });

  res.setHeader('content-type', 'text/html');
  prelude.pipe(res);
}
```

---

## Best Practices

### 1. Keep Server Components as Default

```tsx
// Good: Server Component for data fetching
async function ProductPage({ id }) {
  const product = await getProduct(id);
  return (
    <div>
      <h1>{product.name}</h1>
      <InteractivePrice price={product.price} /> {/* Only this is client */}
    </div>
  );
}
```

### 2. Minimize Client Boundary

```tsx
// Bad: Entire page is client
'use client';
export default function Page() { /* ... */ }

// Good: Only interactive part is client
export default async function Page() {
  const data = await getData();
  return (
    <div>
      <StaticContent data={data} />
      <InteractivePart /> {/* 'use client' inside */}
    </div>
  );
}
```

### 3. Colocate Server Actions

```tsx
// actions/posts.ts
'use server';

export async function createPost(formData: FormData) { /* ... */ }
export async function updatePost(id: string, formData: FormData) { /* ... */ }
export async function deletePost(id: string) { /* ... */ }
```

### 4. Error Handling

```tsx
'use server';

export async function createUser(formData: FormData) {
  try {
    const user = await db.users.create({
      email: formData.get('email'),
    });
    revalidatePath('/users');
    return { success: true, user };
  } catch (error) {
    if (error.code === 'UNIQUE_VIOLATION') {
      return { error: 'Email already exists' };
    }
    return { error: 'Failed to create user' };
  }
}
```

### 5. Type Safety

```tsx
'use server';

interface ActionResult {
  success?: boolean;
  error?: string;
  data?: User;
}

export async function createUser(
  prevState: ActionResult | null,
  formData: FormData
): Promise<ActionResult> {
  const email = formData.get('email') as string;

  if (!email) {
    return { error: 'Email is required' };
  }

  const user = await db.users.create({ email });
  return { success: true, data: user };
}
```
