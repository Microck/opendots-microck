---
name: gsap-react
description: Use when using GSAP with React, useGSAP hook, React component animations, ScrollTrigger in React, or managing GSAP lifecycle in React components.
---

# GSAP React Integration

GSAP integrates seamlessly with React through the `@gsap/react` package and `useGSAP()` hook. Automatically handles cleanup, scoping, and lifecycle management.

## Installation

```bash
npm install gsap @gsap/react
```

## Basic Setup

### Register Hook

```javascript
import gsap from 'gsap'
import { useGSAP } from '@gsap/react'
import { ScrollTrigger } from 'gsap/ScrollTrigger'

gsap.registerPlugin(ScrollTrigger, useGSAP)
```

### Basic useGSAP Hook

```javascript
import { useGSAP } from '@gsap/react'
import { useRef } from 'react'

function MyComponent() {
  const container = useRef()

  useGSAP(() => {
    gsap.to('.box', { x: 200, duration: 1 })
  }, { scope: container })

  return <div ref={container}>
    <div className="box">Animate me</div>
  </div>
}
```

## Selector Scoping

### Scope to Container

```javascript
import { useGSAP } from '@gsap/react'
import { useRef } from 'react'

function MyComponent() {
  const container = useRef()

  useGSAP(() => {
    // Only targets within container
    gsap.to('.box', { x: 200, duration: 1 })
  }, { scope: container })

  return (
    <div ref={container}>
      <div className="box">Box 1</div>
      <div className="box">Box 2</div>
    </div>
  )
}
```

### Without Scoping (Global)

```javascript
useGSAP(() => {
  // Targets globally (be careful!)
  gsap.to('.box', { x: 200, duration: 1 })
})
```

## Dependency Array

### Rerun on Dependencies

```javascript
import { useState } from 'react'
import { useGSAP } from '@gsap/react'

function Counter() {
  const [count, setCount] = useState(0)

  useGSAP(() => {
    gsap.to('.counter', {
      scale: 1 + count * 0.1,
      duration: 0.5
    })
  }, { scope: container, dependencies: [count] })

  return <div className="counter">{count}</div>
}
```

### Automatic Cleanup

```javascript
useGSAP(() => {
  const tl = gsap.timeline()
  tl.to('.box', { x: 200, duration: 1 })

  // Automatically cleaned up on unmount
})
```

## ScrollTrigger Integration

### Basic ScrollTrigger

```javascript
import { ScrollTrigger } from 'gsap/ScrollTrigger'

function ScrollComponent() {
  const container = useRef()

  useGSAP(() => {
    gsap.to('.box', {
      x: 500,
      scrollTrigger: {
        trigger: '.box',
        start: 'top center',
        end: 'bottom center',
        scrub: true
      }
    })
  }, { scope: container })

  return <div ref={container}>
    <div className="box">Scroll me</div>
  </div>
}
```

### Multiple ScrollTriggers

```javascript
useGSAP(() => {
  gsap.to('.box1', {
    x: 200,
    scrollTrigger: {
      trigger: '.box1',
      start: 'top 80%'
    }
  })

  gsap.to('.box2', {
    x: 200,
    scrollTrigger: {
      trigger: '.box2',
      start: 'top 80%'
    }
  })
}, { scope: container })
```

### Pinning with useGSAP

```javascript
useGSAP(() => {
  const tl = gsap.timeline({
    scrollTrigger: {
      trigger: '.section',
      start: 'top top',
      end: '+=500',
      pin: true,
      scrub: true
    }
  })

  tl.to('.box', { x: 200, duration: 1 })
    .to('.box', { y: 200, duration: 1 })
}, { scope: container })
```

## Context Safety

### contextSafe for Events

```javascript
import { useGSAP } from '@gsap/react'
import { useRef } from 'react'

function Button() {
  const container = useRef()

  useGSAP(() => {
    const { contextSafe } = useGSAP(() => {}, { scope: container })

    const handleClick = contextSafe(() => {
      gsap.to('.box', {
        scale: 1.5,
        duration: 0.3,
        ease: 'back.out(1.7)'
      })
    })

    document.querySelector('.button').addEventListener('click', handleClick)

    return () => {
      document.querySelector('.button').removeEventListener('click', handleClick)
    }
  })

  return <div ref={container}>
    <div className="button">Click me</div>
    <div className="box">Box</div>
  </div>
}
```

## Responsive with matchMedia

### Basic matchMedia

