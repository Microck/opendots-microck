---
name: gsap-scrolltrigger
description: Use when implementing scroll-based animations, scroll-driven effects, pinning elements, scrubbing animations, scroll callbacks, or when using ScrollTrigger plugin.
---

# GSAP ScrollTrigger

ScrollTrigger links animations to the scroll position of a page or container. Enable scrubbing, pinning, snapping, and callbacks for scroll-driven experiences.

## Installation

```bash
npm install gsap
```

```javascript
import gsap from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'

gsap.registerPlugin(ScrollTrigger)
```

## Basic Usage

### Simple Scroll Animation

```javascript
gsap.to('.box', {
  x: 500,
  scrollTrigger: {
    trigger: '.box',
    start: 'top 80%',       // When top of box hits 80% of viewport
    end: 'top 20%',         // When top of box hits 20% of viewport
    scrub: true              // Link animation to scroll
  }
})
```

### Scrub with Smoothing

```javascript
gsap.to('.box', {
  x: 500,
  scrollTrigger: {
    trigger: '.box',
    start: 'top center',
    scrub: 1              // 1 second smoothing
  }
})
```

## Pinning

### Basic Pin

```javascript
gsap.to('.box', {
  x: 500,
  scrollTrigger: {
    trigger: '.box',
    start: 'top center',
    end: '+=500',          // Pin for 500px of scroll
    pin: true,             // Pin the trigger element
    scrub: true
  }
})
```

### Pin with Spacing Control

```javascript
gsap.to('.box', {
  x: 500,
  scrollTrigger: {
    trigger: '.box',
    start: 'top center',
    end: '+=500',
    pin: true,
    pinSpacing: false      // Don't add extra spacing
  }
})
```

### Pin Different Element

```javascript
gsap.to('.content', {
  x: 500,
  scrollTrigger: {
    trigger: '.trigger-element',
    start: 'top center',
    end: '+=500',
    pin: '.pin-element',  // Pin different element
    scrub: true
  }
})
```

## Toggle Actions

```javascript
gsap.to('.box', {
  x: 500,
  scrollTrigger: {
    trigger: '.box',
    start: 'top center',
    end: 'bottom center',
    toggleActions: 'play none none reverse'
    // Format: onEnter, onLeave, onEnterBack, onLeaveBack
    // Options: play, pause, resume, reset, restart, complete, reverse, none
  }
})
```

**Toggle action examples:**
- `'play none none reverse'` - Play on scroll down, reverse on scroll up
- `'play pause resume reset'` - Play down, pause, resume on scroll up, reset
- `'restart none none none'` - Always restart when entering
- `'none none none reverse'` - Only animate when scrolling up

## Callbacks

```javascript
gsap.to('.box', {
  x: 500,
  scrollTrigger: {
    trigger: '.box',
    start: 'top center',

    // Scroll event callbacks
    onEnter: (self) => console.log('Entered', self.progress),
    onLeave: (self) => console.log('Left', self.progress),
    onEnterBack: (self) => console.log('Re-entered', self.progress),
    onLeaveBack: (self) => console.log('Re-left', self.progress),
    onUpdate: (self) => console.log('Update', self.progress),
    onToggle: (self) => console.log('Toggled', self.isActive),

    // Scrub complete
    onScrubComplete: (self) => console.log('Scrub complete'),

    // Refresh events
    onRefresh: (self) => console.log('Refreshed'),
    onRefreshInit: (self) => console.log('Refresh init')
  }
})
```

### Accessing ScrollTrigger Data

```javascript
ScrollTrigger.create({
  trigger: '.box',
  start: 'top center',
  onUpdate: (self) => {
    console.log('Progress:', self.progress)      // 0-1
    console.log('Direction:', self.direction)      // 1 or -1
    console.log('Velocity:', self.getVelocity())   // Scroll velocity
    console.log('Active:', self.isActive)          // Boolean
  }
})
```

## Position Syntax

### Basic Positions

