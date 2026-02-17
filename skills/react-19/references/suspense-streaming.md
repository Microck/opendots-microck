# Suspense, Streaming & Error Handling in React 19

React 19 brings significant improvements to Suspense behavior, streaming, and error handling.

## Suspense Improvements

### Sibling Pre-warming

**React 18:** When a component suspended, React would wait before rendering siblings.

**React 19:** Fallback commits immediately, then siblings are pre-warmed in the background.

```tsx
function Dashboard() {
  return (
    <div>
      <Suspense fallback={<UserSkeleton />}>
        <UserCard />       {/* Suspends - fetching user */}
        <UserStats />      {/* Pre-warmed while UserCard loads! */}
        <UserActivity />   {/* Pre-warmed while UserCard loads! */}
      </Suspense>
    </div>
  );
}
```

**Impact:**
- Faster perceived loading (siblings start loading earlier)
- Better parallelization of data fetching
- Smoother reveal when data arrives

### Nested Suspense Boundaries

Design for progressive disclosure with nested boundaries:

```tsx
function ProductPage({ productId }) {
  return (
    <div>
      {/* Critical: Load first */}
      <Suspense fallback={<ProductHeaderSkeleton />}>
        <ProductHeader productId={productId} />
      </Suspense>

      {/* Secondary: Can wait */}
      <Suspense fallback={<ProductDetailsSkeleton />}>
        <ProductDetails productId={productId} />

        {/* Tertiary: Nested, loads after details */}
        <Suspense fallback={<ReviewsSkeleton />}>
          <Reviews productId={productId} />
        </Suspense>
      </Suspense>

      {/* Independent: Loads in parallel */}
      <Suspense fallback={<RelatedSkeleton />}>
        <RelatedProducts productId={productId} />
      </Suspense>
    </div>
  );
}
```

---

## Streaming Patterns

### Server-Side Streaming

With Server Components, HTML streams to the client as data becomes available:

```tsx
// This streams progressively
export default async function Page() {
  return (
    <div>
      {/* Immediate - no data needed */}
      <Header />

      {/* Streams when user data ready */}
      <Suspense fallback={<UserSkeleton />}>
        <UserProfile />
      </Suspense>

      {/* Streams when posts data ready */}
      <Suspense fallback={<PostsSkeleton />}>
        <PostsFeed />
      </Suspense>

      {/* Immediate */}
      <Footer />
    </div>
  );
}

async function UserProfile() {
  const user = await getUser(); // 200ms
  return <Profile user={user} />;
}

async function PostsFeed() {
  const posts = await getPosts(); // 500ms
  return <Feed posts={posts} />;
}
```

**Timeline:**
1. `0ms`: Header, Footer, both skeletons render
2. `200ms`: UserProfile streams in, replaces skeleton
3. `500ms`: PostsFeed streams in, replaces skeleton

### Parallel Data Fetching

Avoid waterfalls by initiating fetches at the same level:

```tsx
// ❌ Waterfall: Sequential loading
async function Dashboard() {
  const user = await getUser();        // Wait 200ms
  const posts = await getPosts();      // Then wait 300ms
  const stats = await getStats();      // Then wait 150ms
  // Total: 650ms

  return <DashboardUI user={user} posts={posts} stats={stats} />;
}

// ✅ Parallel: Concurrent loading
async function Dashboard() {
  const [user, posts, stats] = await Promise.all([
    getUser(),   // 200ms
    getPosts(),  // 300ms  } All run
    getStats(),  // 150ms  } concurrently
  ]);
  // Total: 300ms (slowest)

  return <DashboardUI user={user} posts={posts} stats={stats} />;
}

// ✅ Best: Independent Suspense boundaries
function Dashboard() {
  return (
    <div>
      <Suspense fallback={<UserSkeleton />}>
        <UserSection />      {/* Shows at 200ms */}
      </Suspense>
      <Suspense fallback={<PostsSkeleton />}>
        <PostsSection />     {/* Shows at 300ms */}
      </Suspense>
      <Suspense fallback={<StatsSkeleton />}>
        <StatsSection />     {/* Shows at 150ms - first! */}
      </Suspense>
    </div>
  );
}
```

---

## The `use()` Hook with Suspense

### Basic Pattern

```tsx
import { use, Suspense } from 'react';

// Parent creates the promise
function CommentsSection({ postId }) {
  const commentsPromise = fetchComments(postId);

  return (
    <Suspense fallback={<CommentsSkeleton />}>
      <Comments commentsPromise={commentsPromise} />
    </Suspense>
  );
}

// Child reads the promise
function Comments({ commentsPromise }) {
  const comments = use(commentsPromise); // Suspends until resolved

  return (
    <ul>
      {comments.map(c => (
        <li key={c.id}>{c.text}</li>
      ))}
    </ul>
  );
}
```

### Caching Promises

**Critical:** Promises must be stable (not created fresh each render):

```tsx
// ❌ Bad: New promise every render
function Bad({ id }) {
  const data = use(fetch(`/api/${id}`)); // Creates new promise!
}

// ✅ Good: Stable promise reference
function Good({ id }) {
  const promise = useMemo(() => fetchData(id), [id]);
  const data = use(promise);
}

// ✅ Better: Promise created in parent
function Parent({ id }) {
  const promise = fetchData(id);
  return (
    <Suspense fallback={<Loading />}>
      <Child dataPromise={promise} />
    </Suspense>
  );
}
```

### With Error Boundaries

