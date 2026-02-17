# Three.js Performance Optimization

Instancing, LOD, culling, batching, profiling, memory management, and mobile optimization.

## Draw Call Optimization

Each `renderer.render()` iterates all visible objects. Fewer draw calls = better performance.

### InstancedMesh

Render thousands of identical geometries in one draw call.

```javascript
const geometry = new THREE.BoxGeometry(1, 1, 1);
const material = new THREE.MeshStandardMaterial({ color: 0x00ff00 });
const count = 10000;

const mesh = new THREE.InstancedMesh(geometry, material, count);
scene.add(mesh);

// Set transforms
const matrix = new THREE.Matrix4();
const position = new THREE.Vector3();
const quaternion = new THREE.Quaternion();
const scale = new THREE.Vector3(1, 1, 1);

for (let i = 0; i < count; i++) {
  position.set(
    Math.random() * 100 - 50,
    Math.random() * 100 - 50,
    Math.random() * 100 - 50
  );

  quaternion.setFromEuler(new THREE.Euler(
    Math.random() * Math.PI,
    Math.random() * Math.PI,
    0
  ));

  matrix.compose(position, quaternion, scale);
  mesh.setMatrixAt(i, matrix);
}

mesh.instanceMatrix.needsUpdate = true;
```

### Per-Instance Colors

```javascript
// Enable instance colors
const mesh = new THREE.InstancedMesh(geometry, material, count);

for (let i = 0; i < count; i++) {
  mesh.setColorAt(i, new THREE.Color(Math.random(), Math.random(), Math.random()));
}

mesh.instanceColor.needsUpdate = true;
```

### Dynamic Instance Updates

```javascript
// Update specific instance
function updateInstance(index, position, rotation) {
  const matrix = new THREE.Matrix4();
  const quaternion = new THREE.Quaternion().setFromEuler(rotation);
  const scale = new THREE.Vector3(1, 1, 1);

  matrix.compose(position, quaternion, scale);
  mesh.setMatrixAt(index, matrix);
  mesh.instanceMatrix.needsUpdate = true;
}

// Hide instance (scale to zero)
function hideInstance(index) {
  const matrix = new THREE.Matrix4();
  matrix.makeScale(0, 0, 0);
  mesh.setMatrixAt(index, matrix);
  mesh.instanceMatrix.needsUpdate = true;
}

// Reduce instance count
mesh.count = visibleCount;  // Only render first N instances
```

### InstancedMesh with Object3D Helper

Use Object3D as a transform helper for cleaner code:

```javascript
const count = 1000;
const mesh = new THREE.InstancedMesh(geometry, material, count);
const dummy = new THREE.Object3D();
const color = new THREE.Color();

for (let i = 0; i < count; i++) {
  dummy.position.set(
    Math.random() * 100 - 50,
    Math.random() * 60 - 30,
    Math.random() * 80 - 40
  );
  dummy.rotation.set(
    Math.random() * Math.PI * 2,
    Math.random() * Math.PI * 2,
    Math.random() * Math.PI * 2
  );
  dummy.scale.setScalar(Math.random() * 2 + 1);
  dummy.updateMatrix();

  mesh.setMatrixAt(i, dummy.matrix);
  mesh.setColorAt(i, color.setHSL(i / count, 1, 0.5));
}

mesh.instanceMatrix.needsUpdate = true;
mesh.instanceColor.needsUpdate = true;

// Compute bounds for frustum culling
mesh.computeBoundingBox();
mesh.computeBoundingSphere();
```

### BatchedMesh (Three.js r159+)

Multiple geometries in one draw call. Better than InstancedMesh for rendering different geometries together.

```javascript
// Calculate buffer sizes based on geometries
const box = new THREE.BoxGeometry(1, 1, 1);
const sphere = new THREE.SphereGeometry(1, 12, 12);

const material = new THREE.MeshBasicMaterial({ color: 0x00ff00 });

// Initialize: (maxInstanceCount, maxVertexCount, maxIndexCount, material)
const batchedMesh = new THREE.BatchedMesh(10, 5000, 10000, material);

// Add geometries - returns geometry IDs
const boxGeomId = batchedMesh.addGeometry(box);
const sphereGeomId = batchedMesh.addGeometry(sphere);

// Add instances of geometries - returns instance IDs
const boxInst1 = batchedMesh.addInstance(boxGeomId);
const boxInst2 = batchedMesh.addInstance(boxGeomId);
const sphereInst1 = batchedMesh.addInstance(sphereGeomId);

// Set transforms and colors per instance
const matrix = new THREE.Matrix4();

matrix.setPosition(0, 0, 0);
batchedMesh.setMatrixAt(boxInst1, matrix);
batchedMesh.setColorAt(boxInst1, new THREE.Color(0xff0000));

matrix.setPosition(2, 0, 0);
batchedMesh.setMatrixAt(boxInst2, matrix);
batchedMesh.setColorAt(boxInst2, new THREE.Color(0x00ff00));

matrix.setPosition(4, 0, 0);
batchedMesh.setMatrixAt(sphereInst1, matrix);
batchedMesh.setColorAt(sphereInst1, new THREE.Color(0x0000ff));

scene.add(batchedMesh);
```