```javascript
scrollTrigger: {
  trigger: '.box',

  // Viewport positions
  start: 'top center',      // Element top hits viewport center
  end: 'bottom top',        // Element bottom hits viewport top

  // Pixel values
  start: 'top 100px',       // Element top hits 100px from viewport top
  end: 'top 500px',

  // Percentage
  start: 'top 80%',        // Element top hits 80% viewport
  end: 'top 20%',

  // Relative values
  start: 'top center',
  end: '+=500',            // 500px after start

  // Function
  start: (self) => {
    return self.trigger.offsetHeight * 0.8
  }
}
```

### Position Keywords

- `top` / `bottom` / `center` / `left` / `right`: Element edge
- `top center` - Element top to viewport center
- `center center` - Element center to viewport center
- `bottom 80%` - Element bottom to 80% from viewport top

## Timeline Integration

### Timeline with ScrollTrigger

```javascript
const tl = gsap.timeline({
  scrollTrigger: {
    trigger: '.section',
    start: 'top center',
    end: 'bottom top',
    scrub: true,
    pin: true
  }
})

tl.to('.box1', { x: 100, duration: 1 })
  .to('.box2', { x: 100, duration: 1 })
  .to('.box3', { x: 100, duration: 1 })
```

### Multiple ScrollTriggers on Timeline

```javascript
const tl = gsap.timeline()

tl.to('.box1', {
  x: 100,
  scrollTrigger: {
    trigger: '.box1',
    start: 'top center',
    scrub: true
  }
})

tl.to('.box2', {
  y: 100,
  scrollTrigger: {
    trigger: '.box2',
    start: 'top center',
    scrub: true
  }
})
```

## Snapping

### Basic Snap

```javascript
gsap.to('.box', {
  x: 500,
  scrollTrigger: {
    trigger: '.box',
    start: 'top center',
    end: '+=500',
    scrub: 1,
    snap: 0.1              // Snap to 0.1 increments (10%)
  }
})
```

### Snap to Values

```javascript
gsap.to('.box', {
  x: 500,
  scrollTrigger: {
    trigger: '.box',
    start: 'top center',
    end: '+=500',
    scrub: 1,
    snap: [0, 0.25, 0.5, 0.75, 1]  // Snap to specific values
  }
})
```

### Snap with Direction

```javascript
gsap.to('.box', {
  x: 500,
  scrollTrigger: {
    trigger: '.box',
    start: 'top center',
    end: '+=500',
    scrub: 1,
    snap: {
      snapTo: [0.25, 0.5, 0.75, 1],
      duration: { min: 0.2, max: 0.5 },
      ease: 'power1.inOut',
      inertia: true
    }
  }
})
```

## Markers

### Enable Markers

```javascript
gsap.to('.box', {
  x: 500,
  scrollTrigger: {
    trigger: '.box',
    start: 'top center',
    end: '+=500',
    scrub: true,
    markers: true          // Show visual markers
  }
})
```

### Custom Markers

```javascript
gsap.to('.box', {
  x: 500,
  scrollTrigger: {
    trigger: '.box',
    start: 'top center',
    end: '+=500',
    scrub: true,
    markers: {
      startColor: 'green',
      endColor: 'red',
      fontSize: '18px',
      indent: 20,
      name: 'My Trigger'
    }
  }
})
```

## Horizontal Scroll

### Basic Horizontal

```javascript
gsap.to('.container', {
  xPercent: -100 * (sections.length - 1),
  scrollTrigger: {
    trigger: '.wrapper',
    start: 'top top',
    end: '+=3000',
    pin: true,
    scrub: 1,
    snap: 1 / (sections.length - 1)
  }
})
```

### Horizontal with Sections

```javascript
const sections = gsap.utils.toArray('.section')

gsap.to(sections, {
  xPercent: -100 * (sections.length - 1),
  scrollTrigger: {
    trigger: '.container',
    start: 'top top',
    end: '+=3000',
    pin: true,
    scrub: 1,
    snap: 1 / (sections.length - 1)
  }
})
```

## Nested ScrollTriggers

