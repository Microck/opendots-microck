---
name: gsap-performance
description: Use when optimizing GSAP animations, performance tuning, ticker configuration, stagger optimization, or improving animation frame rates.
---

# GSAP Performance Optimization

GSAP is highly performant by design, but proper optimization ensures smooth 60fps animations even with complex effects. Master ticker, lag smoothing, staggers, and utilities for best results.

## Ticker and Lag Smoothing

### Basic Ticker Control

```javascript
// Get ticker settings
console.log(gsap.ticker.fps())
console.log(gsap.ticker.time())
console.log(gsap.ticker.delta)
```

### Lag Smoothing

```javascript
// Default lag smoothing (prevents visual jumps during CPU lag)
gsap.ticker.lagSmoothing(1000, 16)
// 1000ms threshold, 16ms treated as max lag

// Disable lag smoothing
gsap.ticker.lagSmoothing(0)

// Custom smoothing
gsap.ticker.lagSmoothing(500, 33)  // 500ms threshold, 33ms max
```

### Add Ticker Callback

```javascript
// Add to ticker
const callback = (time, deltaTime, frame) => {
  console.log('Tick:', time, deltaTime)
}

gsap.ticker.add(callback)

// Remove from ticker
gsap.ticker.remove(callback)

// Callback with priority
gsap.ticker.add(callback, false, 1)  // Priority 1
```

### Global Ticker Use

```javascript
// Synchronize with ticker
function syncWithTicker() {
  gsap.ticker.add(() => {
    // Run on every animation frame
    updateUI()
  })
}

// Stop synchronization
function stopSync() {
  gsap.ticker.remove(updateUI)
}
```

## Stagger Optimization

### Basic Stagger

```javascript
// Stagger delays - distributes load
gsap.to('.box', {
  x: 200,
  duration: 1,
  stagger: 0.1  // Good for performance
})
```

### Stagger with Ease

```javascript
// Non-linear stagger - more natural feel
gsap.from('.item', {
  opacity: 0,
  y: 20,
  stagger: {
    each: 0.05,
    ease: 'power2.out',  // Slower start, faster end
    from: 'center'
  },
  duration: 0.8
})
```

### Grid Stagger

```javascript
// Grid pattern - efficient for large numbers
gsap.to('.grid-item', {
  scale: 1,
  opacity: 1,
  stagger: {
    each: 0.05,
    from: 'center',
    grid: [10, 5],  // 10 columns, 5 rows
    ease: 'power2.inOut'
  },
  duration: 0.6
})
```

### Avoid Tiny Staggers

```javascript
// ❌ Too small - uneven execution
gsap.to('.many-boxes', {
  x: 100,
  stagger: 0.006  // Too small!
})

// ✅ Reasonable stagger
gsap.to('.many-boxes', {
  x: 100,
  stagger: 0.05  // Better
})
```

## Snapping

### Basic Snap

```javascript
gsap.to('.box', {
  x: 500,
  snap: 20  // Snap every 20px
})
```

### Snap to Array

```javascript
gsap.to('.box', {
  x: 500,
  snap: [0, 100, 200, 300, 400, 500]
})
```

### Snap with Radius

```javascript
gsap.to('.box', {
  x: 500,
  snap: {
    x: {
      points: [0, 100, 200, 300, 400, 500],
      radius: 10,  // Within 10px of point
      velocity: 0  // Don't affect velocity
    }
  }
})
```

### Live Snap Performance

```javascript
// For better performance, reduce delay
gsap.to('.box', {
  x: 500,
  snap: {
    x: 20,
    delay: 0.01  // Lower delay
  }
})
```

## Modifiers

### Basic Modifier

```javascript
gsap.to('.box', {
  x: 200,
  modifiers: {
    x: gsap.utils.unitize(x => Math.round(x / 10) * 10)  // Round to nearest 10
  }
})
```

### Clamping Modifier

```javascript
gsap.to('.box', {
  x: 500,
  modifiers: {
    x: gsap.utils.pipe(
      gsap.utils.clamp(0, 400)  // Clamp between 0 and 400
    )
  }
})
```

### Complex Modifier

```javascript
gsap.to('.box', {
  x: 500,
  y: 500,
  modifiers: {
    x: value => Math.round(value),
    y: value => Math.max(0, value)  // Never go negative
  }
})
```

## Keyframes

### Condense Tweens

