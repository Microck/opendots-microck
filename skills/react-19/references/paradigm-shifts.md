# React 19 Paradigm Shifts

How to **think** in React 19. These are fundamental mental model changes, not just new APIs.

## 1. Server-First Thinking

### The Old Model (React 18 and before)
Everything runs on the client. Server rendering (SSR) is an optimization that pre-renders HTML, but the same code runs everywhere.

```tsx
// Old: Everything is a "component" that might run anywhere
function ProductPage({ productId }) {
  const [product, setProduct] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(`/api/products/${productId}`)
      .then(res => res.json())
      .then(data => {
        setProduct(data);
        setLoading(false);
      });
  }, [productId]);

  if (loading) return <Skeleton />;
  return <ProductDetails product={product} />;
}
```

### The New Model (React 19)
**Server is the default.** Components run on the server unless they need client interactivity. Client components are the exception, not the rule.

```tsx
// New: Server Component (default) - runs only on server
async function ProductPage({ productId }) {
  // Direct database/API access - no useEffect, no loading state
  const product = await db.products.find(productId);

  return (
    <div>
      <ProductDetails product={product} />
      <AddToCartButton productId={productId} /> {/* Client island */}
    </div>
  );
}

// Client Component - only what needs interactivity
'use client';
function AddToCartButton({ productId }) {
  const [isPending, startTransition] = useTransition();
  // Client-side logic here
}
```

### Key Insight
**Ask "why does this need to be on the client?" instead of "should I server-render this?"**

| Need | Solution |
|------|----------|
| Fetch data | Server Component (async/await) |
| Database access | Server Component |
| API keys/secrets | Server Component |
| Static UI | Server Component |
| onClick, onChange | Client Component |
| useState, useEffect | Client Component |
| Browser APIs | Client Component |

---

## 2. Compiler-First Optimization

### The Old Model
Performance optimization is the developer's responsibility. You must manually identify and memoize expensive operations.

```tsx
// Old: Developer manages all memoization
const MemoizedChild = memo(Child);

function Parent({ items, onSelect }) {
  // Must manually memoize
  const processed = useMemo(() =>
    items.filter(x => x.active).sort(byName),
    [items]
  );

  // Must manually memoize
  const handleSelect = useCallback((id) => {
    onSelect(id);
  }, [onSelect]);

  return <MemoizedChild items={processed} onSelect={handleSelect} />;
}
```

### The New Model
**The compiler understands your code.** It automatically applies memoization where beneficial. Your job is to write correct, readable code.

```tsx
// New: Write naturally, compiler optimizes
function Parent({ items, onSelect }) {
  const processed = items.filter(x => x.active).sort(byName);

  const handleSelect = (id) => {
    onSelect(id);
  };

  return <Child items={processed} onSelect={handleSelect} />;
}
```

### Key Insight
**Stop thinking about memoization. Start thinking about correctness.**

The compiler optimizes based on data flow analysis. Your responsibility shifts to:
- Following the Rules of React (purity, immutability)
- Writing clear, predictable code
- Using escape hatches (`useMemo`) only for specific control needs

---

## 3. Declarative Mutations (Actions)

### The Old Model
Mutations are imperative. You manually orchestrate loading states, error handling, form resets, and optimistic updates.

```tsx
// Old: Imperative mutation handling
function CommentForm({ postId }) {
  const [text, setText] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState(null);

  async function handleSubmit(e) {
    e.preventDefault();
    setIsSubmitting(true);
    setError(null);

    try {
      await submitComment(postId, text);
      setText(''); // Manual reset
    } catch (err) {
      setError(err.message);
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <textarea
        value={text}
        onChange={e => setText(e.target.value)}
        disabled={isSubmitting}
      />
      <button disabled={isSubmitting}>
        {isSubmitting ? 'Posting...' : 'Post'}
      </button>
      {error && <p className="error">{error}</p>}
    </form>
  );
}
```

### The New Model
**Mutations are declarative.** You describe what should happen, React handles the orchestration.

```tsx
// New: Declarative with Actions
function CommentForm({ postId }) {
  const [state, formAction, isPending] = useActionState(
    async (prevState, formData) => {
      const text = formData.get('text');
      const error = await submitComment(postId, text);
      if (error) return { error };
      return { error: null }; // Form auto-resets on success
    },
    { error: null }
  );

  return (
    <form action={formAction}>
      <textarea name="text" disabled={isPending} />
      <button disabled={isPending}>
        {isPending ? 'Posting...' : 'Post'}
      </button>
      {state.error && <p className="error">{state.error}</p>}
    </form>
  );
}
```