### BatchedMesh Per-Object Culling

```javascript
// Disable full-mesh culling for dynamic objects
batchedMesh.frustumCulled = false;

// Enable per-instance frustum culling (better for spread-out objects)
batchedMesh.perObjectFrustumCulled = true;
```

### Geometry Merging

Combine static geometries into one.

```javascript
import { mergeGeometries, mergeVertices } from 'three/addons/utils/BufferGeometryUtils.js';

// Merge multiple geometries
const geometries = [];
objects.forEach(obj => {
  const geom = obj.geometry.clone();
  geom.applyMatrix4(obj.matrixWorld);
  geometries.push(geom);
});

const mergedGeometry = mergeGeometries(geometries, true);
const mergedMesh = new THREE.Mesh(mergedGeometry, material);

// Dispose originals
geometries.forEach(g => g.dispose());
objects.forEach(obj => scene.remove(obj));
scene.add(mergedMesh);

// Merge duplicate vertices
const optimized = mergeVertices(geometry, tolerance);
```

## Level of Detail (LOD)

Switch detail based on distance.

```javascript
const lod = new THREE.LOD();

// High detail (close)
const highGeom = new THREE.IcosahedronGeometry(10, 4);  // 2560 faces
const highMesh = new THREE.Mesh(highGeom, material);
lod.addLevel(highMesh, 0);

// Medium detail
const medGeom = new THREE.IcosahedronGeometry(10, 2);  // 320 faces
const medMesh = new THREE.Mesh(medGeom, material);
lod.addLevel(medMesh, 50);

// Low detail (far)
const lowGeom = new THREE.IcosahedronGeometry(10, 1);  // 80 faces
const lowMesh = new THREE.Mesh(lowGeom, material);
lod.addLevel(lowMesh, 100);

// Billboard (very far)
const sprite = new THREE.Sprite(spriteMaterial);
sprite.scale.set(20, 20, 1);
lod.addLevel(sprite, 200);

scene.add(lod);

// Update in animation loop
function animate() {
  lod.update(camera);
  renderer.render(scene, camera);
}
```

### Automatic LOD Generation

```javascript
import { SimplifyModifier } from 'three/addons/modifiers/SimplifyModifier.js';

const modifier = new SimplifyModifier();

function createLOD(originalGeometry, levels) {
  const lod = new THREE.LOD();

  levels.forEach(({ ratio, distance }) => {
    const simplified = modifier.modify(
      originalGeometry.clone(),
      Math.floor(originalGeometry.attributes.position.count * ratio)
    );
    const mesh = new THREE.Mesh(simplified, material);
    lod.addLevel(mesh, distance);
  });

  return lod;
}

const lod = createLOD(geometry, [
  { ratio: 1.0, distance: 0 },
  { ratio: 0.5, distance: 50 },
  { ratio: 0.25, distance: 100 },
  { ratio: 0.1, distance: 200 }
]);
```

## Frustum Culling

Objects outside camera view are automatically not rendered.

```javascript
// Enabled by default
mesh.frustumCulled = true;

// Disable for always-visible objects (skyboxes, etc.)
mesh.frustumCulled = false;

// Manual frustum testing
const frustum = new THREE.Frustum();
const projScreenMatrix = new THREE.Matrix4();

function updateFrustum() {
  camera.updateMatrixWorld();
  projScreenMatrix.multiplyMatrices(
    camera.projectionMatrix,
    camera.matrixWorldInverse
  );
  frustum.setFromProjectionMatrix(projScreenMatrix);
}

function isVisible(object) {
  const box = new THREE.Box3().setFromObject(object);
  return frustum.intersectsBox(box);
}
```

### Custom Bounding Volumes

```javascript
// Force compute bounding sphere (for accurate culling)
geometry.computeBoundingSphere();

// Override bounding volume
mesh.geometry.boundingSphere = new THREE.Sphere(
  new THREE.Vector3(0, 0, 0),
  customRadius
);
```

