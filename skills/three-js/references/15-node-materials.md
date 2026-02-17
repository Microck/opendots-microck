# Three.js Node Materials (TSL)

Three Shading Language - node-based material system for custom shaders.

## What is TSL?

Three Shading Language (TSL) is a modern, node-based system for creating materials and shaders:
- Functional composition of shader nodes
- Type-safe node graph
- Unified output: GLSL (WebGL) and WGSL (WebGPU)
- No manual shader code required
- Automatic optimization

## Import Paths

```javascript
// Preferred import path for TSL (Three.js r167+)
import { Fn, uniform, texture, uv, ... } from 'three/tsl';

// Legacy import path (still works)
import { ... } from 'three/nodes';

// WebGPU build includes TSL by default
import * as THREE from 'three/webgpu';
```

## Basic Node Material

```javascript
import * as THREE from 'three/webgpu';
import {
  MeshStandardNodeMaterial,
  color,
  texture,
  normalMap,
  float,
  uv
} from 'three/tsl';

const material = new MeshStandardNodeMaterial();

// Set base color
material.colorNode = color(0xff0000);

// Or use texture
material.colorNode = texture(colorTexture);

// Combine nodes
material.colorNode = texture(colorTexture).mul(color(0xffffff));

// Normal mapping
material.normalNode = normalMap(normalTexture);

// PBR properties
material.roughnessNode = float(0.5);
material.metalnessNode = float(0.8);
```

## Node Material Types

```javascript
import {
  MeshBasicNodeMaterial,
  MeshStandardNodeMaterial,
  MeshPhysicalNodeMaterial,
  PointsNodeMaterial,
  LineBasicNodeMaterial,
  SpriteNodeMaterial,
  NodeMaterial
} from 'three/nodes';

// Basic (unlit)
const basic = new MeshBasicNodeMaterial();
basic.colorNode = colorNode;

// Standard PBR
const standard = new MeshStandardNodeMaterial();
standard.colorNode = colorNode;
standard.roughnessNode = roughnessNode;
standard.metalnessNode = metalnessNode;
standard.normalNode = normalMapNode;

// Physical (advanced PBR)
const physical = new MeshPhysicalNodeMaterial();
physical.colorNode = colorNode;
physical.clearcoatNode = clearcoatNode;
physical.clearcoatRoughnessNode = clearcoatRoughnessNode;
physical.transmissionNode = transmissionNode;
physical.thicknessNode = thicknessNode;
physical.iorNode = iorNode;
physical.sheenNode = sheenNode;
physical.iridescenceNode = iridescenceNode;

// Points
const points = new PointsNodeMaterial();
points.colorNode = colorNode;
points.sizeNode = sizeNode;

// Lines
const lines = new LineBasicNodeMaterial();
lines.colorNode = colorNode;

// Sprite
const sprite = new SpriteNodeMaterial();
sprite.colorNode = colorNode;
```

## Input Nodes

### Attributes

```javascript
import {
  attribute,
  positionLocal,
  positionWorld,
  positionView,
  normalLocal,
  normalWorld,
  normalView,
  uv,
  color as vertexColor,
  tangentLocal
} from 'three/nodes';

// Geometry attributes
const posNode = positionLocal;      // Local space position
const normalNode = normalLocal;     // Local space normal
const uvNode = uv();                // UV coordinates
const uv2Node = uv(1);              // Second UV channel
const vertexColorNode = vertexColor; // Vertex colors

// Custom attribute
const customAttr = attribute('customAttribute');

// Transformed positions
const worldPos = positionWorld;
const viewPos = positionView;
```

### Uniforms

```javascript
import { uniform, uniformArray } from 'three/tsl';

// Single values
const timeNode = uniform(0);           // float
const colorUniform = uniform(new THREE.Color(1, 0, 0));
const vector3Uniform = uniform(new THREE.Vector3(1, 2, 3));
const matrixUniform = uniform(new THREE.Matrix4());

// Update at runtime
timeNode.value = clock.getElapsedTime();

// Array uniforms
const colorsUniform = uniformArray([
  new THREE.Color(1, 0, 0),
  new THREE.Color(0, 1, 0),
  new THREE.Color(0, 0, 1)
]);
```

### Uniform Update Best Practices

