---
name: gsap-core
description: Use when implementing GSAP core animations, tweens, timeline sequencing, playback controls, or when using gsap.to(), gsap.from(), gsap.fromTo(), gsap.set(), gsap.timeline().
---

# GSAP Core - Tweens and Timelines

GSAP's core provides the fundamental building blocks for animation: tweens (single animations) and timelines (sequences of tweens). This skill covers all core methods, playback controls, and best practices.

## Installation

```bash
npm install gsap
```

```javascript
import gsap from 'gsap'
```

## Core Tween Methods

### gsap.to(target, vars)

Animate from current values to new end values. Most commonly used method.

```javascript
// Basic animation
gsap.to('.box', {
  x: 200,
  opacity: 0.5,
  duration: 1.5,
  ease: 'power2.out'
})

// Multiple properties
gsap.to('.element', {
  x: 100,
  y: 50,
  rotation: 90,
  scale: 1.2,
  backgroundColor: '#ff0000',
  duration: 1
})

// Array of targets
gsap.to('.box', {
  x: 100,
  duration: 1,
  stagger: 0.1
})
```

### gsap.from(target, vars)

Animate from defined start values to current values. Ideal for entrance effects.

```javascript
// Element fades in from below
gsap.from('.hero', {
  opacity: 0,
  y: 100,
  duration: 1,
  ease: 'back.out(1.7)'
})

// Elements animate from scattered positions
gsap.from('.particle', {
  x: () => gsap.utils.random(-200, 200),
  y: () => gsap.utils.random(-200, 200),
  scale: 0,
  duration: 1,
  stagger: 0.05,
  ease: 'elastic.out(1, 0.3)'
})
```

### gsap.fromTo(target, fromVars, toVars)

Explicitly control both start and end values. Maximum control.

```javascript
gsap.fromTo('.box',
  { opacity: 0, x: -100 },
  { opacity: 1, x: 0, duration: 1 }
)

// Perfect for state transitions
gsap.fromTo('.modal',
  { opacity: 0, scale: 0.8, y: 50 },
  { opacity: 1, scale: 1, y: 0, duration: 0.3, ease: 'back.out' }
)
```

### gsap.set(target, vars)

Instantly apply values without duration (zero-duration tween). Good for initial states.

```javascript
// Set initial state
gsap.set('.box', { opacity: 0 })

// Position elements without animation
gsap.set('.item', {
  x: (i) => i * 100,
  y: (i) => i * 50
})

// Set multiple properties
gsap.set('.element', {
  display: 'flex',
  opacity: 0,
  y: 20
})
```

## Timeline Methods

### Creating Timelines

```javascript
// Basic timeline
const tl = gsap.timeline()

// Timeline with defaults
const tl = gsap.timeline({
  paused: true,
  repeat: -1,
  yoyo: true,
  defaults: { ease: 'power2.out', duration: 1 }
})

// Timeline with ScrollTrigger
const tl = gsap.timeline({
  scrollTrigger: {
    trigger: '.section',
    start: 'top center',
    scrub: true
  }
})
```

### Chaining Tweens

```javascript
const tl = gsap.timeline()

// Sequential animations
tl.to('.box1', { x: 100, duration: 1 })
  .to('.box2', { x: 100, duration: 1 })

// Overlapping animations
tl.to('.box1', { x: 100, duration: 1 })
  .to('.box2', { x: 100, duration: 1 }, '-=0.5')  // Start 0.5s before previous ends

// Same start time
tl.to('.box1', { x: 100, duration: 1 })
  .to('.box2', { x: 100, duration: 1 }, '<')       // Start with previous
  .to('.box3', { y: 100, duration: 1 }, '<0.2')    // Start 0.2s after previous
```

### Timeline Positioning

```javascript
const tl = gsap.timeline()

tl.to('.box1', { x: 100 })
  .addLabel('step1')  // Add label
  .to('.box2', { x: 100 }, 'step1')    // Start at label
  .to('.box3', { x: 100 }, 'step1+=0.5')  // 0.5s after label
  .to('.box4', { x: 100 }, 'step1-=0.2')  // 0.2s before label
```

**Position strings:**
- `"<"`: Start at same time as previous animation
- `">"`: Start after previous animation ends
- `"<0.5"`: Start 0.5s before previous ends
- `">0.5"`: Start 0.5s after previous ends
- `"label"`: Start at specific label
- `"label+=0.5"`: Start 0.5s after label
- `"label-=0.5"`: Start 0.5s before label

### Playback Control Methods