```javascript
// Parent timeline
const parentTl = gsap.timeline({
  scrollTrigger: {
    trigger: '.parent',
    start: 'top top',
    end: '+=1000',
    pin: true,
    scrub: true
  }
})

// Nested ScrollTrigger
parentTl.to('.child', {
  rotation: 360,
  scrollTrigger: {
    trigger: '.child',
    start: 'top center',
    end: 'bottom center',
    scrub: true
  }
})
```

## Batch Operations

### Batch with ScrollTrigger

```javascript
ScrollTrigger.batch('.box', {
  onEnter: batch => gsap.to(batch, { opacity: 1, y: 0, stagger: 0.1 }),
  onLeave: batch => gsap.to(batch, { opacity: 0, y: 50 }),
  onEnterBack: batch => gsap.to(batch, { opacity: 1, y: 0 }),
  onLeaveBack: batch => gsap.to(batch, { opacity: 0, y: 50 })
})
```

### Batch with Scrub

```javascript
ScrollTrigger.batch('.box', {
  start: 'top bottom-=100',
  onEnter: batch => gsap.to(batch, {
    scale: 1,
    opacity: 1,
    stagger: 0.1,
    overwrite: 'auto',
    scrollTrigger: {
      trigger: batch,
      start: 'top bottom-=100',
      end: 'bottom top',
      scrub: true
    }
  })
})
```

## Dynamic Triggers

### Dynamic Content

```javascript
function createDynamicTrigger() {
  const box = document.createElement('div')
  box.className = 'box'
  document.body.appendChild(box)

  gsap.to(box, {
    x: 500,
    scrollTrigger: {
      trigger: box,
      start: 'top center',
      end: '+=500',
      scrub: true
    }
  })

  return box
}
```

### Refresh After DOM Changes

```javascript
// Add content dynamically
document.querySelector('.container').innerHTML = newContent

// Refresh ScrollTrigger
ScrollTrigger.refresh()
```

## Scroller Customization

### Custom Scroller

```javascript
gsap.to('.box', {
  x: 500,
  scrollTrigger: {
    trigger: '.box',
    start: 'top 80%',
    scroller: '.custom-scroller',  // Custom scroll container
    scrub: true
  }
})
```

### Multiple Scrollers

```javascript
// Container 1
gsap.to('.box1', {
  x: 500,
  scrollTrigger: {
    trigger: '.box1',
    scroller: '.scroller1',
    start: 'top center',
    scrub: true
  }
})

// Container 2
gsap.to('.box2', {
  x: 500,
  scrollTrigger: {
    trigger: '.box2',
    scroller: '.scroller2',
    start: 'top center',
    scrub: true
  }
})
```

## Instance Methods

```javascript
const st = ScrollTrigger.create({
  trigger: '.box',
  start: 'top center',
  onEnter: () => console.log('Entered')
})

// Manually trigger
st.scroll(st.start)          // Jump to start position
st.scroll(st.end)            // Jump to end position

// Get position
console.log(st.start)
console.log(st.end)
console.log(st.progress)

// Update
st.refresh()
st.update()

// Enable/disable
st.enable()
st.disable()

// Kill
st.kill()

// Get velocity
st.getVelocity()

// Check if active
console.log(st.isActive)
```

## Static Methods

```javascript
// Get all ScrollTriggers
const triggers = ScrollTrigger.getAll()

// Refresh all
ScrollTrigger.refresh()

// Scroll to position
ScrollTrigger.scroll(position)

// Create standalone instance
const st = ScrollTrigger.create({
  trigger: '.box',
  start: 'top center',
  onEnter: () => console.log('Entered')
})

// Match media with ScrollTrigger
gsap.matchMedia().add('(min-width: 768px)', () => {
  ScrollTrigger.refresh()
})
```

## Performance Tips

### Use Scrub Sparingly

```javascript
// ❌ Heavy scrub on many elements
gsap.utils.toArray('.item').forEach(item => {
  gsap.to(item, {
    x: 100,
    scrollTrigger: {
      trigger: item,
      scrub: true
    }
  })
})

// ✅ Batch or use toggle actions
gsap.to('.item', {
  x: 100,
  scrollTrigger: {
    trigger: '.container',
    start: 'top center',
    toggleActions: 'play none none reverse'
  }
})
```