## Occlusion Culling

Don't render objects hidden behind others.

```javascript
// Three.js doesn't have built-in occlusion culling
// Options:
// 1. Use physics raycasting to check visibility
// 2. Divide scene into rooms/sectors
// 3. Use GPU occlusion queries (advanced)

// Simple room-based culling
class Room {
  constructor(bounds, objects) {
    this.bounds = bounds;  // Box3
    this.objects = objects;
    this.visible = true;
  }

  updateVisibility(camera) {
    this.visible = frustum.intersectsBox(this.bounds);
    this.objects.forEach(obj => {
      obj.visible = this.visible;
    });
  }
}
```

## Texture Optimization

### Texture Size

```javascript
// Use power-of-2 dimensions: 256, 512, 1024, 2048, 4096
// Smaller = faster loading, less memory

// Check max texture size
const maxSize = renderer.capabilities.maxTextureSize;  // Usually 4096-16384

// Mobile: prefer 1024 or 2048
// Desktop: up to 4096
```

### Texture Compression

```javascript
import { KTX2Loader } from 'three/addons/loaders/KTX2Loader.js';

const ktx2Loader = new KTX2Loader()
  .setTranscoderPath('/basis/')
  .detectSupport(renderer);

ktx2Loader.load('texture.ktx2', (texture) => {
  material.map = texture;
});

// Compression formats:
// - Basis/KTX2: Universal, transcodes to native formats
// - ETC2: Android/WebGL 2
// - ASTC: Modern mobile (iOS, Android)
// - BC7/BPTC: Desktop (high quality)
// - S3TC/DXT: Desktop (legacy)
```

### Mipmaps

```javascript
// Enabled by default for power-of-2 textures
texture.generateMipmaps = true;

// Filtering
texture.minFilter = THREE.LinearMipmapLinearFilter;  // Best quality
texture.magFilter = THREE.LinearFilter;

// Anisotropic filtering (better at angles)
texture.anisotropy = renderer.capabilities.getMaxAnisotropy();
// Use lower values for performance: 4, 8, or 16
```

### Texture Atlas

Combine multiple textures into one.

```javascript
// Create atlas (e.g., 4x4 = 16 textures)
const atlas = textureLoader.load('atlas.png');

// UV offset per sub-texture
const materials = [];
for (let i = 0; i < 16; i++) {
  const material = new THREE.MeshBasicMaterial({ map: atlas.clone() });
  material.map.repeat.set(0.25, 0.25);
  material.map.offset.set((i % 4) * 0.25, Math.floor(i / 4) * 0.25);
  materials.push(material);
}
```

## Material Optimization

### Share Materials

```javascript
// Bad: new material per mesh
meshes.forEach(mesh => {
  mesh.material = new THREE.MeshStandardMaterial({ color: 0x00ff00 });
});

// Good: share one material
const sharedMaterial = new THREE.MeshStandardMaterial({ color: 0x00ff00 });
meshes.forEach(mesh => {
  mesh.material = sharedMaterial;
});
```

### Simpler Materials

```javascript
// Performance ranking (fastest to slowest):
// 1. MeshBasicMaterial (no lighting)
// 2. MeshLambertMaterial (simple lighting)
// 3. MeshPhongMaterial (specular)
// 4. MeshStandardMaterial (PBR)
// 5. MeshPhysicalMaterial (advanced PBR)

// Use simplest material that looks acceptable
const distantMaterial = new THREE.MeshLambertMaterial({ color: 0x888888 });
const closeMaterial = new THREE.MeshStandardMaterial({
  color: 0x888888,
  roughness: 0.5,
  metalness: 0.5
});
```

### Reduce Shader Complexity

```javascript
// Disable unnecessary features
const material = new THREE.MeshStandardMaterial({
  map: texture,
  normalMap: null,        // Skip normal mapping
  roughnessMap: null,     // Use uniform roughness
  metalnessMap: null,     // Use uniform metalness
  envMap: null,           // Skip environment reflections
  aoMap: null,            // Skip ambient occlusion
  flatShading: false,     // Smooth shading is usually faster
});
```

## Shadow Optimization

