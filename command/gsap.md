---
name: gsap
description: Analyze website and generate comprehensive GSAP animations. Use when you want to enhance a site with scroll effects, text animations, SVG effects, layout transitions, drag interactions, or any GSAP-based motion.
---

# GSAP Animation Generator

Analyze the current project and generate comprehensive GSAP animations using all available GSAP skills as reference.

## How to use

- `/gsap`
  Analyze the current project and generate a comprehensive GSAP animation plan with implementations.

- `/gsap <component>`
  Focus animations on a specific component or section (e.g., `/gsap hero`, `/gsap nav`, `/gsap cards`).

- `/gsap scroll`
  Focus specifically on scroll-based animations (ScrollTrigger patterns).

- `/gsap text`
  Focus specifically on text animations (SplitText, typewriter, scramble effects).

- `/gsap svg`
  Focus specifically on SVG animations (DrawSVG, MorphSVG, MotionPath).

- `/gsap audit`
  Review existing GSAP usage in the project and suggest improvements.

## Skills to Reference

Load and reference these skills as needed:

| Skill | Use When |
|-------|----------|
| `gsap-core` | Basic tweens, timelines, playback controls |
| `gsap-scrolltrigger` | Scroll-based animations, pin, scrub, snap |
| `gsap-text` | Text reveals, SplitText, ScrambleText |
| `gsap-svg` | SVG stroke animation, morphing, path motion |
| `gsap-flip` | Layout transitions, reorder animations |
| `gsap-draggable` | Drag interactions, sliders, carousels |
| `gsap-observer` | Gesture detection, swipe patterns |
| `gsap-easing` | Easing selection, custom eases |
| `gsap-react` | React integration with useGSAP |
| `gsap-utilities` | Utility functions (clamp, mapRange, pipe) |
| `gsap-performance` | Performance optimization patterns |
| `gsap-setup` | Installation and configuration |

## Analysis Phase

Before implementing, analyze the project structure:

1. **Framework Detection**
   - Check for React/Next.js (`package.json`, `.tsx` files)
   - Check for Vue/Nuxt
   - Check for vanilla JS/HTML
   - Determine if `@gsap/react` is installed

2. **Component Inventory**
   - Identify hero sections
   - Identify navigation elements
   - Identify card/grid layouts
   - Identify text-heavy sections
   - Identify SVG elements
   - Identify interactive elements (buttons, modals)
   - Identify scrollable sections

3. **Animation Opportunities**
   - Entrance animations (fade in, slide in, scale)
   - Scroll-triggered reveals
   - Text animations (split, scramble)
   - SVG drawing/morphing
   - Hover effects
   - Layout transitions
   - Parallax effects
   - Sticky/pinned sections
   - Drag interactions

## Implementation Phase

For each animation opportunity, provide:

1. **Setup Code**
   ```javascript
   // Required imports and registrations
   import gsap from 'gsap'
   import { ScrollTrigger } from 'gsap/ScrollTrigger'
   gsap.registerPlugin(ScrollTrigger)
   ```

2. **Animation Code**
   - Complete, copy-paste ready implementation
   - Proper cleanup handling
   - Responsive considerations (matchMedia)

3. **Performance Notes**
   - Use transform/opacity (GPU-accelerated)
   - Avoid layout thrashing
   - Consider reduced-motion preferences

## Output Format

Generate a structured animation plan:

```markdown
## GSAP Animation Plan for [Project Name]

### Setup
[Installation commands, imports, registrations]

### Animations by Section

#### Hero
- [Animation name]: [Description]
- [Code block]

#### Navigation
- [Animation name]: [Description]
- [Code block]

#### [Continue for each section]

### Performance Considerations
- [Notes on optimization]

### Reduced Motion
- [How to handle prefers-reduced-motion]
```

## Quality Rules

1. **Never animate layout properties** (`width`, `height`, `top`, `left`, `margin`, `padding`) - use `transform` instead
2. **Always use proper easing** - match ease to context (`power2.out` for UI, `back.out` for attention)
3. **Stagger appropriately** - don't make stagger too slow or too fast
4. **Respect reduced motion** - wrap animations in `gsap.matchMedia()` check
5. **Clean up on unmount** - use `useGSAP` in React or kill timelines
6. **Test on low-end devices** - consider performance impact

## Quick Patterns Reference

### Entrance
```javascript
gsap.from('.element', {
  opacity: 0,
  y: 50,
  duration: 0.8,
  ease: 'power2.out'
})
```

### Scroll Reveal
```javascript
gsap.from('.cards', {
  scrollTrigger: {
    trigger: '.cards',
    start: 'top 80%'
  },
  opacity: 0,
  y: 30,
  stagger: 0.1
})
```

### Text Split
```javascript
const split = new SplitText('.heading', { type: 'chars' })
gsap.from(split.chars, {
  opacity: 0,
  y: 20,
  stagger: 0.02,
  ease: 'back.out'
})
```

### Pinned Scroll
```javascript
gsap.to('.section', {
  scrollTrigger: {
    trigger: '.section',
    pin: true,
    scrub: true,
    end: '+=500'
  },
  x: -500
})
```

## Notes

- All GSAP plugins (including formerly members-only ones like SplitText, DrawSVG, MorphSVG) are available under the Standard No-Charge License as of GSAP 3.13+
- Commercial use is allowed; prohibited uses apply to competing visual no-code animation builders
- See: https://gsap.com/community/standard-license/