### Key Insight
**Think in terms of "what happens" not "how to make it happen".**

| Old (Imperative) | New (Declarative) |
|------------------|-------------------|
| `setIsLoading(true)` | `isPending` from hook |
| `try/catch` + `setError` | Return error from action |
| `e.preventDefault()` | Form action handles it |
| Manual `setText('')` | Auto-reset on success |
| `onChange` + `useState` | Native `FormData` |

---

## 4. Streaming Over Loading States

### The Old Model
Loading is binary. Content is either loading or loaded. You manage loading states explicitly.

```tsx
// Old: Binary loading states
function Dashboard() {
  const [user, setUser] = useState(null);
  const [posts, setPosts] = useState(null);
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([fetchUser(), fetchPosts(), fetchStats()])
      .then(([user, posts, stats]) => {
        setUser(user);
        setPosts(posts);
        setStats(stats);
        setLoading(false);
      });
  }, []);

  if (loading) return <FullPageSpinner />;

  return (
    <div>
      <UserCard user={user} />
      <PostList posts={posts} />
      <StatsPanel stats={stats} />
    </div>
  );
}
```

### The New Model
**Content streams in progressively.** Each piece of UI appears as soon as its data is ready. No "all or nothing" loading.

```tsx
// New: Progressive streaming with Suspense
function Dashboard() {
  return (
    <div>
      <Suspense fallback={<UserCardSkeleton />}>
        <UserCard /> {/* Appears when user data ready */}
      </Suspense>

      <Suspense fallback={<PostListSkeleton />}>
        <PostList /> {/* Appears when posts ready */}
      </Suspense>

      <Suspense fallback={<StatsSkeleton />}>
        <StatsPanel /> {/* Appears when stats ready */}
      </Suspense>
    </div>
  );
}

// Each component fetches independently
async function UserCard() {
  const user = await getUser();
  return <div>{user.name}</div>;
}
```

### Key Insight
**Design for progressive disclosure, not loading screens.**

Users see useful content immediately. Slow data doesn't block fast data.

---

## 5. Colocation Over Separation

### The Old Model
Separation of concerns by file type. Data fetching, mutations, and rendering live in different places.

```
/components
  ProductCard.tsx       # Just renders
/hooks
  useProduct.ts         # Fetches data
/api
  products.ts           # API calls
/actions
  productActions.ts     # Mutations
```

### The New Model
**Colocate by feature.** Data fetching, mutations, and rendering live together when they're used together.

```tsx
// Everything for this feature in one place
// products/ProductCard.tsx

// Server Action - colocated
async function addToCart(productId: string) {
  'use server';
  await db.cart.add(productId);
  revalidatePath('/cart');
}

// Server Component - fetches its own data
export async function ProductCard({ productId }) {
  const product = await db.products.find(productId);

  return (
    <div>
      <h2>{product.name}</h2>
      <p>{product.price}</p>
      <form action={addToCart.bind(null, productId)}>
        <button>Add to Cart</button>
      </form>
    </div>
  );
}
```

### Key Insight
**The component IS the API.** Server Components blur the line between frontend and backend.

---

## 6. Progressive Enhancement Default

### The Old Model
JavaScript is required. Forms don't work without JS. You build for JS-enabled browsers first.

### The New Model
**Works without JS, enhanced with JS.** Form actions submit to the server even before hydration.

```tsx
// Works before JavaScript loads
<form action={serverAction}>
  <input name="email" />
  <button>Subscribe</button>
</form>

// After hydration: instant feedback, no page reload
// Before hydration: traditional form submission, still works
```

### Key Insight
**Build for resilience.** Your app should function (at minimum) without JavaScript, then enhance progressively.

---

## Summary: The React 19 Mindset

| Old Thinking | New Thinking |
|--------------|--------------|
| "How do I optimize this?" | "Is this code correct and pure?" |
| "Client-side by default" | "Server-side by default" |
| "Loading states everywhere" | "Suspense boundaries" |
| "useEffect for data" | "async Server Component" |
| "Manual form handling" | "Form Actions" |
| "Separate concerns by type" | "Colocate by feature" |
| "JS required" | "Progressive enhancement" |
| "I control rendering" | "React Compiler controls rendering" |

The fundamental shift: **React is now a full-stack framework paradigm**, not just a UI library. Think about the entire request/response cycle, not just what happens in the browser.