```javascript
// Reduce shadow map resolution
light.shadow.mapSize.width = 1024;   // Default is 512
light.shadow.mapSize.height = 1024;  // Use 512-2048

// Tighten shadow camera frustum
light.shadow.camera.near = 1;
light.shadow.camera.far = 50;
light.shadow.camera.left = -20;
light.shadow.camera.right = 20;
light.shadow.camera.top = 20;
light.shadow.camera.bottom = -20;
light.shadow.camera.updateProjectionMatrix();

// Use helper to visualize
const helper = new THREE.CameraHelper(light.shadow.camera);
scene.add(helper);

// Cheaper shadow type
renderer.shadowMap.type = THREE.BasicShadowMap;     // Fastest, hard edges
renderer.shadowMap.type = THREE.PCFShadowMap;       // Soft, medium cost
renderer.shadowMap.type = THREE.PCFSoftShadowMap;   // Softest, expensive
renderer.shadowMap.type = THREE.VSMShadowMap;       // Variance, for specific cases

// Limit shadow casters
mesh.castShadow = false;  // Disable for small/distant objects
mesh.receiveShadow = false;

// Bake static shadows into lightmaps instead
```

## Lighting Optimization

```javascript
// Limit light count (3-5 max)
// Each light = additional shader calculations

// Use baked lighting for static scenes
// Create lightmaps in Blender, apply as:
material.lightMap = lightmapTexture;
material.lightMapIntensity = 1;

// Use light probes for indirect lighting
const lightProbe = new THREE.LightProbe();
scene.add(lightProbe);
// Generate from environment map

// Disable physically correct lights if not needed
renderer.useLegacyLights = true;  // Deprecated but sometimes faster
```

## Geometry Optimization

### Reduce Polygon Count

```javascript
import { SimplifyModifier } from 'three/addons/modifiers/SimplifyModifier.js';

const modifier = new SimplifyModifier();
const simplified = modifier.modify(
  geometry,
  Math.floor(geometry.attributes.position.count * 0.5)  // 50% reduction
);
```

### Indexed Geometry

```javascript
// Check if indexed
if (geometry.index) {
  console.log('Indexed geometry');
}

// Convert to indexed (shares vertices)
import { mergeVertices } from 'three/addons/utils/BufferGeometryUtils.js';
const indexed = mergeVertices(geometry);
```

### Dispose Unused

```javascript
// Dispose geometry
geometry.dispose();

// Dispose material and textures
material.dispose();
material.map?.dispose();
material.normalMap?.dispose();
material.roughnessMap?.dispose();

// Dispose render targets
renderTarget.dispose();

// Remove from scene
scene.remove(mesh);
```

## Object Pooling

Reuse objects instead of creating/destroying.

```javascript
class ObjectPool {
  constructor(factory, initialSize = 10) {
    this.factory = factory;
    this.pool = [];
    this.active = new Set();

    for (let i = 0; i < initialSize; i++) {
      this.pool.push(factory());
    }
  }

  get() {
    const obj = this.pool.pop() || this.factory();
    this.active.add(obj);
    return obj;
  }

  release(obj) {
    if (this.active.has(obj)) {
      this.active.delete(obj);
      this.pool.push(obj);
    }
  }

  releaseAll() {
    this.active.forEach(obj => this.pool.push(obj));
    this.active.clear();
  }
}

// Usage
const bulletPool = new ObjectPool(() => {
  const bullet = new THREE.Mesh(bulletGeometry, bulletMaterial);
  return bullet;
}, 100);

function fireBullet() {
  const bullet = bulletPool.get();
  bullet.position.copy(gun.position);
  bullet.visible = true;
  scene.add(bullet);
}

function recycleBullet(bullet) {
  bullet.visible = false;
  scene.remove(bullet);
  bulletPool.release(bullet);
}
```

## Animation Optimization

```javascript
// Pause invisible animations
if (!isInFrustum(mesh)) {
  action.paused = true;
} else {
  action.paused = false;
}

// Share animation clips
const sharedClip = clips[0];
meshes.forEach(mesh => {
  const mixer = new THREE.AnimationMixer(mesh);
  mixer.clipAction(sharedClip).play();  // Same clip, different mixer
});

// Optimize clips
clip.optimize();  // Remove redundant keyframes

// Use skeletal LOD
// - Full skeleton when close
// - Reduced skeleton when far
// - No animation (static pose) when very far
```

## Render Optimization

### Render on Demand

```javascript
let needsRender = true;

function requestRender() {
  needsRender = true;
}

function animate() {
  requestAnimationFrame(animate);

  if (needsRender) {
    renderer.render(scene, camera);
    needsRender = false;
  }
}

// Request render when something changes
controls.addEventListener('change', requestRender);
```

### Pixel Ratio

```javascript
// Limit pixel ratio on high-DPI displays
const maxPixelRatio = 2;
renderer.setPixelRatio(Math.min(window.devicePixelRatio, maxPixelRatio));

// Lower on mobile
if (isMobile) {
  renderer.setPixelRatio(1);
}
```

