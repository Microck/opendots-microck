# React 19 Anti-Patterns

Patterns that were acceptable (or even recommended) before but should be avoided in React 19.

## Data Fetching Anti-Patterns

### useEffect for Initial Data

```tsx
// ❌ Anti-pattern: useEffect for data fetching
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    setLoading(true);
    fetchUser(userId)
      .then(setUser)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [userId]);

  if (loading) return <Spinner />;
  if (error) return <Error message={error.message} />;
  return <Profile user={user} />;
}

// ✅ React 19: Server Component
async function UserProfile({ userId }) {
  const user = await fetchUser(userId);
  return <Profile user={user} />;
}

// ✅ React 19: Client with use() and Suspense
function UserProfile({ userPromise }) {
  const user = use(userPromise);
  return <Profile user={user} />;
}
```

**Why it's an anti-pattern:**
- Creates loading/error state boilerplate
- Causes layout shift (content jumps when data loads)
- Waterfalls when nested (parent fetches, then child fetches)
- Runs on every render without careful memoization

### Fetching in Parent, Passing to Child

```tsx
// ❌ Anti-pattern: Prop drilling fetched data
function ProductPage({ productId }) {
  const product = useProduct(productId);
  const reviews = useReviews(productId);

  return (
    <div>
      <ProductInfo product={product} />
      <ProductReviews reviews={reviews} />
      <RelatedProducts product={product} />
    </div>
  );
}

// ✅ React 19: Each component fetches its own data
async function ProductPage({ productId }) {
  return (
    <div>
      <Suspense fallback={<ProductInfoSkeleton />}>
        <ProductInfo productId={productId} />
      </Suspense>
      <Suspense fallback={<ReviewsSkeleton />}>
        <ProductReviews productId={productId} />
      </Suspense>
      <Suspense fallback={<RelatedSkeleton />}>
        <RelatedProducts productId={productId} />
      </Suspense>
    </div>
  );
}

async function ProductInfo({ productId }) {
  const product = await getProduct(productId);
  return <div>{product.name}</div>;
}
```

**Why it's an anti-pattern:**
- All data must load before anything renders
- Tight coupling between parent and children
- Hard to add loading states per-section

---

## Memoization Anti-Patterns

### Premature/Excessive Memoization

```tsx
// ❌ Anti-pattern: Memoizing everything "just in case"
function ProductList({ products, onSelect }) {
  const sortedProducts = useMemo(
    () => products.sort((a, b) => a.name.localeCompare(b.name)),
    [products]
  );

  const handleSelect = useCallback(
    (id) => onSelect(id),
    [onSelect]
  );

  const itemStyle = useMemo(
    () => ({ padding: 10, margin: 5 }),
    []
  );

  return sortedProducts.map(p => (
    <ProductItem
      key={p.id}
      product={p}
      onSelect={handleSelect}
      style={itemStyle}
    />
  ));
}

// ✅ React 19: Let the compiler handle it
function ProductList({ products, onSelect }) {
  const sortedProducts = products.sort((a, b) =>
    a.name.localeCompare(b.name)
  );

  return sortedProducts.map(p => (
    <ProductItem
      key={p.id}
      product={p}
      onSelect={(id) => onSelect(id)}
      style={{ padding: 10, margin: 5 }}
    />
  ));
}
```

**Why it's an anti-pattern:**
- React Compiler handles memoization automatically
- Manual memoization adds cognitive overhead
- Often applied incorrectly (wrong deps, unnecessary usage)
- Makes code harder to read

### Memoizing Cheap Operations

```tsx
// ❌ Anti-pattern: Memoizing trivial computations
const fullName = useMemo(
  () => `${firstName} ${lastName}`,
  [firstName, lastName]
);

const isActive = useMemo(
  () => status === 'active',
  [status]
);

// ✅ React 19: Just compute it
const fullName = `${firstName} ${lastName}`;
const isActive = status === 'active';
```

**Why it's an anti-pattern:**
- useMemo has overhead (comparing deps, storing value)
- For cheap operations, overhead exceeds savings
- Compiler optimizes when actually needed

---

## Form Handling Anti-Patterns

### Controlled Inputs for Submit-Only Forms

```tsx
// ❌ Anti-pattern: useState for every form field
function ContactForm() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setIsSubmitting(true);
    await submitForm({ name, email, message });
    setIsSubmitting(false);
    setName('');
    setEmail('');
    setMessage('');
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={name} onChange={e => setName(e.target.value)} />
      <input value={email} onChange={e => setEmail(e.target.value)} />
      <textarea value={message} onChange={e => setMessage(e.target.value)} />
      <button disabled={isSubmitting}>Send</button>
    </form>
  );
}

// ✅ React 19: Form Actions with FormData
function ContactForm() {
  const [state, formAction, isPending] = useActionState(
    async (prev, formData) => {
      await submitForm({
        name: formData.get('name'),
        email: formData.get('email'),
        message: formData.get('message'),
      });
      return { success: true };
    },
    null
  );

  return (
    <form action={formAction}>
      <input name="name" />
      <input name="email" type="email" />
      <textarea name="message" />
      <button disabled={isPending}>Send</button>
    </form>
  );
}
```

**Why it's an anti-pattern:**
- Unnecessary re-renders on every keystroke
- Boilerplate for loading/reset states
- No progressive enhancement

### Manual Loading State Tracking