```javascript
// GOOD: Mutate existing value (no recompilation)
colorUniform.value.setRGB(0, 1, 0);
vector3Uniform.value.set(1, 2, 3);

// BAD: Assign new object (triggers shader recompilation!)
colorUniform.value = new THREE.Color(0, 1, 0);  // Avoid!
vector3Uniform.value = new THREE.Vector3(1, 2, 3);  // Avoid!

// For numbers, direct assignment is fine
timeNode.value = 1.5;  // OK
```

### Textures

```javascript
import { texture, cubeTexture, equirectUV } from 'three/nodes';

// 2D texture
const colorNode = texture(diffuseTexture);
const colorNode = texture(diffuseTexture, uv());  // Explicit UV

// With transform
const colorNode = texture(diffuseTexture, uv().mul(2));  // Tiled 2x

// Cube texture
const envNode = cubeTexture(cubeMapTexture);

// Equirectangular to cubemap UV
const envNode = texture(equirectTexture, equirectUV(reflectVector));
```

## Math Nodes

### Arithmetic

```javascript
import { add, sub, mul, div, pow, mod, abs, sign, floor, ceil, fract } from 'three/nodes';

// Basic operations
const result = add(a, b);      // a + b
const result = sub(a, b);      // a - b
const result = mul(a, b);      // a * b
const result = div(a, b);      // a / b
const result = pow(a, b);      // a^b
const result = mod(a, b);      // a % b

// Method syntax (equivalent)
const result = a.add(b);
const result = a.sub(b);
const result = a.mul(b);
const result = a.div(b);

// Chaining
const result = a.add(b).mul(c).sub(d);

// Unary
const result = abs(a);
const result = sign(a);
const result = floor(a);
const result = ceil(a);
const result = fract(a);
```

### Trigonometry

```javascript
import { sin, cos, tan, asin, acos, atan, atan2 } from 'three/nodes';

const result = sin(angle);
const result = cos(angle);
const result = tan(angle);
const result = asin(value);
const result = acos(value);
const result = atan(value);
const result = atan2(y, x);
```

### Vector Operations

```javascript
import { length, normalize, dot, cross, reflect, refract, distance } from 'three/nodes';

const len = length(vector);
const norm = normalize(vector);
const d = dot(a, b);
const c = cross(a, b);
const r = reflect(incident, normal);
const t = refract(incident, normal, eta);
const dist = distance(a, b);
```

### Interpolation

```javascript
import { mix, smoothstep, step, clamp, min, max } from 'three/nodes';

// Linear interpolation
const result = mix(a, b, t);  // lerp

// Smooth interpolation
const result = smoothstep(edge0, edge1, x);

// Step function
const result = step(edge, x);  // 0 if x < edge, else 1

// Clamping
const result = clamp(x, minVal, maxVal);
const result = min(a, b);
const result = max(a, b);
```

## Creating Nodes

### Value Nodes

```javascript
import { float, int, vec2, vec3, vec4, mat3, mat4, color } from 'three/nodes';

// Scalars
const f = float(1.5);
const i = int(5);

// Vectors
const v2 = vec2(1, 2);
const v3 = vec3(1, 2, 3);
const v4 = vec4(1, 2, 3, 4);

// From existing nodes
const v3FromXYZ = vec3(xNode, yNode, zNode);

// Color
const c = color(0xff0000);
const c = color(1, 0, 0);

// Matrices
const m3 = mat3();
const m4 = mat4();
```

### Swizzling

```javascript
const v = vec3(1, 2, 3);

// Component access
const x = v.x;
const y = v.y;
const z = v.z;

// Swizzling
const xy = v.xy;         // vec2(1, 2)
const zyx = v.zyx;       // vec3(3, 2, 1)
const xyzx = v.xyzx;     // vec4(1, 2, 3, 1)

// Alternative names
const r = v.r;           // Same as x (for colors)
const rgb = v.rgb;
```

## Custom Functions

```javascript
import { Fn, float, vec3, If, Loop, Break } from 'three/nodes';

// Define custom function
const customColor = Fn(([uv, time]) => {
  const r = sin(uv.x.mul(10).add(time));
  const g = cos(uv.y.mul(10).add(time));
  const b = float(0.5);
  return vec3(r, g, b);
});

// Use in material
material.colorNode = customColor(uvNode, timeNode);

// With conditionals
const conditionalColor = Fn(([value]) => {
  return If(value.greaterThan(0.5), () => {
    return vec3(1, 0, 0);
  }).Else(() => {
    return vec3(0, 0, 1);
  });
});

// With loops
const sumFunction = Fn(([count]) => {
  const sum = float(0).toVar();
  Loop({ start: int(0), end: count }, ({ i }) => {
    sum.addAssign(float(i));
  });
  return sum;
});
```