```javascript
// ❌ Multiple tweens
gsap.to('.box', { x: 100, duration: 1 })
gsap.to('.box', { y: 100, duration: 1 })
gsap.to('.box', { rotation: 90, duration: 1 })

// ✅ Use keyframes
gsap.to('.box', {
  keyframes: [
    { x: 100, duration: 1 },
    { y: 100, duration: 1 },
    { rotation: 90, duration: 1 }
  ]
})
```

### Keyframes with Eases

```javascript
gsap.to('.box', {
  keyframes: [
    { x: 100, duration: 1, ease: 'power2.out' },
    { y: 100, duration: 1, ease: 'back.out' },
    { rotation: 90, duration: 1, ease: 'elastic.out' }
  ]
})
```

### Keyframe Duration Control

```javascript
gsap.to('.box', {
  duration: 3,  // Total duration
  keyframes: [
    { x: 100, duration: 1 },  // 1/3 of total
    { y: 100, duration: 1 },  // 1/3 of total
    { rotation: 90, duration: 1 }  // 1/3 of total
  ]
})
```

### Ease Each

```javascript
gsap.to('.box', {
  keyframes: [
    { x: 100 },
    { y: 100 },
    { rotation: 90 }
  ],
  easeEach: 'power1.out'  // Apply to all keyframes
})
```

## Performance Utilities

### Throttle

```javascript
gsap.to('.box', {
  onUpdate: gsap.utils.throttle(() => {
    // Expensive operation runs at most every 100ms
    updateLayout()
  }, 100)
})
```

### Debounce

```javascript
ScrollTrigger.create({
  trigger: '.section',
  onUpdate: gsap.utils.debounce((self) => {
    console.log('Scroll position stabilized:', self.progress)
  }, 100)
})
```

### Clamp

```javascript
// Clamp value between min and max
const clamped = gsap.utils.clamp(0, 100, 150)  // Returns 100
```

### Pipe

```javascript
// Chain utilities
const process = gsap.utils.pipe(
  gsap.utils.clamp(0, 100),
  gsap.utils.mapRange(0, 100, 0, 500)
)

console.log(process(150))  // Returns 500
```

## Optimization Strategies

### Combine Animations

```javascript
// ❌ Separate tweens
gsap.to('.box', { x: 100, duration: 1 })
gsap.to('.box', { y: 100, duration: 1 })
gsap.to('.box', { opacity: 0.5, duration: 1 })

// ✅ Combine properties
gsap.to('.box', {
  x: 100,
  y: 100,
  opacity: 0.5,
  duration: 1
})
```

### Limit Active Tweens

```javascript
// Kill tweens before creating new ones
gsap.killTweensOf('.box')
gsap.to('.box', { x: 200, duration: 1 })
```

### Use Timelines

```javascript
// Easier to control and optimize
const tl = gsap.timeline()

tl.to('.box1', { x: 100, duration: 1 })
  .to('.box2', { x: 100, duration: 1 })
  .to('.box3', { x: 100, duration: 1 })

// Control entire timeline
tl.kill()  // Kill all tweens at once
```

### Batch Operations

```javascript
// Batch ScrollTrigger
const elements = document.querySelectorAll('.element')

ScrollTrigger.batch(elements, {
  onEnter: batch => gsap.from(batch, {
    opacity: 0,
    y: 20,
    stagger: 0.1
  })
})
```

## Animation Performance Tips

### Use Transform Over Properties

```javascript
// ❌ Slower - triggers layout
gsap.to('.box', {
  left: 200,
  top: 100,
  width: 100,
  height: 100
})

// ✅ Faster - GPU-accelerated
gsap.to('.box', {
  x: 200,
  y: 100,
  scale: 1.5
})
```

### Avoid Filters on Many Elements

```javascript
// ❌ Heavy on many elements
gsap.to('.many-boxes', {
  filter: 'blur(10px)',
  duration: 1
})

// ✅ Use sparingly
gsap.to('.few-boxes', {
  filter: 'blur(10px)',
  duration: 1
})
```

### Use Will Change

```javascript
// Optimize with will-change
gsap.set('.box', { willChange: 'transform, opacity' })

gsap.to('.box', {
  x: 200,
  opacity: 0.5,
  duration: 1,

  onComplete: () => {
    gsap.set('.box', { willChange: 'auto' })
  }
})
```

### Reduce Change Area

```javascript
// Animate small areas for better performance
gsap.to('.small-indicator', {
  scale: 2,
  duration: 0.3
})

// Better than animating large area
gsap.to('.large-container', {
  scale: 1.1,
  duration: 0.3
})
```

