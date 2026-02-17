# Three.js WebGPU

Modern GPU API for next-generation rendering and compute shaders.

## WebGPU Renderer

```javascript
import * as THREE from 'three/webgpu';

// Check support
if (navigator.gpu) {
  const renderer = new THREE.WebGPURenderer();
  await renderer.init();

  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.setPixelRatio(window.devicePixelRatio);
  document.body.appendChild(renderer.domElement);

  // IMPORTANT: Use setAnimationLoop (not requestAnimationFrame)
  renderer.setAnimationLoop(() => {
    renderer.render(scene, camera);
  });
} else {
  console.warn('WebGPU not supported');
}
```

### Legacy Check Pattern

```javascript
import WebGPU from 'three/addons/capabilities/WebGPU.js';

if (WebGPU.isAvailable()) {
  // WebGPU supported
  const renderer = new THREE.WebGPURenderer();
} else {
  // Fallback to WebGL
  console.warn(WebGPU.getErrorMessage());
  const renderer = new THREE.WebGLRenderer();
}
```

## Benefits of WebGPU

- **Lower CPU overhead**: Better multi-threading and batching
- **Compute shaders**: GPU-accelerated computation
- **Modern API**: Better error handling and debugging
- **Unified shading**: WGSL works across platforms
- **Bindless resources**: More efficient texture/buffer management
- **Pipeline state**: Pre-compiled render pipelines

## Async Initialization

```javascript
const renderer = new THREE.WebGPURenderer();

// Initialize async (required for WebGPU)
await renderer.init();

// Or use promise
renderer.init().then(() => {
  startApp();
});
```

## Async Shader Compilation

Avoid frame drops from shader compilation.

```javascript
const renderer = new THREE.WebGPURenderer();
await renderer.init();

// Pre-compile all materials
await renderer.compileAsync(scene, camera);

// Now start rendering without hitches
renderer.setAnimationLoop(() => {
  renderer.render(scene, camera);
});
```

### Material Compilation

```javascript
// Compile specific material
await renderer.compileAsync(mesh, camera);

// Compile multiple objects
const objects = [mesh1, mesh2, mesh3];
await Promise.all(objects.map(obj => renderer.compileAsync(obj, camera)));
```

## Compute Shaders

GPU-accelerated computation without rendering.

### Using instancedArray (Preferred)

The modern way to define storage buffers for compute shaders:

```javascript
import { Fn, instancedArray, instanceIndex, deltaTime } from 'three/tsl';

const count = 1000;

// Create instanced arrays (automatically handles storage buffer creation)
const positionArray = instancedArray(count, 'vec3');
const velocityArray = instancedArray(count, 'vec3');

// Create compute shader
const computeShader = Fn(() => {
  const position = positionArray.element(instanceIndex);
  const velocity = velocityArray.element(instanceIndex);

  // Apply velocity
  position.addAssign(velocity.mul(deltaTime));
})().compute(count);

// Execute in render loop
renderer.setAnimationLoop(() => {
  renderer.compute(computeShader);
  renderer.render(scene, camera);
});
```

### Using StorageBufferAttribute (Manual Control)

For more control over buffer initialization:

```javascript
import { Fn, storage, instanceIndex, float, If } from 'three/tsl';

// Create storage buffer
const count = 10000;
const positionBuffer = new THREE.StorageBufferAttribute(count, 4);  // vec4

// Initialize buffer data
for (let i = 0; i < count; i++) {
  positionBuffer.setXYZW(
    i,
    Math.random() * 10 - 5,
    Math.random() * 10 - 5,
    Math.random() * 10 - 5,
    1
  );
}

// Create compute shader
const computeParticles = Fn(() => {
  const positions = storage(positionBuffer, 'vec4', count);
  const pos = positions.element(instanceIndex);

  // Update position
  pos.y.addAssign(float(0.01));

  // Wrap around
  If(pos.y.greaterThan(5), () => {
    pos.y.assign(-5);
  });
})();

// Create compute node
const computeNode = computeParticles.compute(count);

// Execute in render loop
renderer.setAnimationLoop(() => {
  renderer.compute(computeNode);
  renderer.render(scene, camera);
});
```

