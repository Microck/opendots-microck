# Three.js Fundamentals

Core concepts: Scene, Renderer, Object3D hierarchy, coordinate system, and essential patterns.

## Scene

Container for all 3D objects, lights, and cameras.

```javascript
const scene = new THREE.Scene();

// Background options
scene.background = new THREE.Color(0x000000);        // Solid color
scene.background = texture;                          // 2D texture
scene.background = cubeTexture;                      // Cubemap skybox
scene.backgroundBlurriness = 0.5;                    // Blur background (0-1)
scene.backgroundIntensity = 1.0;                     // Background brightness
scene.backgroundRotation.y = Math.PI;                // Rotate background

// Environment map (affects all PBR materials)
scene.environment = envMap;
scene.environmentIntensity = 1.0;
scene.environmentRotation.y = Math.PI;

// Fog
scene.fog = new THREE.Fog(0xffffff, 1, 100);         // Linear fog (color, near, far)
scene.fog = new THREE.FogExp2(0xffffff, 0.02);       // Exponential fog (color, density)

// Scene graph traversal
scene.traverse((child) => {
  if (child.isMesh) {
    child.castShadow = true;
  }
});

// Find objects
const mesh = scene.getObjectByName('myMesh');
const meshes = scene.getObjectsByProperty('type', 'Mesh');
```

## WebGLRenderer

```javascript
const renderer = new THREE.WebGLRenderer({
  canvas: document.querySelector('#canvas'),  // Existing canvas (optional)
  antialias: true,                            // Smooth edges
  alpha: true,                                // Transparent background
  powerPreference: 'high-performance',        // GPU hint
  preserveDrawingBuffer: true,                // For screenshots
  stencil: false,                             // Disable if not needed
  depth: true,                                // Depth buffer
});

// Size and pixel ratio
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));  // Cap at 2 for performance

// Color management (see Color Space section below)
renderer.outputColorSpace = THREE.SRGBColorSpace;

// Tone mapping (HDR to LDR)
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.0;
// Options: NoToneMapping, LinearToneMapping, ReinhardToneMapping,
//          CineonToneMapping, ACESFilmicToneMapping, AgXToneMapping, NeutralToneMapping

// Shadows
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
// Options: BasicShadowMap, PCFShadowMap, PCFSoftShadowMap, VSMShadowMap

// Clear color
renderer.setClearColor(0x000000, 1);  // color, alpha

// Render
renderer.render(scene, camera);

// Info (for debugging)
console.log(renderer.info.render.calls);     // Draw calls
console.log(renderer.info.memory.geometries); // Geometry count
console.log(renderer.info.memory.textures);   // Texture count
```

## Object3D

Base class for all 3D objects. Mesh, Group, Light, Camera all extend Object3D.

```javascript
const obj = new THREE.Object3D();

// Position
obj.position.set(x, y, z);
obj.position.x = 5;

// Rotation (Euler angles in radians)
obj.rotation.set(x, y, z);
obj.rotation.order = 'XYZ';  // Rotation order matters

// Quaternion (alternative rotation)
obj.quaternion.setFromAxisAngle(axis, angle);
obj.quaternion.setFromEuler(euler);

// Scale
obj.scale.set(x, y, z);
obj.scale.setScalar(2);  // Uniform scale

// Look at target
obj.lookAt(targetVector);
obj.lookAt(x, y, z);

// Hierarchy
obj.add(child);
obj.remove(child);
obj.removeFromParent();
obj.parent;      // Parent object
obj.children;    // Array of children

// Visibility
obj.visible = false;

// Layers (for selective rendering/raycasting)
obj.layers.set(1);        // Set to layer 1 only
obj.layers.enable(2);     // Add layer 2
obj.layers.disable(0);    // Remove layer 0
obj.layers.test(camera.layers);  // Check if visible to camera

// World transforms
const worldPos = new THREE.Vector3();
obj.getWorldPosition(worldPos);
obj.getWorldQuaternion(worldQuat);
obj.getWorldDirection(worldDir);
obj.getWorldScale(worldScale);

// Local to world / world to local
obj.localToWorld(localVector);
obj.worldToLocal(worldVector);

// Matrix
obj.matrixAutoUpdate = true;   // Auto-update matrix (default)
obj.updateMatrix();            // Manual update
obj.updateMatrixWorld(true);   // Update world matrix recursively
obj.matrixWorld;               // World transform matrix

// User data (store custom properties)
obj.userData = { id: 123, type: 'enemy' };

// Name (for debugging/finding)
obj.name = 'myObject';
```

## Group

Empty container for organizing objects.