```javascript
useGSAP(() => {
  const mm = gsap.matchMedia()

  mm.add('(min-width: 768px)', () => {
    gsap.to('.box', { x: 200, duration: 1 })
  })

  mm.add('(max-width: 767px)', () => {
    gsap.to('.box', { x: 100, duration: 1 })
  })

  return () => mm.revert()
}, { scope: container })
```

### Nested matchMedia

```javascript
useGSAP(() => {
  const mm = gsap.matchMedia()

  mm.add('(min-width: 1024px)', () => {
    gsap.to('.box', { x: 300, duration: 1 })
  })

  mm.add('(min-width: 768px) and (max-width: 1023px)', () => {
    gsap.to('.box', { x: 200, duration: 1 })
  })

  mm.add('(max-width: 767px)', () => {
    gsap.to('.box', { x: 100, duration: 1 })
  })

  return () => mm.revert()
}, { scope: container })
```

## Dynamic Content

### Animate on Data Change

```javascript
function DataList({ items }) {
  const container = useRef()

  useGSAP(() => {
    gsap.from('.item', {
      opacity: 0,
      y: 20,
      stagger: 0.1,
      duration: 0.5
    })
  }, { scope: container, dependencies: [items] })

  return (
    <div ref={container}>
      {items.map((item, i) => (
        <div key={i} className="item">{item}</div>
      ))}
    </div>
  )
}
```

### Animate on Mount

```javascript
function Welcome() {
  const container = useRef()

  useGSAP(() => {
    gsap.from('.welcome', {
      opacity: 0,
      y: -30,
      duration: 0.8,
      ease: 'back.out(1.7)'
    })
  }, { scope: container })

  return <div ref={container}>
    <div className="welcome">Welcome!</div>
  </div>
}
```

### Animate on Unmount

```javascript
function Modal({ isOpen, onClose }) {
  const container = useRef()

  useGSAP(() => {
    if (isOpen) {
      gsap.from('.modal-content', {
        scale: 0.8,
        opacity: 0,
        duration: 0.3,
        ease: 'back.out(1.7)'
      })
    }

    return () => {
      if (isOpen) {
        gsap.to('.modal-content', {
          scale: 0.8,
          opacity: 0,
          duration: 0.2,
          ease: 'power2.in'
        })
      }
    }
  }, { scope: container, dependencies: [isOpen] })

  return isOpen ? (
    <div className="modal" ref={container}>
      <div className="modal-content">Modal content</div>
    </div>
  ) : null
}
```

## Advanced Patterns

### Controlled Timeline

```javascript
function ControlledAnimation({ isPlaying }) {
  const container = useRef()

  useGSAP(() => {
    const tl = gsap.timeline({ paused: true })

    tl.to('.box', { x: 200, duration: 1 })
      .to('.box', { y: 200, duration: 1 })
      .to('.box', { rotation: 360, duration: 1 })

    // Expose timeline
    window.myTimeline = tl
  }, { scope: container })

  useEffect(() => {
    if (isPlaying && window.myTimeline) {
      window.myTimeline.play()
    } else if (!isPlaying && window.myTimeline) {
      window.myTimeline.pause()
    }
  }, [isPlaying])

  return <div ref={container}>
    <div className="box">Box</div>
  </div>
}
```

### Flip Animation

```javascript
import { Flip } from 'gsap/Flip'
gsap.registerPlugin(Flip)

function DraggableList({ items }) {
  const container = useRef()

  useGSAP(() => {
    const state = Flip.getState('.item')
    // DOM changes happen automatically by React
    Flip.from(state, {
      duration: 0.8,
      ease: 'power2.out'
    })
  }, { scope: container, dependencies: [items] })

  return (
    <div ref={container}>
      {items.map((item, i) => (
        <div key={item.id} className="item">
          {item.text}
        </div>
      ))}
    </div>
  )
}
```

### SplitText in React

```javascript
import { SplitText } from 'gsap/SplitText'
gsap.registerPlugin(SplitText)

function AnimatedText({ text }) {
  const container = useRef()

  useGSAP(() => {
    const split = new SplitText('.text', { type: 'chars' })
    gsap.from(split.chars, {
      opacity: 0,
      y: 20,
      stagger: 0.02,
      duration: 0.5
    })

    return () => split.revert()
  }, { scope: container, dependencies: [text] })

  return (
    <div ref={container}>
      <div className="text">{text}</div>
    </div>
  )
}
```

## ScrollTrigger + Dynamic Data