### Render Target Resolution

```javascript
// Lower resolution for effects
const scale = 0.5;  // Half resolution
const renderTarget = new THREE.WebGLRenderTarget(
  window.innerWidth * scale,
  window.innerHeight * scale
);
```

## Profiling

### Stats.js

```javascript
import Stats from 'three/addons/libs/stats.module.js';

const stats = new Stats();
document.body.appendChild(stats.dom);

function animate() {
  stats.begin();

  // ... rendering ...

  stats.end();
  requestAnimationFrame(animate);
}
```

### Renderer Info

```javascript
// After rendering
console.log('Render info:', renderer.info);
// {
//   render: { calls, triangles, points, lines, frame },
//   memory: { geometries, textures },
//   programs: [...shader programs]
// }

// Reset per frame
renderer.info.reset();
```

### Performance Timeline

```javascript
// Mark rendering
performance.mark('render-start');
renderer.render(scene, camera);
performance.mark('render-end');
performance.measure('render', 'render-start', 'render-end');

// View in DevTools Performance tab
```

### GPU Timing (WebGL 2)

```javascript
const ext = renderer.getContext().getExtension('EXT_disjoint_timer_query_webgl2');
if (ext) {
  const query = renderer.getContext().createQuery();
  gl.beginQuery(ext.TIME_ELAPSED_EXT, query);
  renderer.render(scene, camera);
  gl.endQuery(ext.TIME_ELAPSED_EXT);

  // Check result later (async)
  setTimeout(() => {
    const available = gl.getQueryParameter(query, gl.QUERY_RESULT_AVAILABLE);
    if (available) {
      const elapsed = gl.getQueryParameter(query, gl.QUERY_RESULT);
      console.log('GPU time:', elapsed / 1000000, 'ms');
    }
  }, 100);
}
```

## Mobile Optimization

```javascript
const isMobile = /iPhone|iPad|Android/i.test(navigator.userAgent);

if (isMobile) {
  // Lower resolution
  renderer.setPixelRatio(1);

  // Simpler shadows
  renderer.shadowMap.type = THREE.BasicShadowMap;
  light.shadow.mapSize.set(512, 512);

  // Fewer lights
  scene.remove(fillLight);

  // Simpler materials
  material.envMapIntensity = 0;

  // Lower geometry detail
  // Use LOD with more aggressive distances

  // Disable post-processing
  bloomPass.enabled = false;
  ssaoPass.enabled = false;

  // Reduce animation update rate
  mixer.timeScale = 0.5;
}
```

## Memory Management

```javascript
// Track memory
function logMemory() {
  console.log('Geometries:', renderer.info.memory.geometries);
  console.log('Textures:', renderer.info.memory.textures);
}

// Dispose everything properly
function disposeObject(obj) {
  if (obj.geometry) {
    obj.geometry.dispose();
  }

  if (obj.material) {
    if (Array.isArray(obj.material)) {
      obj.material.forEach(disposeMaterial);
    } else {
      disposeMaterial(obj.material);
    }
  }
}

function disposeMaterial(material) {
  material.dispose();

  // Dispose all textures
  for (const key of Object.keys(material)) {
    const value = material[key];
    if (value && typeof value === 'object' && 'minFilter' in value) {
      value.dispose();
    }
  }
}

function disposeScene(scene) {
  scene.traverse(disposeObject);
  renderer.dispose();
}
```

## Performance Checklist

1. **Draw Calls**
   - [ ] Use InstancedMesh for repeated geometry
   - [ ] Merge static geometries
   - [ ] Share materials between meshes

2. **Geometry**
   - [ ] Use LOD for complex models
   - [ ] Simplify distant geometry
   - [ ] Use indexed geometry

3. **Textures**
   - [ ] Use compressed textures (KTX2)
   - [ ] Use appropriate sizes
   - [ ] Use texture atlases

4. **Shadows**
   - [ ] Limit shadow map resolution
   - [ ] Tighten shadow camera frustum
   - [ ] Limit shadow-casting objects

5. **Lighting**
   - [ ] Limit light count (3-5)
   - [ ] Use baked lighting for static scenes
   - [ ] Use light probes

6. **Rendering**
   - [ ] Limit pixel ratio
   - [ ] Render on demand when possible
   - [ ] Lower resolution for effects

7. **Memory**
   - [ ] Dispose unused resources
   - [ ] Use object pooling
   - [ ] Monitor memory usage
