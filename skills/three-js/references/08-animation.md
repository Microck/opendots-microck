# Three.js Animation

Keyframe animation, skeletal animation, morph targets, blending, and procedural motion.

## Animation System Overview

Three.js animation has three main components:

1. **AnimationClip** - Container for keyframe data
2. **AnimationMixer** - Plays animations on a root object
3. **AnimationAction** - Controls playback of a clip

## AnimationClip

Stores keyframe animation data.

```javascript
// Create animation clip manually
const times = [0, 1, 2];  // Keyframe times (seconds)
const values = [0, 1, 0];  // Values at each keyframe

const track = new THREE.NumberKeyframeTrack('.position[y]', times, values);
const clip = new THREE.AnimationClip('bounce', 2, [track]);
```

### KeyframeTrack Types

```javascript
// Number track (single value)
new THREE.NumberKeyframeTrack('.opacity', [0, 1], [1, 0]);
new THREE.NumberKeyframeTrack('.material.opacity', [0, 1], [1, 0]);

// Vector track (position, scale)
new THREE.VectorKeyframeTrack('.position', [0, 1, 2], [
  0, 0, 0,  // t=0
  1, 2, 0,  // t=1
  0, 0, 0,  // t=2
]);

// Quaternion track (rotation)
const q1 = new THREE.Quaternion().setFromEuler(new THREE.Euler(0, 0, 0));
const q2 = new THREE.Quaternion().setFromEuler(new THREE.Euler(0, Math.PI, 0));
new THREE.QuaternionKeyframeTrack('.quaternion', [0, 1], [
  q1.x, q1.y, q1.z, q1.w,
  q2.x, q2.y, q2.z, q2.w,
]);

// Color track
new THREE.ColorKeyframeTrack('.material.color', [0, 1, 2], [
  1, 0, 0,  // red
  0, 1, 0,  // green
  0, 0, 1,  // blue
]);

// Boolean track
new THREE.BooleanKeyframeTrack('.visible', [0, 0.5, 1], [true, false, true]);

// String track (rare)
new THREE.StringKeyframeTrack('.name', [0, 1], ['start', 'end']);
```

### Interpolation Modes

```javascript
const track = new THREE.VectorKeyframeTrack('.position', times, values);

track.setInterpolation(THREE.InterpolateLinear);    // Default, linear
track.setInterpolation(THREE.InterpolateSmooth);    // Cubic spline
track.setInterpolation(THREE.InterpolateDiscrete);  // Step function
```

## AnimationMixer

Plays animations on an object and its descendants.

```javascript
const mixer = new THREE.AnimationMixer(model);

// Create action from clip
const action = mixer.clipAction(clip);
action.play();

// Update in animation loop (required!)
const clock = new THREE.Clock();

function animate() {
  const delta = clock.getDelta();
  mixer.update(delta);

  requestAnimationFrame(animate);
  renderer.render(scene, camera);
}
```

### Mixer Events

```javascript
mixer.addEventListener('finished', (e) => {
  console.log('Finished:', e.action.getClip().name);
});

mixer.addEventListener('loop', (e) => {
  console.log('Looped:', e.action.getClip().name);
});
```

## AnimationAction

Controls playback of an animation clip.

```javascript
const action = mixer.clipAction(clip);

// Playback control
action.play();
action.stop();
action.reset();
action.halt(fadeOutDuration);

// Playback state
action.isRunning();
action.isScheduled();

// Time control
action.time = 0.5;           // Current time
action.timeScale = 1;        // Playback speed (negative = reverse)
action.paused = false;

// Weight (for blending)
action.weight = 1;           // 0-1, contribution to final pose
action.setEffectiveWeight(1);

// Loop modes
action.loop = THREE.LoopRepeat;     // Loop forever (default)
action.loop = THREE.LoopOnce;       // Play once and stop
action.loop = THREE.LoopPingPong;   // Alternate forward/backward
action.repetitions = 3;             // Number of loops

// Clamping
action.clampWhenFinished = true;    // Hold last frame when done

// Blend mode
action.blendMode = THREE.NormalAnimationBlendMode;
action.blendMode = THREE.AdditiveAnimationBlendMode;
```