```javascript
const tl = gsap.timeline()

// Play
tl.play()
tl.play(0.5)          // Play from 0.5 seconds
tl.play('step1')       // Play from label

// Pause
tl.pause()
tl.pause(0.5)

// Reverse
tl.reverse()
tl.reverse(0.5)

// Progress control (0-1)
tl.progress(0)          // Start
tl.progress(0.5)        // Halfway
tl.progress(1)          // End

// Time scale (speed)
tl.timeScale(1)          // Normal speed
tl.timeScale(2)          // 2x faster
tl.timeScale(0.5)        // 2x slower

// Animation in place (pause after completing)
tl.animationProgress(0.5)

// Total progress (including repeats)
tl.totalProgress(0.75)

// Restart
tl.restart()

// Kill
tl.kill()
```

## Special Properties

### Core Tween Properties

```javascript
gsap.to('.box', {
  // Duration
  duration: 1,           // Seconds
  delay: 0.5,            // Delay before start

  // Easing
  ease: 'power2.out',     // See gsap-easing skill

  // Repeats
  repeat: 2,              // Number of repeats
  repeatDelay: 0.5,       // Delay between repeats
  yoyo: true,             // Alternate direction each repeat

  // Callbacks
  onStart: () => console.log('Started'),
  onUpdate: () => console.log('Updating'),
  onComplete: () => console.log('Complete'),
  onRepeat: () => console.log('Repeating'),
  onReverseComplete: () => console.log('Reverse complete')
})
```

### Advanced Properties

```javascript
gsap.to('.box', {
  x: 100,
  y: 50,
  rotation: 90,
  scale: 1.5,
  opacity: 0.5,

  // Transform origin
  transformOrigin: 'center center',

  // Immediate render
  immediateRender: false,    // Don't render immediately

  // Lazy rendering
  lazy: true,               // Don't render until needed

  // Overwrite behavior
  overwrite: 'auto',        // 'auto', 'true', false

  // ID for reference
  id: 'myAnimation',

  // Data storage
  data: { custom: 'value' }
})
```

## Stagger Animations

### Basic Stagger

```javascript
// Delay between elements
gsap.to('.box', {
  x: 100,
  stagger: 0.1          // 0.1s delay between each
})

// Stagger with options
gsap.to('.box', {
  x: 100,
  stagger: {
    each: 0.1,           // Delay between each
    from: 'start',         // 'start', 'center', 'end', 'edges'
    grid: [4, 4],         // Grid dimensions for pattern
    ease: 'power2.out'     // Easing for stagger
  }
})
```

### Stagger Patterns

```javascript
// From center
gsap.from('.item', {
  opacity: 0,
  scale: 0,
  stagger: {
    each: 0.05,
    from: 'center',
    ease: 'back.out(1.7)'
  }
})

// Grid stagger
gsap.to('.grid-item', {
  rotation: 90,
  stagger: {
    each: 0.1,
    from: 'center',
    grid: [5, 5],         // 5x5 grid
    ease: 'power2.inOut'
  }
})

// Wave pattern
gsap.to('.wave-item', {
  y: -50,
  stagger: {
    each: 0.05,
    from: 'start',
    ease: 'sine.out'
  }
})
```

## Keyframes

```javascript
// Multiple stages in one tween
gsap.to('.box', {
  keyframes: [
    { x: 100, duration: 1, ease: 'power1.inOut' },
    { y: 100, duration: 1, ease: 'power1.inOut' },
    { x: 0, y: 0, duration: 1, ease: 'power1.inOut' }
  ],
  duration: 3,           // Total duration if not specified per key
  easeEach: 'power1.out'  // Apply ease to each keyframe
})
```

## Callbacks

```javascript
gsap.to('.box', {
  x: 100,
  duration: 1,

  // Lifecycle callbacks
  onStart: function() {
    console.log(this.targets())  // Access targets
  },
  onUpdate: function() {
    console.log(this.progress())  // Current progress
  },
  onComplete: function() {
    console.log('Done!')
  },
  onRepeat: function() {
    console.log('Repeating...')
  },
  onReverseComplete: function() {
    console.log('Reverse done!')
  },

  // Parameters
  onStartParams: ['param1', 'param2'],
  onUpdateScope: myObject,
  onCompleteScope: myObject
})
```

## Instance Methods

```javascript
const tween = gsap.to('.box', { x: 100 })

// Control methods
tween.play()
tween.pause()
tween.resume()
tween.reverse()
tween.restart()
tween.kill()

// Progress control
tween.progress(0.5)
tween.time(0.5)

// Rate
tween.timeScale(2)

// Pause/resume
tween.pause()
tween.paused(true)

// Invalidate (force recalculation)
tween.invalidate()

// Get targets
tween.targets()

// Get timeline
tween.timeline()

// Get ID
tween.id

// Kill
tween.kill()
tween.kill(vars)  // Kill specific properties
```