```javascript
const group = new THREE.Group();
group.add(mesh1);
group.add(mesh2);
scene.add(group);

// Transform entire group
group.position.x = 5;
group.rotation.y = Math.PI / 4;
group.scale.setScalar(2);

// All children move with group
```

## Mesh

Combines geometry and material.

```javascript
const mesh = new THREE.Mesh(geometry, material);

// Properties
mesh.geometry;
mesh.material;

// Shadows
mesh.castShadow = true;
mesh.receiveShadow = true;

// Frustum culling (skip if outside camera view)
mesh.frustumCulled = true;  // Default

// Render order (higher = rendered later, for transparency)
mesh.renderOrder = 10;

// Multiple materials
const mesh = new THREE.Mesh(geometry, [material1, material2, material3]);
// Each material applies to a geometry group
```

## Coordinate System

Three.js uses a **right-handed coordinate system**:
- **+X** points right
- **+Y** points up
- **+Z** points toward viewer (out of screen)

```javascript
// Axes helper
const axesHelper = new THREE.AxesHelper(5);
scene.add(axesHelper);  // Red=X, Green=Y, Blue=Z

// Grid helper
const gridHelper = new THREE.GridHelper(10, 10);  // size, divisions
scene.add(gridHelper);

// Arrow helper
const arrow = new THREE.ArrowHelper(
  direction,      // Vector3 (normalized)
  origin,         // Vector3
  length,         // number
  color,          // hex
  headLength,     // number (optional)
  headWidth       // number (optional)
);
```

## Animation Loop

```javascript
// Basic loop
function animate() {
  requestAnimationFrame(animate);
  renderer.render(scene, camera);
}
animate();

// With Clock (frame-rate independent)
const clock = new THREE.Clock();

function animate() {
  const delta = clock.getDelta();      // Seconds since last frame
  const elapsed = clock.getElapsedTime();  // Total seconds

  // Frame-rate independent movement
  mesh.rotation.y += delta * 0.5;  // 0.5 radians per second

  requestAnimationFrame(animate);
  renderer.render(scene, camera);
}
animate();

// Using setAnimationLoop (preferred for WebXR)
renderer.setAnimationLoop((time) => {
  // time is in milliseconds
  renderer.render(scene, camera);
});

// Stop animation
renderer.setAnimationLoop(null);
```

## Resize Handler

```javascript
function onWindowResize() {
  const width = window.innerWidth;
  const height = window.innerHeight;

  camera.aspect = width / height;
  camera.updateProjectionMatrix();

  renderer.setSize(width, height);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
}

window.addEventListener('resize', onWindowResize);

// For container-based sizing
function onContainerResize() {
  const container = document.getElementById('container');
  const width = container.clientWidth;
  const height = container.clientHeight;

  camera.aspect = width / height;
  camera.updateProjectionMatrix();

  renderer.setSize(width, height);
}

// ResizeObserver for containers
const resizeObserver = new ResizeObserver(onContainerResize);
resizeObserver.observe(container);
```

## Disposal & Cleanup

```javascript
function dispose() {
  // Dispose geometries
  mesh.geometry.dispose();

  // Dispose materials
  if (Array.isArray(mesh.material)) {
    mesh.material.forEach(m => disposeMaterial(m));
  } else {
    disposeMaterial(mesh.material);
  }

  // Remove from scene
  scene.remove(mesh);

  // Dispose renderer
  renderer.dispose();
  renderer.forceContextLoss();
}

function disposeMaterial(material) {
  // Dispose textures
  const textureProperties = [
    'map', 'normalMap', 'roughnessMap', 'metalnessMap',
    'aoMap', 'emissiveMap', 'displacementMap', 'alphaMap',
    'envMap', 'lightMap', 'bumpMap', 'specularMap'
  ];

  textureProperties.forEach(prop => {
    if (material[prop]) {
      material[prop].dispose();
    }
  });

  material.dispose();
}

// Full scene cleanup
function disposeScene(scene) {
  scene.traverse((object) => {
    if (object.geometry) {
      object.geometry.dispose();
    }
    if (object.material) {
      if (Array.isArray(object.material)) {
        object.material.forEach(m => disposeMaterial(m));
      } else {
        disposeMaterial(object.material);
      }
    }
  });

  scene.clear();
}
```

## Color Space Management

Three.js uses linear color space internally for physically correct lighting calculations. Final output is converted to sRGB for display.

```javascript
// Renderer output (display color space)
renderer.outputColorSpace = THREE.SRGBColorSpace;  // Default, correct for monitors

// Texture color spaces
const colorTexture = textureLoader.load('diffuse.jpg');
colorTexture.colorSpace = THREE.SRGBColorSpace;  // Color/diffuse/emissive textures

const normalMap = textureLoader.load('normal.jpg');
normalMap.colorSpace = THREE.NoColorSpace;  // Data textures (normal, roughness, AO)

// Manual color creation with color space
const color = new THREE.Color();
color.setHex(0xff0000, THREE.SRGBColorSpace);  // Hex in sRGB

// Convert between spaces
color.convertSRGBToLinear();  // sRGB to Linear
color.convertLinearToSRGB();  // Linear to sRGB
```