### Fade In/Out

```javascript
// Fade in
action.reset().fadeIn(0.5).play();

// Fade out
action.fadeOut(0.5);

// Crossfade between animations
action1.play();
// Later...
action1.crossFadeTo(action2, 0.5, true);
action2.play();
```

### Time Scale Warping

Smoothly transition between playback speeds:

```javascript
// warp(startTimeScale, endTimeScale, duration)
action.warp(1, 2, 0.5);     // Speed up from 1x to 2x over 0.5 seconds

// Slow-motion effect
action.warp(1, 0.1, 0.3);   // Slow down to 0.1x
// Later...
action.warp(0.1, 1, 0.3);   // Speed back up to normal

// Reverse playback
action.warp(1, -1, 0.5);    // Transition to reverse
```

## Loading GLTF Animations

```javascript
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';

const loader = new GLTFLoader();
loader.load('character.glb', (gltf) => {
  const model = gltf.scene;
  scene.add(model);

  // Create mixer
  const mixer = new THREE.AnimationMixer(model);

  // Get all clips
  const clips = gltf.animations;
  console.log('Animations:', clips.map(c => c.name));

  // Play first animation
  if (clips.length > 0) {
    mixer.clipAction(clips[0]).play();
  }

  // Play by name
  const walkClip = THREE.AnimationClip.findByName(clips, 'Walk');
  if (walkClip) {
    mixer.clipAction(walkClip).play();
  }

  // Store for animation loop
  window.mixer = mixer;
});
```

## Skeletal Animation

### Skeleton and Bones

```javascript
// Find skinned mesh
const skinnedMesh = model.getObjectByProperty('type', 'SkinnedMesh');
const skeleton = skinnedMesh.skeleton;

// List all bones
skeleton.bones.forEach(bone => {
  console.log(bone.name);
});

// Find specific bone
const headBone = skeleton.bones.find(b => b.name === 'Head');

// Manipulate bone
if (headBone) {
  headBone.rotation.y = Math.PI / 4;  // Turn head
}

// Skeleton helper (visualize bones)
const helper = new THREE.SkeletonHelper(model);
scene.add(helper);
```

### Programmatic Bone Animation

```javascript
function animate() {
  const time = clock.getElapsedTime();

  // Find and animate bone
  const headBone = skeleton.bones.find(b => b.name === 'Head');
  if (headBone) {
    headBone.rotation.y = Math.sin(time) * 0.3;
    headBone.rotation.x = Math.sin(time * 0.5) * 0.1;
  }

  // Still update mixer for other animations
  mixer.update(clock.getDelta());
}
```

### Bone Attachments

```javascript
// Attach object to bone
const weapon = new THREE.Mesh(weaponGeometry, weaponMaterial);
const handBone = skeleton.bones.find(b => b.name === 'RightHand');

if (handBone) {
  handBone.add(weapon);
  // Offset attachment
  weapon.position.set(0, 0, 0.5);
  weapon.rotation.set(0, Math.PI / 2, 0);
}
```

## Morph Targets

Blend between different mesh shapes.

```javascript
// Find morph targets
const mesh = model.getObjectByProperty('type', 'Mesh');
console.log('Morph targets:', Object.keys(mesh.morphTargetDictionary));

// Access influences
mesh.morphTargetInfluences;      // Array of weights
mesh.morphTargetDictionary;      // Name -> index mapping

// Set by index
mesh.morphTargetInfluences[0] = 0.5;

// Set by name
const smileIndex = mesh.morphTargetDictionary['smile'];
mesh.morphTargetInfluences[smileIndex] = 1;
```

### Animating Morph Targets