```javascript
function InfiniteScroll({ data }) {
  const container = useRef()

  useGSAP(() => {
    ScrollTrigger.refresh()
  }, { scope: container, dependencies: [data] })

  useGSAP(() => {
    gsap.from('.item', {
      opacity: 0,
      y: 50,
      stagger: 0.1,
      duration: 0.6,
      scrollTrigger: {
        trigger: '.item',
        start: 'top 80%',
        toggleActions: 'play none none reverse'
      }
    })
  }, { scope: container, dependencies: [data] })

  return (
    <div ref={container}>
      {data.map((item, i) => (
        <div key={i} className="item">{item}</div>
      ))}
    </div>
  )
}
```

## Multiple Hooks

### Separate Scopes

```javascript
function MultiAnimation() {
  const scope1 = useRef()
  const scope2 = useRef()

  useGSAP(() => {
    gsap.to('.box1', { x: 200, duration: 1 })
  }, { scope: scope1 })

  useGSAP(() => {
    gsap.to('.box2', { y: 200, duration: 1 })
  }, { scope: scope2 })

  return (
    <>
      <div ref={scope1}>
        <div className="box1">Box 1</div>
      </div>
      <div ref={scope2}>
        <div className="box2">Box 2</div>
      </div>
    </>
  )
}
```

## Strict Mode Handling

### useGSAP Handles Strict Mode

```javascript
// React 18 Strict Mode double-mounts components
// useGSAP automatically handles this

function StrictComponent() {
  const container = useRef()

  useGSAP(() => {
    // Runs twice in Strict Mode, but cleans up properly
    gsap.from('.box', {
      opacity: 0,
      y: 20,
      duration: 0.5
    })
  }, { scope: container })

  return <div ref={container}>
    <div className="box">Box</div>
  </div>
}
```

## Performance Tips

### Memoize Callbacks

```javascript
import { useCallback } from 'react'

function OptimizedComponent() {
  const container = useRef()

  const animateBox = useCallback(() => {
    gsap.to('.box', { x: 200, duration: 1 })
  }, [])

  useGSAP(() => {
    animateBox()
  }, { scope: container, dependencies: [animateBox] })

  return <div ref={container}>
    <div className="box">Box</div>
  </div>
}
```

### Throttle Expensive Updates

```javascript
useGSAP(() => {
  const throttledUpdate = gsap.utils.throttle(() => {
    // Expensive operation
    updateLayout()
  }, 100)

  gsap.to('.box', {
    onUpdate: throttledUpdate
  })
}, { scope: container })
```

## Common Mistakes

### 1. Not Scoping Selectors

```javascript
// ❌ Targets globally, can affect other components
useGSAP(() => {
  gsap.to('.box', { x: 200 })
})

// ✅ Scope to container
useGSAP(() => {
  gsap.to('.box', { x: 200 })
}, { scope: container })
```

### 2. Forgetting Dependencies

```javascript
// ❌ Animation doesn't update when data changes
useGSAP(() => {
  gsap.from('.item', { opacity: 0, stagger: 0.1 })
}, { scope: container })

// ✅ Include data in dependencies
useGSAP(() => {
  gsap.from('.item', { opacity: 0, stagger: 0.1 })
}, { scope: container, dependencies: [items] })
```

### 3. Manual Cleanup Issues

```javascript
// ❌ Memory leaks, zombie animations
useEffect(() => {
  gsap.to('.box', { x: 200 })
}, [])

// ✅ useGSAP handles cleanup
useGSAP(() => {
  gsap.to('.box', { x: 200 })
}, { scope: container })
```

## Best Practices

1. **Always use scope** - Prevents selector conflicts
2. **Include dependencies** - Rerun animations when data changes
3. **Use contextSafe for events** - Ensures cleanup
4. **Leverage matchMedia** - Responsive animations
5. **Refresh ScrollTrigger** - After dynamic DOM changes
6. **Use revertOnUpdate** - Revert animations on updates
7. **Clean up timelines** - Expose and kill if needed
8. **Test with Strict Mode** - useGSAP handles double-mounts

## Quick Reference

| Feature | Method |
|---------|--------|
| Import hook | `import { useGSAP } from '@gsap/react'` |
| Register hook | `gsap.registerPlugin(useGSAP)` |
| Basic usage | `useGSAP(() => { ... }, { scope: ref })` |
| Dependencies | `useGSAP(() => { ... }, { dependencies: [data] })` |
| ScrollTrigger | Works automatically with useGSAP |
| matchMedia | `gsap.matchMedia().add(...)` |
| Context safe | `const { contextSafe } = useGSAP(...)` |
| Cleanup | Automatic, or return cleanup function |