### Compute Shader Patterns

```javascript
// Particle simulation
const updateParticles = Fn(() => {
  const particles = storage(particleBuffer, 'vec4', count);
  const velocities = storage(velocityBuffer, 'vec4', count);
  const index = instanceIndex;

  const pos = particles.element(index);
  const vel = velocities.element(index);

  // Apply velocity
  pos.xyz.addAssign(vel.xyz.mul(timerDelta()));

  // Apply gravity
  vel.y.subAssign(float(9.8).mul(timerDelta()));

  // Ground collision
  If(pos.y.lessThan(0), () => {
    pos.y.assign(0);
    vel.y.mulAssign(-0.8);  // Bounce
  });
})();

// GPU sorting (parallel prefix sum)
// Note: Complex algorithms need careful implementation

// Image processing
const processImage = Fn(() => {
  const inputTex = storageTexture(inputTexture);
  const outputTex = storageTexture(outputTexture);

  const coord = vec2(instanceIndex % width, instanceIndex / width);
  const pixel = inputTex.load(coord);

  // Apply effect (e.g., grayscale)
  const gray = dot(pixel.rgb, vec3(0.299, 0.587, 0.114));
  outputTex.store(coord, vec4(gray, gray, gray, 1));
})();
```

## Storage Buffers

GPU-accessible read/write memory.

```javascript
import { storage, storageObject } from 'three/nodes';

// Simple buffer
const buffer = new THREE.StorageBufferAttribute(count * 4, 4);  // count items, 4 floats each
const bufferNode = storage(buffer, 'vec4', count);

// Access in compute shader
const element = bufferNode.element(instanceIndex);

// Structured data
// Note: Define struct via multiple buffers or pack into vec4
const positionBuffer = new THREE.StorageBufferAttribute(count, 3);
const velocityBuffer = new THREE.StorageBufferAttribute(count, 3);
const lifeBuffer = new THREE.StorageBufferAttribute(count, 1);
```

### Reading Buffer Data

```javascript
// GPU to CPU (async)
await renderer.readStorageBufferAsync(buffer);

// Access data
const array = buffer.array;
console.log('First position:', array[0], array[1], array[2]);
```

## Storage Textures

Read/write textures in compute shaders.

```javascript
import { storageTexture, Fn, instanceIndex, ivec2, vec4 } from 'three/tsl';

// Create storage texture
const texture = new THREE.DataTexture(
  new Float32Array(width * height * 4),
  width,
  height,
  THREE.RGBAFormat,
  THREE.FloatType
);
texture.needsUpdate = true;

// In compute shader - specify access type
const texRead = storageTexture(texture, 'read');        // Read-only
const texWrite = storageTexture(texture, 'write');      // Write-only
const texRW = storageTexture(texture, 'read-write');    // Both (default)

const computeShader = Fn(() => {
  const coord = ivec2(instanceIndex % width, instanceIndex / width);

  // Read
  const pixel = texRead.load(coord);

  // Write
  texWrite.store(coord, vec4(1, 0, 0, 1));
})();
```

## Node Materials with WebGPU

Same TSL API works with both WebGL and WebGPU.

```javascript
import { MeshStandardNodeMaterial, texture, normalMap, float, color } from 'three/nodes';

const material = new MeshStandardNodeMaterial();
material.colorNode = texture(diffuseTexture);
material.normalNode = normalMap(normalTexture);
material.roughnessNode = float(0.5);
material.metalnessNode = float(0.8);

// Works automatically with WebGPU renderer
const mesh = new THREE.Mesh(geometry, material);
```

## Multi-Render-Target (MRT)

Render to multiple textures simultaneously.

```javascript
// Create MRT render target
const renderTarget = new THREE.WebGLRenderTarget(width, height, {
  count: 4,  // Number of render targets
  format: THREE.RGBAFormat,
  type: THREE.FloatType
});

// Access individual textures
const albedoTexture = renderTarget.textures[0];
const normalTexture = renderTarget.textures[1];
const positionTexture = renderTarget.textures[2];
const depthTexture = renderTarget.textures[3];

// Render to MRT
renderer.setRenderTarget(renderTarget);
renderer.render(deferredScene, camera);
renderer.setRenderTarget(null);

// Use textures in second pass
compositeMaterial.uniforms.albedo.value = albedoTexture;
compositeMaterial.uniforms.normal.value = normalTexture;
```