```tsx
// ❌ Anti-pattern: Manual loading booleans
function SubmitButton({ isLoading }) {
  return (
    <button disabled={isLoading}>
      {isLoading ? 'Loading...' : 'Submit'}
    </button>
  );
}

// ✅ React 19: useFormStatus
function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <button disabled={pending}>
      {pending ? 'Loading...' : 'Submit'}
    </button>
  );
}
```

---

## Component Pattern Anti-Patterns

### Client Component as Default

```tsx
// ❌ Anti-pattern: 'use client' everywhere
'use client';

export function ProductCard({ product }) {
  // No interactivity, just rendering
  return (
    <div>
      <h2>{product.name}</h2>
      <p>{product.description}</p>
      <span>{product.price}</span>
    </div>
  );
}

// ✅ React 19: Server Component (default)
export function ProductCard({ product }) {
  return (
    <div>
      <h2>{product.name}</h2>
      <p>{product.description}</p>
      <span>{product.price}</span>
    </div>
  );
}
```

**Why it's an anti-pattern:**
- Sends unnecessary JavaScript to client
- Increases bundle size
- Slows initial page load

### Large Client Boundaries

```tsx
// ❌ Anti-pattern: Entire page as client component
'use client';

export default function ProductPage({ productId }) {
  const [product, setProduct] = useState(null);
  // ... lots of code

  return (
    <div>
      <Header /> {/* Could be server */}
      <ProductInfo product={product} /> {/* Could be server */}
      <AddToCart productId={productId} /> {/* Needs client */}
      <Reviews productId={productId} /> {/* Could be server */}
      <Footer /> {/* Could be server */}
    </div>
  );
}

// ✅ React 19: Minimal client boundaries
export default async function ProductPage({ productId }) {
  const product = await getProduct(productId);

  return (
    <div>
      <Header />
      <ProductInfo product={product} />
      <AddToCart productId={productId} /> {/* Only this is client */}
      <Suspense fallback={<ReviewsSkeleton />}>
        <Reviews productId={productId} />
      </Suspense>
      <Footer />
    </div>
  );
}
```

---

## Ref Anti-Patterns

### forwardRef Wrapper

```tsx
// ❌ Anti-pattern: Using forwardRef
import { forwardRef } from 'react';

const Input = forwardRef<HTMLInputElement, InputProps>((props, ref) => {
  return <input ref={ref} {...props} />;
});

// ✅ React 19: ref as prop
function Input({ ref, ...props }: InputProps & { ref?: Ref<HTMLInputElement> }) {
  return <input ref={ref} {...props} />;
}
```

### Null Check Pattern for Ref Cleanup

```tsx
// ❌ Anti-pattern: Checking for null to detect unmount
<div ref={(node) => {
  if (node) {
    // Mount - setup
    node.addEventListener('scroll', handler);
  } else {
    // Unmount - cleanup (unreliable)
    // Can't access node here!
  }
}} />

// ✅ React 19: Cleanup function
<div ref={(node) => {
  node.addEventListener('scroll', handler);
  return () => {
    node.removeEventListener('scroll', handler);
  };
}} />
```

---

## Context Anti-Patterns

### Context.Provider Wrapper

```tsx
// ❌ Anti-pattern: Using .Provider
<ThemeContext.Provider value={theme}>
  {children}
</ThemeContext.Provider>

// ✅ React 19: Context directly
<ThemeContext value={theme}>
  {children}
</ThemeContext>
```

### useContext at Top Level Only

```tsx
// ❌ Old limitation: useContext must be top-level
function Component({ showTheme }) {
  const theme = useContext(ThemeContext); // Always called

  if (!showTheme) {
    return <div>No theme</div>;
  }

  return <div className={theme}>Themed</div>;
}

// ✅ React 19: use() can be conditional
function Component({ showTheme }) {
  if (!showTheme) {
    return <div>No theme</div>;
  }

  const theme = use(ThemeContext); // Called conditionally
  return <div className={theme}>Themed</div>;
}
```

---

## State Management Anti-Patterns

### Global State for Server Data

```tsx
// ❌ Anti-pattern: Redux/Zustand for server cache
const useProductStore = create((set) => ({
  products: [],
  loading: false,
  fetchProducts: async () => {
    set({ loading: true });
    const products = await api.getProducts();
    set({ products, loading: false });
  },
}));

function ProductList() {
  const { products, loading, fetchProducts } = useProductStore();

  useEffect(() => {
    fetchProducts();
  }, []);

  if (loading) return <Spinner />;
  return products.map(p => <Product key={p.id} {...p} />);
}

// ✅ React 19: Server Component (no client state needed)
async function ProductList() {
  const products = await getProducts();
  return products.map(p => <Product key={p.id} {...p} />);
}
```

**Why it's an anti-pattern:**
- Server Components eliminate need for client-side server data cache
- Simpler mental model
- No hydration mismatch issues
- Data is always fresh

**When global state IS still appropriate:**
- UI state (modals, sidebars, theme)
- Client-only data (form drafts, selections)
- Real-time data (WebSocket state)

---

## Summary Table

| Anti-Pattern | React 19 Solution |
|--------------|-------------------|
| `useEffect` for data fetching | Server Components / `use()` |
| Manual `isLoading` state | `useActionState`, `useFormStatus` |
| Excessive `useMemo`/`useCallback` | React Compiler |
| `forwardRef` wrapper | `ref` as prop |
| `Context.Provider` | `<Context value={}>` |
| `'use client'` everywhere | Server Components by default |
| `useState` for form fields | `FormData` + Actions |
| Global state for server data | Server Components |
| Loading spinners | Suspense boundaries |
| `null` check in ref callbacks | Cleanup functions |