### Refresh Only When Needed

```javascript
// ❌ Refresh on every scroll
window.addEventListener('scroll', () => {
  ScrollTrigger.refresh()
})

// ✅ Refresh after DOM changes
function addContent() {
  document.querySelector('.container').innerHTML = newContent
  ScrollTrigger.refresh()
}
```

### Use Anticipate Pin

```javascript
gsap.to('.box', {
  x: 500,
  scrollTrigger: {
    trigger: '.box',
    start: 'top center',
    end: '+=500',
    pin: true,
    anticipatePin: 1  // Pin 1 scroll tick early
  }
})
```

## Common Patterns

### Parallax Effect

```javascript
gsap.to('.parallax-bg', {
  yPercent: 50,
  scrollTrigger: {
    trigger: '.section',
    start: 'top bottom',
    end: 'bottom top',
    scrub: true
  }
})
```

### Reveal on Scroll

```javascript
gsap.from('.reveal', {
  opacity: 0,
  y: 50,
  scrollTrigger: {
    trigger: '.reveal',
    start: 'top 80%',
    toggleActions: 'play none none reverse'
  },
  stagger: 0.2
})
```

### Progress Indicator

```javascript
ScrollTrigger.create({
  trigger: '.section',
  start: 'top top',
  end: 'bottom bottom',
  onUpdate: (self) => {
    gsap.to('.progress-bar', {
      scaleX: self.progress
    })
  }
})
```

## Common Mistakes

### 1. Forgetting Refresh

```javascript
// ❌ DOM changes but ScrollTrigger uses old positions
dynamicContent.innerHTML = newContent

// ✅ Refresh after changes
dynamicContent.innerHTML = newContent
ScrollTrigger.refresh()
```

### 2. Wrong Scroller

```javascript
// ❌ Using default scroller when using custom
gsap.to('.box', {
  x: 500,
  scrollTrigger: {
    trigger: '.box',
    start: 'top center',
    scrub: true
    // Missing scroller: '.custom-scroller'
  }
})

// ✅ Specify custom scroller
gsap.to('.box', {
  x: 500,
  scrollTrigger: {
    trigger: '.box',
    start: 'top center',
    scroller: '.custom-scroller',
    scrub: true
  }
})
```

### 3. Pin Conflicts

```javascript
// ❌ Multiple pins causing issues
gsap.to('.box1', { x: 500, scrollTrigger: { trigger: '.box1', pin: true } })
gsap.to('.box2', { x: 500, scrollTrigger: { trigger: '.box2', pin: true } })

// ✅ Use nested timeline or check overlap
const tl = gsap.timeline({ scrollTrigger: { trigger: '.container', pin: true } })
tl.to('.box1', { x: 500 })
  .to('.box2', { x: 500 })
```

## Best Practices

1. **Use scrub wisely** - Good for visual control, bad for performance with many elements
2. **Pin only when necessary** - Pinning adds complexity
3. **Leverage toggle actions** - More performant than scrub for simple effects
4. **Refresh after DOM changes** - Critical for dynamic content
5. **Use markers for development** - Remove in production
6. **Combine with timelines** - Easier to control complex sequences
7. **Consider performance** - Batch similar animations, avoid over-scrubbing

## Quick Reference

| Feature | Method |
|---------|--------|
| Register plugin | `gsap.registerPlugin(ScrollTrigger)` |
| Basic scroll animation | `gsap.to(target, { scrollTrigger: { trigger, start, scrub } })` |
| Pin element | `pin: true` |
| Scrub with smoothing | `scrub: 1` |
| Toggle actions | `toggleActions: 'play none none reverse'` |
| Callbacks | `onEnter`, `onLeave`, `onUpdate` |
| Refresh | `ScrollTrigger.refresh()` |
| Get all triggers | `ScrollTrigger.getAll()` |
| Markers | `markers: true` |
| Snap | `snap: 0.1` |
| Custom scroller | `scroller: '.container'` |