## Global Methods

```javascript
// Kill all tweens
gsap.killTweensOf('.box')
gsap.killTweensOf('.box', 'x')  // Kill only x tweens
gsap.killTweensOf('.box', { x: true })

// Global defaults
gsap.defaults({
  ease: 'power2.out',
  duration: 1
})

// Match media (responsive)
const mm = gsap.matchMedia()

mm.add('(min-width: 768px)', () => {
  gsap.to('.box', { x: 200 })
})

mm.add('(max-width: 767px)', () => {
  gsap.to('.box', { x: 100 })
})

// Revert all match media
mm.revert()

// Get tween by ID
const tween = gsap.getById('myAnimation')

// Global ticker
gsap.ticker.add(callback)
gsap.ticker.remove(callback)
gsap.ticker.lagSmoothing(1000)  // Adjust lag smoothing

// Export timeline (for external control)
const tl = gsap.timeline()
window.myAnimation = tl
```

## Quick Patterns

### Entrance Animation

```javascript
gsap.from('.hero', {
  opacity: 0,
  y: 50,
  duration: 1,
  ease: 'power2.out'
})
```

### Exit Animation

```javascript
gsap.to('.modal', {
  opacity: 0,
  scale: 0.9,
  duration: 0.3,
  ease: 'power2.in',
  onComplete: () => {
    // Remove element
  }
})
```

### Hover Effect

```javascript
const hoverTween = gsap.to('.button', {
  scale: 1.1,
  duration: 0.3,
  ease: 'power2.out',
  paused: true
})

document.querySelector('.button').addEventListener('mouseenter', () => hoverTween.play())
document.querySelector('.button').addEventListener('mouseleave', () => hoverTween.reverse())
```

### Sequence with Labels

```javascript
const tl = gsap.timeline()

tl.addLabel('start')
  .to('.box1', { x: 100 }, 'start')
  .to('.box2', { x: 100 }, 'start+=0.5')
  .to('.box3', { x: 100 }, 'start+=1')
  .addLabel('end')

// Jump to label
tl.play('start')
```

## Common Mistakes

### 1. Forgetting to Register Plugins

```javascript
// ❌ Wrong
import { ScrollTrigger } from 'gsap/ScrollTrigger'
gsap.to('.box', { scrollTrigger: { ... } })

// ✅ Correct
gsap.registerPlugin(ScrollTrigger)
gsap.to('.box', { scrollTrigger: { ... } })
```

### 2. Conflicting Tweens

```javascript
// ❌ Conflicting
gsap.to('.box', { x: 100, duration: 2 })
gsap.to('.box', { x: 200, duration: 1 })

// ✅ Use overwrite
gsap.to('.box', { x: 100, duration: 2, overwrite: true })

// ✅ Or kill first
gsap.killTweensOf('.box', 'x')
gsap.to('.box', { x: 200, duration: 1 })
```

### 3. from() Flash

```javascript
// ❌ Element flashes before animation
gsap.from('.box', { opacity: 0 })

// ✅ Set initial state in CSS
// CSS: .box { opacity: 0; }
gsap.to('.box', { opacity: 1 })

// ✅ Or use fromTo
gsap.fromTo('.box',
  { opacity: 0 },
  { opacity: 1, duration: 1 }
)
```

## Best Practices

1. **Use timelines for sequences** - Easier to control and maintain
2. **Leverage stagger** - Creates smoother, more engaging animations
3. **Use callbacks wisely** - Don't overuse, keep logic simple
4. **Clean up animations** - Kill tweens/timelines when no longer needed
5. **Use matchMedia** - Make animations responsive
6. **Set appropriate eases** - Match animation to feel (see gsap-easing)
7. **Avoid over-animating** - Keep animations purposeful and performant

## Quick Reference

| Task | Method |
|------|--------|
| Animate to values | `gsap.to(target, { props })` |
| Animate from values | `gsap.from(target, { props })` |
| Animate both | `gsap.fromTo(target, { from }, { to })` |
| Set instantly | `gsap.set(target, { props })` |
| Create timeline | `gsap.timeline({ options })` |
| Kill tweens | `gsap.killTweensOf(target)` |
| Global defaults | `gsap.defaults({ props })` |
| Match media | `gsap.matchMedia()` |
| Get tween | `gsap.getById(id)` |
| Ticker | `gsap.ticker` |