## Indirect Drawing

GPU-generated draw calls.

```javascript
import { IndirectStorageBufferAttribute } from 'three/addons/renderers/common/IndirectStorageBufferAttribute.js';

// Create indirect buffer
// Format: [vertexCount, instanceCount, firstVertex, firstInstance, ...]
const indirectBuffer = new IndirectStorageBufferAttribute(maxDrawCalls * 4, 4);

// Compute shader fills indirect buffer (GPU culling)
const computeCulling = Fn(() => {
  const indirect = storage(indirectBuffer, 'uvec4', maxDrawCalls);
  const index = instanceIndex;

  // Frustum culling logic
  const visible = isInFrustum(boundingBoxes.element(index));

  If(visible, () => {
    const drawIndex = atomicAdd(drawCount, 1);
    indirect.element(drawIndex).assign(uvec4(
      vertexCount,
      1,  // instanceCount
      0,
      index
    ));
  });
})();

// Draw with indirect buffer
renderer.renderIndirect(mesh, indirectBuffer);
```

## Timestamp Queries

GPU timing for profiling.

```javascript
// Create timestamp query
const timestampQuery = renderer.createTimestampQuery();

// Measure render time
timestampQuery.begin();
renderer.render(scene, camera);
timestampQuery.end();

// Get results (async)
timestampQuery.getResult().then((duration) => {
  console.log(`GPU render time: ${duration.toFixed(2)}ms`);
});
```

## WGSL (WebGPU Shading Language)

Native shader language for WebGPU.

```wgsl
// Vertex shader
@vertex
fn vertexMain(
  @location(0) position: vec3f,
  @location(1) normal: vec3f,
  @location(2) uv: vec2f
) -> VertexOutput {
  var output: VertexOutput;
  output.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * vec4f(position, 1.0);
  output.normal = (uniforms.normalMatrix * vec4f(normal, 0.0)).xyz;
  output.uv = uv;
  return output;
}

// Fragment shader
@fragment
fn fragmentMain(input: VertexOutput) -> @location(0) vec4f {
  let color = textureSample(diffuseTexture, textureSampler, input.uv);
  return color;
}

// Compute shader
@compute @workgroup_size(64)
fn computeMain(@builtin(global_invocation_id) global_id: vec3u) {
  let index = global_id.x;
  if (index >= arrayLength(&positions)) {
    return;
  }

  var pos = positions[index];
  pos.y += sin(uniforms.time + f32(index)) * 0.01;
  positions[index] = pos;
}
```

### Using Raw WGSL

```javascript
// Note: Three.js prefers TSL, but raw WGSL is possible via custom materials
// TSL compiles to WGSL automatically for WebGPU renderer
```

## WebGPU-Specific Features

### Texture Compression

```javascript
// BC7 compression (desktop, high quality)
const texture = new THREE.CompressedTexture(
  mipmaps,
  width,
  height,
  THREE.RGBA_BPTC_Format
);

// ASTC compression (mobile, Quest)
// THREE.RGBA_ASTC_4x4_Format, etc.

// Use KTX2Loader for universal support
import { KTX2Loader } from 'three/addons/loaders/KTX2Loader.js';

const ktx2Loader = new KTX2Loader()
  .setTranscoderPath('/basis/');

// WebGPU requires async detectSupport
await ktx2Loader.detectSupport(renderer);

ktx2Loader.load('texture.ktx2', (texture) => {
  material.map = texture;
});
```

### Depth Textures

```javascript
const depthTexture = new THREE.DepthTexture(width, height);
depthTexture.type = THREE.FloatType;  // 32-bit depth
depthTexture.format = THREE.DepthFormat;

const renderTarget = new THREE.WebGLRenderTarget(width, height, {
  depthTexture: depthTexture
});
```

### Stencil Buffer