## Built-in Nodes

### Time and Animation

```javascript
import { timerLocal, timerGlobal, timerDelta, oscSine, oscSquare, oscTriangle, oscSawtooth } from 'three/nodes';

// Time
const time = timerLocal();      // Seconds since start
const time = timerGlobal();     // Global time
const delta = timerDelta();     // Frame delta time

// Oscillators
const sine = oscSine(timerLocal());           // 0 to 1 sine wave
const square = oscSquare(timerLocal());       // 0 or 1
const triangle = oscTriangle(timerLocal());   // 0 to 1 to 0
const sawtooth = oscSawtooth(timerLocal());   // 0 to 1 linear

// With frequency
const fastSine = oscSine(timerLocal(2));      // 2 Hz
```

### Procedural Patterns

```javascript
import { checker, hash, noise, voronoi } from 'three/nodes';

// Checker pattern
const check = checker(uv().mul(10));

// Hash (pseudo-random)
const random = hash(positionLocal);

// Noise
const n = noise(positionLocal.mul(5));

// Voronoi
const v = voronoi(uv().mul(5));
```

### Camera and View

```javascript
import {
  cameraPosition,
  cameraProjectionMatrix,
  cameraViewMatrix,
  cameraFar,
  cameraNear,
  viewportResolution
} from 'three/nodes';

const camPos = cameraPosition;
const resolution = viewportResolution;
```

## Common Effects

### Fresnel Effect

```javascript
import { normalView, positionView, dot, pow, float } from 'three/nodes';

const viewDirection = positionView.normalize();
const fresnel = pow(
  float(1).sub(dot(normalView, viewDirection.negate())),
  float(3)
);

material.colorNode = mix(baseColor, edgeColor, fresnel);
```

### Vertex Displacement

```javascript
import { positionLocal, normalLocal, sin, timerLocal } from 'three/nodes';

// Wave displacement
const time = timerLocal();
const displacement = sin(positionLocal.y.mul(10).add(time)).mul(0.1);
material.positionNode = positionLocal.add(normalLocal.mul(displacement));
```

### UV Animation

```javascript
import { uv, timerLocal, sin, vec2 } from 'three/nodes';

const time = timerLocal();

// Scroll
const scrolledUV = uv().add(vec2(time.mul(0.1), 0));

// Wave distortion
const waveUV = uv().add(vec2(sin(uv().y.mul(10).add(time)).mul(0.02), 0));

material.colorNode = texture(diffuseTexture, scrolledUV);
```

### Dissolve Effect

```javascript
import { uv, texture, float, smoothstep, step, If, discard } from 'three/nodes';

const noiseValue = texture(noiseTexture, uv()).r;
const progress = uniform(0);  // 0 to 1

const dissolve = Fn(() => {
  If(noiseValue.lessThan(progress), () => {
    discard();
  });

  // Edge glow
  const edge = smoothstep(progress, progress.add(0.1), noiseValue);
  const edgeColor = vec3(1, 0.5, 0);
  const baseColor = texture(diffuseTexture, uv());

  return mix(edgeColor, baseColor.rgb, edge);
});

material.colorNode = dissolve();
```

### Hologram

```javascript
import { positionLocal, normalView, cameraPosition, timerLocal, sin, pow, dot } from 'three/nodes';

const hologram = Fn(() => {
  const time = timerLocal();

  // Scanlines
  const scanline = sin(positionLocal.y.mul(100).add(time.mul(5))).mul(0.5).add(0.5);
  const scanlineEffect = pow(scanline, float(2)).mul(0.3).add(0.7);

  // Fresnel
  const viewDir = cameraPosition.sub(positionLocal).normalize();
  const fresnel = pow(float(1).sub(dot(normalView, viewDir).abs()), float(2));

  // Flicker
  const flicker = sin(time.mul(20)).mul(0.02).add(0.98);

  const baseColor = vec3(0, 1, 0.8);
  const alpha = fresnel.add(0.2).mul(scanlineEffect).mul(flicker);

  return vec4(baseColor, alpha);
});

material.colorNode = hologram().rgb;
material.opacityNode = hologram().a;
material.transparent = true;
```