## ScrollTrigger Performance

### Use Toggle Actions

```javascript
// More performant than scrub for simple effects
gsap.to('.box', {
  x: 200,
  scrollTrigger: {
    trigger: '.box',
    start: 'top 80%',
    toggleActions: 'play none none reverse'
  }
})
```

### Throttle Scroll Events

```javascript
ScrollTrigger.config({
  ignoreMobileResize: true,  // Ignore mobile resize events
  autoRefreshEvents: 'visibilitychange,DOMContentLoaded'  // Custom events
})
```

### Batch ScrollTriggers

```javascript
// Create multiple ScrollTriggers efficiently
const elements = document.querySelectorAll('.element')

elements.forEach(el => {
  ScrollTrigger.create({
    trigger: el,
    start: 'top 80%',
    onEnter: () => gsap.to(el, { opacity: 1 })
  })
})

// Then batch refresh
ScrollTrigger.refresh()
```

## Memory Management

### Kill When Done

```javascript
// Kill timeline when complete
const tl = gsap.timeline()

tl.to('.box', { x: 200, duration: 1 })

tl.eventCallback('onComplete', () => {
  tl.kill()
})
```

### Clean Up References

```javascript
// Remove references to prevent memory leaks
function animateAndCleanup() {
  const tl = gsap.timeline()

  tl.to('.box', { x: 200, duration: 1 })

  // Use animation
  tl.play()

  // Clean up
  setTimeout(() => {
    tl.kill()
  }, 2000)
}
```

### Revert SplitText

```javascript
const split = new SplitText('#text', { type: 'chars' })

gsap.from(split.chars, {
  opacity: 0,
  y: 20,
  onComplete: () => {
    split.revert()  // Clean up
  }
})
```

## Performance Monitoring

### Measure FPS

```javascript
let frameCount = 0
let lastTime = performance.now()

gsap.ticker.add(() => {
  frameCount++
  const now = performance.now()

  if (now - lastTime >= 1000) {
    console.log('FPS:', frameCount)
    frameCount = 0
    lastTime = now
  }
})
```

### Profile Animation

```javascript
const start = performance.now()

gsap.to('.box', {
  x: 200,
  duration: 1,
  onComplete: () => {
    const duration = performance.now() - start
    console.log('Animation time:', duration)
  }
})
```

## Common Mistakes

### 1. Over-scrubbing

```javascript
// ❌ Scrub too many elements
gsap.to('.many-boxes', {
  x: 200,
  scrollTrigger: { scrub: true }
})

// ✅ Use toggle actions
gsap.to('.many-boxes', {
  x: 200,
  scrollTrigger: { toggleActions: 'play none none reverse' }
})
```

### 2. Animating Wrong Properties

```javascript
// ❌ Triggers layout
gsap.to('.box', {
  left: 200,
  top: 100
})

// ✅ Use transform
gsap.to('.box', {
  x: 200,
  y: 100
})
```

### 3. Not Killing Tweens

```javascript
// ❌ Memory leaks
function animateManyTimes() {
  gsap.to('.box', { x: 200, duration: 1 })
}

// ✅ Clean up
function animateManyTimes() {
  gsap.killTweensOf('.box')
  gsap.to('.box', { x: 200, duration: 1 })
}
```

## Best Practices

1. **Use transform properties** - GPU-accelerated, no layout thrashing
2. **Stagger animations** - Distributes load, smoother experience
3. **Combine properties** - Fewer tweens = better performance
4. **Use timelines** - Easier control and cleanup
5. **Kill when done** - Free memory, prevent conflicts
6. **Test on low-end devices** - Ensure smooth performance
7. **Profile bottlenecks** - Identify expensive animations
8. **Use appropriate eases** - Complex eases cost more

## Quick Reference

| Feature | Method |
|---------|--------|
| Lag smoothing | `gsap.ticker.lagSmoothing(1000, 16)` |
| Add callback | `gsap.ticker.add(callback)` |
| Remove callback | `gsap.ticker.remove(callback)` |
| Stagger | `stagger: 0.1` |
| Snap | `snap: 20` or `snap: [0, 100, 200]` |
| Modifier | `modifiers: { x: fn }` |
| Keyframes | `keyframes: [...]` |
| Throttle | `gsap.utils.throttle(fn, 100)` |
| Debounce | `gsap.utils.debounce(fn, 100)` |
| Kill tweens | `gsap.killTweensOf(target)` |
| Will change | `gsap.set(target, { willChange: 'transform' })` |