```javascript
// Procedural
function animate() {
  const t = clock.getElapsedTime();
  mesh.morphTargetInfluences[0] = (Math.sin(t) + 1) / 2;
}

// With keyframe animation
const track = new THREE.NumberKeyframeTrack(
  'mesh.morphTargetInfluences[0]',
  [0, 0.5, 1],
  [0, 1, 0]
);
const clip = new THREE.AnimationClip('smile', 1, [track]);
mixer.clipAction(clip).play();
```

## Animation Blending

Mix multiple animations together.

```javascript
// Setup actions
const idleAction = mixer.clipAction(idleClip);
const walkAction = mixer.clipAction(walkClip);
const runAction = mixer.clipAction(runClip);

// Play all
idleAction.play();
walkAction.play();
runAction.play();

// Set initial weights
idleAction.setEffectiveWeight(1);
walkAction.setEffectiveWeight(0);
runAction.setEffectiveWeight(0);

// Blend based on speed
function updateAnimations(speed) {
  if (speed < 0.1) {
    idleAction.setEffectiveWeight(1);
    walkAction.setEffectiveWeight(0);
    runAction.setEffectiveWeight(0);
  } else if (speed < 5) {
    const t = speed / 5;
    idleAction.setEffectiveWeight(1 - t);
    walkAction.setEffectiveWeight(t);
    runAction.setEffectiveWeight(0);
  } else {
    const t = Math.min((speed - 5) / 5, 1);
    idleAction.setEffectiveWeight(0);
    walkAction.setEffectiveWeight(1 - t);
    runAction.setEffectiveWeight(t);
  }
}
```

### Additive Blending

Layer animations on top of base pose.

```javascript
// Base pose
const baseAction = mixer.clipAction(baseClip);
baseAction.play();

// Additive layer (e.g., breathing, looking around)
THREE.AnimationUtils.makeClipAdditive(additiveClip);

const additiveAction = mixer.clipAction(additiveClip);
additiveAction.blendMode = THREE.AdditiveAnimationBlendMode;
additiveAction.play();
```

## Animation Utilities

```javascript
// Find clip by name
const clip = THREE.AnimationClip.findByName(clips, 'Walk');

// Create subclip
const subclip = THREE.AnimationUtils.subclip(clip, 'subclip', 0, 30, 30);

// Convert to additive
THREE.AnimationUtils.makeClipAdditive(clip);
THREE.AnimationUtils.makeClipAdditive(clip, 0, referenceClip);

// Clone clip
const clone = clip.clone();

// Get duration
clip.duration;

// Optimize (remove redundant keyframes)
clip.optimize();

// Reset duration
clip.resetDuration();
```

## Procedural Animation Patterns

### Smooth Damping

```javascript
const current = new THREE.Vector3();
const target = new THREE.Vector3();
const velocity = new THREE.Vector3();

function smoothDamp(current, target, velocity, smoothTime, deltaTime) {
  const omega = 2 / smoothTime;
  const x = omega * deltaTime;
  const exp = 1 / (1 + x + 0.48 * x * x + 0.235 * x * x * x);

  const change = current.clone().sub(target);
  const temp = velocity.clone().add(change.clone().multiplyScalar(omega)).multiplyScalar(deltaTime);

  velocity.sub(temp.clone().multiplyScalar(omega)).multiplyScalar(exp);

  return target.clone().add(change.add(temp).multiplyScalar(exp));
}

function animate() {
  current.copy(smoothDamp(current, target, velocity, 0.3, delta));
  mesh.position.copy(current);
}
```

### Spring Physics

```javascript
class Spring {
  constructor(stiffness = 100, damping = 10) {
    this.stiffness = stiffness;
    this.damping = damping;
    this.position = 0;
    this.velocity = 0;
    this.target = 0;
  }

  update(dt) {
    const force = -this.stiffness * (this.position - this.target);
    const dampingForce = -this.damping * this.velocity;
    this.velocity += (force + dampingForce) * dt;
    this.position += this.velocity * dt;
    return this.position;
  }
}

const spring = new Spring(100, 10);
spring.target = 1;

function animate() {
  mesh.position.y = spring.update(delta);
}
```