```javascript
const renderTarget = new THREE.WebGLRenderTarget(width, height, {
  stencilBuffer: true
});

// Use stencil in material
material.stencilWrite = true;
material.stencilFunc = THREE.AlwaysStencilFunc;
material.stencilRef = 1;
material.stencilZPass = THREE.ReplaceStencilOp;
```

## Migration from WebGL

Most Three.js code works unchanged.

```javascript
// WebGL
import * as THREE from 'three';
const renderer = new THREE.WebGLRenderer();

// WebGPU (import from different path)
import * as THREE from 'three/webgpu';
const renderer = new THREE.WebGPURenderer();
await renderer.init();
```

### Key Differences

1. **Async initialization**: `await renderer.init()` required
2. **Shader materials**: Use TSL node materials instead of raw GLSL
3. **Compute shaders**: Only available in WebGPU
4. **Animation loop**: Use `setAnimationLoop`, not `requestAnimationFrame`

### Custom Shaders Migration

```javascript
// WebGL (GLSL)
const material = new THREE.ShaderMaterial({
  uniforms: { time: { value: 0 } },
  vertexShader: `...GLSL...`,
  fragmentShader: `...GLSL...`
});

// WebGPU (TSL)
import { MeshBasicNodeMaterial, uniform, sin, uv } from 'three/nodes';

const timeUniform = uniform(0);
const material = new MeshBasicNodeMaterial();
material.colorNode = sin(uv().x.mul(10).add(timeUniform));

// Update
timeUniform.value = clock.getElapsedTime();
```

## Fallback Strategy

```javascript
import * as THREE_WEBGPU from 'three/webgpu';
import * as THREE_WEBGL from 'three';

let THREE;
let renderer;

async function initRenderer() {
  if (navigator.gpu) {
    try {
      THREE = THREE_WEBGPU;
      renderer = new THREE.WebGPURenderer();
      await renderer.init();
      console.log('Using WebGPU');
      return;
    } catch (e) {
      console.warn('WebGPU init failed:', e);
    }
  }

  // Fallback to WebGL
  THREE = THREE_WEBGL;
  renderer = new THREE.WebGLRenderer();
  console.log('Using WebGL fallback');
}

await initRenderer();
```

## Browser Support (2025)

- Chrome 113+
- Edge 113+
- Safari 18+ (macOS Sonoma+, iOS 18+)
- Firefox (in development)

```javascript
// Feature detection
const webgpuSupported = 'gpu' in navigator;

// More detailed check
async function checkWebGPU() {
  if (!navigator.gpu) return false;

  const adapter = await navigator.gpu.requestAdapter();
  if (!adapter) return false;

  const device = await adapter.requestDevice();
  return !!device;
}
```

## Performance Comparison

WebGPU advantages:
- **CPU reduction**: 2-4x fewer CPU cycles for draw calls
- **Better batching**: More efficient state changes
- **Compute shaders**: Offload work to GPU
- **Pipeline caching**: Pre-compiled render states

WebGL might be faster for:
- Simple scenes (WebGPU overhead not worth it)
- Legacy browsers
- Quick prototypes

## Debugging WebGPU

### Inspector

```javascript
import { Inspector } from 'three/addons/renderers/common/extras/Inspector.js';

// Attach inspector to renderer
renderer.inspector = new Inspector(renderer);
```

### Error Logging

```javascript
// Enable shader error logging
renderer.debug.checkShaderErrors = true;

// WebGPU adapter info
const adapter = await navigator.gpu.requestAdapter();
console.log('GPU:', adapter.name);
console.log('Features:', [...adapter.features]);
console.log('Limits:', adapter.limits);
```

## Best Practices

1. **Use TSL**: Node materials are the future, portable across WebGL/WebGPU
2. **Async compile**: Pre-compile materials to avoid hitches
3. **Compute shaders**: Use for particle systems, physics, post-processing
4. **Storage buffers**: Efficient data sharing between CPU/GPU
5. **Test both**: Ensure WebGL fallback works
6. **Profile**: Use timestamp queries to find bottlenecks
7. **Minimize transfers**: Keep data on GPU when possible