### Color Space Guidelines

| Texture Type | Color Space |
|--------------|-------------|
| Diffuse/Albedo | SRGBColorSpace |
| Emissive | SRGBColorSpace |
| Environment Map | SRGBColorSpace |
| Normal Map | NoColorSpace |
| Roughness | NoColorSpace |
| Metalness | NoColorSpace |
| AO | NoColorSpace |
| Displacement | NoColorSpace |

```javascript
// GLTFLoader handles color spaces automatically
// For manual textures:
function setTextureColorSpace(material) {
  if (material.map) material.map.colorSpace = THREE.SRGBColorSpace;
  if (material.emissiveMap) material.emissiveMap.colorSpace = THREE.SRGBColorSpace;
  // Data maps stay as NoColorSpace (default)
}
```

## Loading Manager

Track loading progress across multiple loaders.

```javascript
const manager = new THREE.LoadingManager();

manager.onStart = (url, loaded, total) => {
  console.log(`Started: ${url} (${loaded}/${total})`);
};

manager.onProgress = (url, loaded, total) => {
  const progress = (loaded / total) * 100;
  console.log(`Progress: ${progress.toFixed(1)}%`);
  updateProgressBar(progress);
};

manager.onLoad = () => {
  console.log('All assets loaded!');
  hideLoadingScreen();
  startApp();
};

manager.onError = (url) => {
  console.error(`Error loading: ${url}`);
};

// Use with loaders
const textureLoader = new THREE.TextureLoader(manager);
const gltfLoader = new GLTFLoader(manager);

// All managed loaders contribute to progress
textureLoader.load('texture1.jpg');
textureLoader.load('texture2.jpg');
gltfLoader.load('model.glb');
```

## Debug Helpers

```javascript
// Bounding box helper
const boxHelper = new THREE.BoxHelper(mesh, 0xffff00);
scene.add(boxHelper);
boxHelper.update();  // Call after mesh changes

// Box3 helper (from Box3)
const box = new THREE.Box3().setFromObject(mesh);
const box3Helper = new THREE.Box3Helper(box, 0xffff00);
scene.add(box3Helper);

// Plane helper
const planeHelper = new THREE.PlaneHelper(plane, 5, 0xffff00);
scene.add(planeHelper);

// Polar grid helper
const polarGrid = new THREE.PolarGridHelper(10, 16, 8, 64);
scene.add(polarGrid);

// Stats (FPS counter)
import Stats from 'three/addons/libs/stats.module.js';

const stats = new Stats();
document.body.appendChild(stats.dom);

function animate() {
  stats.begin();
  // ... render
  stats.end();
  requestAnimationFrame(animate);
}
```

## Common Patterns

### Screenshot

```javascript
function screenshot() {
  renderer.render(scene, camera);
  const dataURL = renderer.domElement.toDataURL('image/png');

  const link = document.createElement('a');
  link.download = 'screenshot.png';
  link.href = dataURL;
  link.click();
}
```

### Object Picking (Quick)

```javascript
const raycaster = new THREE.Raycaster();
const pointer = new THREE.Vector2();

function onPointerMove(event) {
  pointer.x = (event.clientX / window.innerWidth) * 2 - 1;
  pointer.y = -(event.clientY / window.innerHeight) * 2 + 1;
}

function checkIntersection() {
  raycaster.setFromCamera(pointer, camera);
  const intersects = raycaster.intersectObjects(scene.children);

  if (intersects.length > 0) {
    const object = intersects[0].object;
    // Handle intersection
  }
}
```

### Center Object at Origin

```javascript
function centerObject(object) {
  const box = new THREE.Box3().setFromObject(object);
  const center = box.getCenter(new THREE.Vector3());
  object.position.sub(center);
}
```

### Fit Object to View

```javascript
function fitCameraToObject(camera, object, offset = 1.5) {
  const box = new THREE.Box3().setFromObject(object);
  const size = box.getSize(new THREE.Vector3());
  const center = box.getCenter(new THREE.Vector3());

  const maxDim = Math.max(size.x, size.y, size.z);
  const fov = camera.fov * (Math.PI / 180);
  const distance = (maxDim / 2) / Math.tan(fov / 2) * offset;

  camera.position.copy(center);
  camera.position.z += distance;
  camera.lookAt(center);
  camera.updateProjectionMatrix();
}
```