### Vector Spring

```javascript
class VectorSpring {
  constructor(stiffness = 100, damping = 10) {
    this.stiffness = stiffness;
    this.damping = damping;
    this.position = new THREE.Vector3();
    this.velocity = new THREE.Vector3();
    this.target = new THREE.Vector3();
  }

  update(dt) {
    const force = this.target.clone().sub(this.position).multiplyScalar(this.stiffness);
    const dampingForce = this.velocity.clone().multiplyScalar(-this.damping);

    this.velocity.add(force.add(dampingForce).multiplyScalar(dt));
    this.position.add(this.velocity.clone().multiplyScalar(dt));

    return this.position;
  }
}
```

### Oscillation Patterns

```javascript
function animate() {
  const t = clock.getElapsedTime();

  // Sine wave
  mesh.position.y = Math.sin(t * 2) * 0.5;

  // Bouncing (absolute sine)
  mesh.position.y = Math.abs(Math.sin(t * 3)) * 2;

  // Circular motion
  mesh.position.x = Math.cos(t) * 2;
  mesh.position.z = Math.sin(t) * 2;

  // Figure 8
  mesh.position.x = Math.sin(t) * 2;
  mesh.position.z = Math.sin(t * 2) * 1;

  // Breathing (slow smooth)
  mesh.scale.setScalar(1 + Math.sin(t * 0.5) * 0.05);
}
```

### Easing Functions

```javascript
const Easing = {
  linear: t => t,
  easeInQuad: t => t * t,
  easeOutQuad: t => t * (2 - t),
  easeInOutQuad: t => t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t,
  easeInCubic: t => t * t * t,
  easeOutCubic: t => (--t) * t * t + 1,
  easeInOutCubic: t => t < 0.5 ? 4 * t * t * t : (t - 1) * (2 * t - 2) * (2 * t - 2) + 1,
  easeOutElastic: t => {
    const p = 0.3;
    return Math.pow(2, -10 * t) * Math.sin((t - p / 4) * (2 * Math.PI) / p) + 1;
  },
  easeOutBounce: t => {
    if (t < 1 / 2.75) return 7.5625 * t * t;
    if (t < 2 / 2.75) return 7.5625 * (t -= 1.5 / 2.75) * t + 0.75;
    if (t < 2.5 / 2.75) return 7.5625 * (t -= 2.25 / 2.75) * t + 0.9375;
    return 7.5625 * (t -= 2.625 / 2.75) * t + 0.984375;
  }
};

// Usage
function animateWithEasing(startValue, endValue, duration, easingFn) {
  const startTime = clock.getElapsedTime();

  return function update() {
    const elapsed = clock.getElapsedTime() - startTime;
    const t = Math.min(elapsed / duration, 1);
    const eased = easingFn(t);
    return startValue + (endValue - startValue) * eased;
  };
}
```

## Performance Tips

1. **Share clips**: Same AnimationClip can be used on multiple mixers
2. **Optimize clips**: Call `clip.optimize()` to remove redundant keyframes
3. **Disable when off-screen**: Pause mixer for invisible objects
4. **Use LOD for animations**: Simpler rigs for distant characters
5. **Limit active mixers**: Each `mixer.update()` has a cost

```javascript
// Pause when not visible
if (!isInFrustum(mesh)) {
  action.paused = true;
} else {
  action.paused = false;
}

// Cache clips
const clipCache = new Map();
function getAction(name) {
  if (!clipCache.has(name)) {
    const clip = THREE.AnimationClip.findByName(animations, name);
    clipCache.set(name, mixer.clipAction(clip));
  }
  return clipCache.get(name);
}
```