```tsx
function DataSection({ dataPromise }) {
  return (
    <ErrorBoundary fallback={<ErrorMessage />}>
      <Suspense fallback={<Loading />}>
        <DataDisplay dataPromise={dataPromise} />
      </Suspense>
    </ErrorBoundary>
  );
}

function DataDisplay({ dataPromise }) {
  const data = use(dataPromise); // Throws on rejection
  return <div>{data.content}</div>;
}
```

---

## Error Handling

### New Error Callbacks

React 19 provides granular error handling at the root level:

```tsx
import { createRoot } from 'react-dom/client';

const root = createRoot(document.getElementById('root'), {
  // Errors NOT caught by an Error Boundary
  onUncaughtError: (error, errorInfo) => {
    console.error('Uncaught error:', error);
    console.error('Component stack:', errorInfo.componentStack);

    // Send to error tracking
    Sentry.captureException(error, {
      extra: { componentStack: errorInfo.componentStack }
    });
  },

  // Errors caught by an Error Boundary
  onCaughtError: (error, errorInfo) => {
    console.warn('Caught error:', error);

    // Log but don't alert (boundary handled it)
    analytics.track('error_caught', {
      error: error.message,
      component: errorInfo.componentStack
    });
  },

  // Errors React recovered from automatically
  onRecoverableError: (error, errorInfo) => {
    console.info('Recovered from:', error);

    // Hydration mismatches, etc.
    // Usually safe to ignore, but good to track
  }
});

root.render(<App />);
```

### Error Boundary Pattern

```tsx
'use client';

import { Component, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    // Log to error tracking service
    console.error('Error caught by boundary:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback;
    }
    return this.props.children;
  }
}

// Usage
function App() {
  return (
    <ErrorBoundary fallback={<ErrorPage />}>
      <Suspense fallback={<Loading />}>
        <MainContent />
      </Suspense>
    </ErrorBoundary>
  );
}
```

### Hydration Error Improvements

React 19 provides better hydration error messages with diffs:

```
// React 18: Vague error
Warning: Text content did not match. Server: "Hello" Client: "World"

// React 19: Clear diff
Uncaught Error: Hydration failed because the server rendered HTML didn't match the client.

<div>
- Hello
+ World
</div>
```

---

## Stylesheet Loading with Suspense

React 19 coordinates stylesheet loading with Suspense boundaries:

```tsx
function FeatureSection() {
  return (
    <Suspense fallback={<FeatureSkeleton />}>
      {/* Stylesheet loads before content reveals */}
      <link rel="stylesheet" href="/feature.css" precedence="default" />
      <FeatureContent />
    </Suspense>
  );
}
```

**Behavior:**
1. Suspense shows fallback
2. Data loads AND stylesheet loads
3. Only when both ready: content reveals (no FOUC)

### Precedence Levels

```tsx
<link rel="stylesheet" href="/reset.css" precedence="reset" />
<link rel="stylesheet" href="/base.css" precedence="low" />
<link rel="stylesheet" href="/theme.css" precedence="default" />
<link rel="stylesheet" href="/feature.css" precedence="high" />
```

Higher precedence stylesheets are inserted later (override lower).

---

## Best Practices

### 1. Suspense Boundary Placement

```tsx
// ❌ Too broad: Everything waits for slowest
<Suspense fallback={<FullPageSpinner />}>
  <Header />
  <MainContent />
  <Sidebar />
  <Footer />
</Suspense>

// ✅ Granular: Independent loading
<Header />
<div className="layout">
  <Suspense fallback={<ContentSkeleton />}>
    <MainContent />
  </Suspense>
  <Suspense fallback={<SidebarSkeleton />}>
    <Sidebar />
  </Suspense>
</div>
<Footer />
```

### 2. Skeleton Design

Match the layout of actual content to prevent layout shift:

```tsx
function CardSkeleton() {
  return (
    <div className="card">
      <div className="skeleton-image" style={{ height: 200 }} />
      <div className="skeleton-text" style={{ height: 24, width: '80%' }} />
      <div className="skeleton-text" style={{ height: 16, width: '60%' }} />
    </div>
  );
}
```

### 3. Error Boundary Granularity

```tsx
function Dashboard() {
  return (
    <div>
      {/* Critical - show error prominently */}
      <ErrorBoundary fallback={<CriticalError />}>
        <Suspense fallback={<UserSkeleton />}>
          <UserSection />
        </Suspense>
      </ErrorBoundary>

      {/* Non-critical - hide on error */}
      <ErrorBoundary fallback={null}>
        <Suspense fallback={<WidgetSkeleton />}>
          <OptionalWidget />
        </Suspense>
      </ErrorBoundary>
    </div>
  );
}
```

### 4. Loading State Hierarchy

```tsx
// Instant (0ms): Static shell
// Fast (< 200ms): Critical content
// Acceptable (< 1s): Secondary content
// Background: Tertiary content

function Page() {
  return (
    <>
      {/* Instant */}
      <Header />
      <Navigation />

      {/* Fast - small spinner acceptable */}
      <Suspense fallback={<SmallSpinner />}>
        <HeroSection />
      </Suspense>

      {/* Acceptable - skeleton */}
      <Suspense fallback={<ContentSkeleton />}>
        <MainContent />
      </Suspense>

      {/* Background - can lazy load */}
      <Suspense fallback={null}>
        <AnalyticsWidgets />
      </Suspense>
    </>
  );
}
```