### Toon Shading

```javascript
import { normalWorld, normalize, dot, step, float, vec3 } from 'three/nodes';

const lightDirection = uniform(new THREE.Vector3(1, 1, 1)).normalize();

const toon = Fn(() => {
  const intensity = dot(normalWorld, lightDirection);

  // Quantize to bands
  const band1 = step(float(0.95), intensity).mul(0.3);
  const band2 = step(float(0.5), intensity).mul(0.25);
  const band3 = step(float(0.25), intensity).mul(0.25);
  const base = float(0.2);

  const shade = base.add(band1).add(band2).add(band3);
  return vec3(shade, shade, shade);
});

material.colorNode = toon().mul(color(0xff6600));
```

## Vertex Output

```javascript
// Custom vertex position
material.positionNode = modifiedPositionNode;

// Custom vertex color (passed to fragment)
material.colorNode = vertexColorNode;

// Custom varyings via Fn
const customVarying = Fn(() => {
  // Computed in vertex shader, interpolated to fragment
  return positionLocal.mul(0.5).add(0.5);
});
```

## Post-Processing with Nodes

```javascript
import { pass, gaussianBlur, bloom, dof } from 'three/nodes';
import { PostProcessing } from 'three/addons/renderers/common/PostProcessing.js';

// Create scene pass
const scenePass = pass(scene, camera);
const color = scenePass.getTextureNode();

// Apply effects
let result = color;
result = bloom(result, 0.5, 0.4, 0.85);  // strength, radius, threshold
result = gaussianBlur(result, vec2(2, 2));  // blur amount

// Create post-processing
const postProcessing = new PostProcessing(renderer);
postProcessing.outputNode = result;

// Render
function animate() {
  postProcessing.render();
}
```

## Compute Shaders (WebGPU)

```javascript
import { compute, storage, instanceIndex, Fn, If } from 'three/nodes';

// Storage buffer
const particleBuffer = new THREE.StorageBufferAttribute(particleCount * 4, 4);

// Compute shader
const updateParticles = Fn(() => {
  const particles = storage(particleBuffer, 'vec4', particleCount);
  const index = instanceIndex;
  const particle = particles.element(index);

  // Update position
  const velocity = particle.w;
  particle.y.addAssign(velocity.mul(timerDelta()));

  // Reset if out of bounds
  If(particle.y.greaterThan(10), () => {
    particle.y.assign(-10);
  });
})();

// Create compute node
const computeNode = updateParticles.compute(particleCount);

// Execute in render loop
function animate() {
  renderer.compute(computeNode);
  renderer.render(scene, camera);
}
```

## Migration from ShaderMaterial

```javascript
// Old way (ShaderMaterial)
const material = new THREE.ShaderMaterial({
  uniforms: {
    time: { value: 0 },
    color: { value: new THREE.Color(0xff0000) }
  },
  vertexShader: `
    varying vec2 vUv;
    void main() {
      vUv = uv;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
  `,
  fragmentShader: `
    uniform float time;
    uniform vec3 color;
    varying vec2 vUv;
    void main() {
      gl_FragColor = vec4(color * sin(vUv.x * 10.0 + time), 1.0);
    }
  `
});

// Update
material.uniforms.time.value = t;

// New way (Node Material)
const timeNode = uniform(0);
const colorNode = uniform(new THREE.Color(0xff0000));

const material = new MeshBasicNodeMaterial();
material.colorNode = colorNode.mul(sin(uv().x.mul(10).add(timeNode)));

// Update
timeNode.value = t;
```

## When to Use Node Materials

**Use Node Materials when:**
- Creating complex procedural materials
- Need both WebGL and WebGPU support
- Want composable, reusable shader components
- Working with compute shaders (WebGPU)
- Building visual shader editors
- Need type-safe shader code

**Stick with ShaderMaterial when:**
- Porting existing GLSL code
- Need very specific GLSL optimizations
- Working with legacy projects
- Simple one-off effects

## Performance Tips

1. **Reuse nodes**: Same node can be used multiple times
2. **Cache textures**: Don't create new texture nodes per frame
3. **Use uniforms**: For values that change per frame
4. **Avoid branching**: Use mix/step instead of If when possible
5. **Profile**: Node materials can be less optimal than hand-written GLSL
