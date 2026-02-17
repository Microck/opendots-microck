# Three.js Cameras

Camera types, projection, viewport, and camera techniques.

## Camera Types

| Camera | Use Case |
|--------|----------|
| PerspectiveCamera | Most common, simulates human eye |
| OrthographicCamera | No perspective distortion, 2D/isometric |
| ArrayCamera | Multiple viewports (split-screen) |
| CubeCamera | Environment maps for reflections |
| StereoCamera | VR/stereoscopic rendering |

## PerspectiveCamera

Standard perspective projection like human vision.

```javascript
// PerspectiveCamera(fov, aspect, near, far)
const camera = new THREE.PerspectiveCamera(
  75,                                        // Field of view (degrees, vertical)
  window.innerWidth / window.innerHeight,    // Aspect ratio
  0.1,                                       // Near clipping plane
  1000                                       // Far clipping plane
);

// Position camera
camera.position.set(0, 5, 10);
camera.lookAt(0, 0, 0);

// After changing fov, aspect, near, or far:
camera.updateProjectionMatrix();
```

### FOV and Zoom

```javascript
// Narrow FOV = telephoto/zoom effect
camera.fov = 30;
camera.updateProjectionMatrix();

// Wide FOV = wide-angle/fisheye effect
camera.fov = 90;
camera.updateProjectionMatrix();

// Zoom (affects field of view)
camera.zoom = 2;  // 2x zoom
camera.updateProjectionMatrix();

// Calculate FOV to fit object
function getFovToFitObject(camera, object, offset = 1.5) {
  const box = new THREE.Box3().setFromObject(object);
  const size = box.getSize(new THREE.Vector3());
  const maxDim = Math.max(size.x, size.y, size.z);

  const distance = camera.position.distanceTo(object.position);
  const fov = 2 * Math.atan(maxDim / (2 * distance)) * (180 / Math.PI);

  return fov * offset;
}
```

### Aspect Ratio

```javascript
// Update on window resize
function onResize() {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
}

// Custom aspect for render target
camera.aspect = renderTarget.width / renderTarget.height;
camera.updateProjectionMatrix();
```

### Near/Far Clipping

```javascript
// Near plane - objects closer than this are clipped
camera.near = 0.1;

// Far plane - objects farther than this are clipped
camera.far = 1000;

// For very large scenes (avoid z-fighting)
camera.near = 1;
camera.far = 100000;

// For small/detailed scenes
camera.near = 0.001;
camera.far = 100;

camera.updateProjectionMatrix();
```

## OrthographicCamera

No perspective distortion. Good for 2D games, CAD, isometric views.

```javascript
// OrthographicCamera(left, right, top, bottom, near, far)
const aspect = window.innerWidth / window.innerHeight;
const frustumSize = 10;

const camera = new THREE.OrthographicCamera(
  frustumSize * aspect / -2,   // left
  frustumSize * aspect / 2,    // right
  frustumSize / 2,             // top
  frustumSize / -2,            // bottom
  0.1,                         // near
  1000                         // far
);

camera.position.set(10, 10, 10);
camera.lookAt(0, 0, 0);
```

### Orthographic Resize

```javascript
function onResize() {
  const aspect = window.innerWidth / window.innerHeight;

  camera.left = frustumSize * aspect / -2;
  camera.right = frustumSize * aspect / 2;
  camera.top = frustumSize / 2;
  camera.bottom = frustumSize / -2;

  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
}
```

### Orthographic Zoom

```javascript
// Zoom by changing frustum size
function setZoom(newFrustumSize) {
  frustumSize = newFrustumSize;
  const aspect = window.innerWidth / window.innerHeight;

  camera.left = frustumSize * aspect / -2;
  camera.right = frustumSize * aspect / 2;
  camera.top = frustumSize / 2;
  camera.bottom = frustumSize / -2;

  camera.updateProjectionMatrix();
}

// Or use built-in zoom
camera.zoom = 2;  // 2x zoom
camera.updateProjectionMatrix();
```

## ArrayCamera

Multiple viewports with sub-cameras (split-screen).

```javascript
const cameras = [];
const size = { width: 0.5, height: 0.5 };

for (let y = 0; y < 2; y++) {
  for (let x = 0; x < 2; x++) {
    const subcamera = new THREE.PerspectiveCamera(40, 1, 0.1, 100);
    subcamera.viewport = new THREE.Vector4(
      x * size.width,
      y * size.height,
      size.width,
      size.height
    );
    subcamera.position.set(x * 10 - 5, 5, y * 10 - 5);
    subcamera.lookAt(0, 0, 0);
    cameras.push(subcamera);
  }
}

const arrayCamera = new THREE.ArrayCamera(cameras);

// Render
renderer.render(scene, arrayCamera);
```

## CubeCamera

Renders environment maps from a point in space.

```javascript
const cubeRenderTarget = new THREE.WebGLCubeRenderTarget(256, {
  generateMipmaps: true,
  minFilter: THREE.LinearMipmapLinearFilter,
});

const cubeCamera = new THREE.CubeCamera(0.1, 1000, cubeRenderTarget);
scene.add(cubeCamera);

// Use for reflections
reflectiveMaterial.envMap = cubeRenderTarget.texture;

// Update in animation loop (expensive!)
function animate() {
  reflectiveObject.visible = false;
  cubeCamera.position.copy(reflectiveObject.position);
  cubeCamera.update(renderer, scene);
  reflectiveObject.visible = true;

  renderer.render(scene, camera);
}
```

## StereoCamera

For VR/stereoscopic rendering.

```javascript
const stereoCamera = new THREE.StereoCamera();
stereoCamera.aspect = 0.5;  // Half width per eye
stereoCamera.eyeSep = 0.064;  // Eye separation

function render() {
  const size = renderer.getSize(new THREE.Vector2());

  // Left eye
  renderer.setScissorTest(true);
  renderer.setScissor(0, 0, size.width / 2, size.height);
  renderer.setViewport(0, 0, size.width / 2, size.height);
  renderer.render(scene, stereoCamera.cameraL);

  // Right eye
  renderer.setScissor(size.width / 2, 0, size.width / 2, size.height);
  renderer.setViewport(size.width / 2, 0, size.width / 2, size.height);
  renderer.render(scene, stereoCamera.cameraR);

  renderer.setScissorTest(false);
}
```

## Camera Positioning

### Look At

```javascript
// Look at point
camera.lookAt(0, 0, 0);
camera.lookAt(new THREE.Vector3(0, 0, 0));

// Look at object
camera.lookAt(mesh.position);

// Smooth look at (interpolate)
const targetLookAt = new THREE.Vector3();
const currentLookAt = new THREE.Vector3();

function animate() {
  targetLookAt.copy(targetObject.position);
  currentLookAt.lerp(targetLookAt, 0.05);
  camera.lookAt(currentLookAt);
}
```

### Orbit Around Point

```javascript
const target = new THREE.Vector3(0, 0, 0);
const radius = 10;
let angle = 0;

function animate() {
  angle += 0.01;

  camera.position.x = target.x + Math.cos(angle) * radius;
  camera.position.z = target.z + Math.sin(angle) * radius;
  camera.lookAt(target);
}
```

### Follow Object

```javascript
const offset = new THREE.Vector3(0, 5, 10);

function animate() {
  // Direct follow
  camera.position.copy(target.position).add(offset);
  camera.lookAt(target.position);

  // Smooth follow
  const desiredPosition = target.position.clone().add(offset);
  camera.position.lerp(desiredPosition, 0.05);
  camera.lookAt(target.position);
}
```

### First-Person Camera

```javascript
camera.position.copy(player.position);
camera.position.y += 1.7;  // Eye height

camera.rotation.order = 'YXZ';  // Important for FPS
camera.rotation.y = player.rotation.y;  // Yaw
camera.rotation.x = lookUpDown;  // Pitch (clamp to avoid flip)
```

## Camera Animation

### Smooth Transitions

```javascript
import { gsap } from 'gsap';

function moveCameraTo(position, lookAt, duration = 1) {
  gsap.to(camera.position, {
    x: position.x,
    y: position.y,
    z: position.z,
    duration: duration,
    ease: 'power2.inOut',
    onUpdate: () => camera.lookAt(lookAt),
  });
}
```

### Camera Path

```javascript
const curve = new THREE.CatmullRomCurve3([
  new THREE.Vector3(-10, 5, 10),
  new THREE.Vector3(0, 3, 10),
  new THREE.Vector3(10, 5, 10),
  new THREE.Vector3(10, 5, -10),
]);

let progress = 0;

function animate() {
  progress += 0.001;
  if (progress > 1) progress = 0;

  const point = curve.getPointAt(progress);
  const tangent = curve.getTangentAt(progress);

  camera.position.copy(point);
  camera.lookAt(point.clone().add(tangent));
}
```

### Camera Shake

```javascript
const originalPosition = camera.position.clone();
let shakeIntensity = 0;

function shake(intensity, duration) {
  shakeIntensity = intensity;
  setTimeout(() => shakeIntensity = 0, duration);
}

function animate() {
  if (shakeIntensity > 0) {
    camera.position.x = originalPosition.x + (Math.random() - 0.5) * shakeIntensity;
    camera.position.y = originalPosition.y + (Math.random() - 0.5) * shakeIntensity;
    camera.position.z = originalPosition.z + (Math.random() - 0.5) * shakeIntensity;
  } else {
    camera.position.copy(originalPosition);
  }
}
```

## Frustum and Projection

### Get Frustum

```javascript
const frustum = new THREE.Frustum();
const projScreenMatrix = new THREE.Matrix4();

projScreenMatrix.multiplyMatrices(
  camera.projectionMatrix,
  camera.matrixWorldInverse
);
frustum.setFromProjectionMatrix(projScreenMatrix);

// Check if object is in view
if (frustum.intersectsObject(mesh)) {
  // Object is visible
}

// Check if point is in view
if (frustum.containsPoint(point)) {
  // Point is visible
}
```

### World to Screen Coordinates

```javascript
function toScreenPosition(object, camera) {
  const vector = new THREE.Vector3();

  object.updateMatrixWorld();
  vector.setFromMatrixPosition(object.matrixWorld);
  vector.project(camera);

  const widthHalf = window.innerWidth / 2;
  const heightHalf = window.innerHeight / 2;

  return {
    x: (vector.x * widthHalf) + widthHalf,
    y: -(vector.y * heightHalf) + heightHalf,
  };
}
```

### Screen to World Coordinates

```javascript
function toWorldPosition(screenX, screenY, camera, targetZ = 0) {
  const vector = new THREE.Vector3(
    (screenX / window.innerWidth) * 2 - 1,
    -(screenY / window.innerHeight) * 2 + 1,
    0.5
  );

  vector.unproject(camera);

  const dir = vector.sub(camera.position).normalize();
  const distance = (targetZ - camera.position.z) / dir.z;

  return camera.position.clone().add(dir.multiplyScalar(distance));
}
```

### Ray from Camera

```javascript
const raycaster = new THREE.Raycaster();
const mouse = new THREE.Vector2();

function onMouseMove(event) {
  mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
  mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;
}

function checkIntersection() {
  raycaster.setFromCamera(mouse, camera);
  const intersects = raycaster.intersectObjects(scene.children);

  if (intersects.length > 0) {
    // intersects[0].point - hit point
    // intersects[0].object - hit object
  }
}
```

## Viewport

### Custom Viewport

```javascript
// Render to portion of screen
const width = window.innerWidth;
const height = window.innerHeight;

// Bottom-left quarter
renderer.setViewport(0, 0, width / 2, height / 2);
renderer.setScissor(0, 0, width / 2, height / 2);
renderer.setScissorTest(true);
renderer.render(scene, camera1);

// Top-right quarter
renderer.setViewport(width / 2, height / 2, width / 2, height / 2);
renderer.setScissor(width / 2, height / 2, width / 2, height / 2);
renderer.render(scene, camera2);

// Reset
renderer.setScissorTest(false);
renderer.setViewport(0, 0, width, height);
```

### Picture-in-Picture

```javascript
function render() {
  // Main view
  renderer.setViewport(0, 0, window.innerWidth, window.innerHeight);
  renderer.render(scene, mainCamera);

  // Mini-map (top-right corner)
  const pipWidth = 200;
  const pipHeight = 150;
  renderer.setViewport(
    window.innerWidth - pipWidth - 10,
    window.innerHeight - pipHeight - 10,
    pipWidth,
    pipHeight
  );
  renderer.setScissor(
    window.innerWidth - pipWidth - 10,
    window.innerHeight - pipHeight - 10,
    pipWidth,
    pipHeight
  );
  renderer.setScissorTest(true);
  renderer.render(scene, topDownCamera);
  renderer.setScissorTest(false);
}
```

## Camera Helpers

```javascript
// Camera helper (visualize frustum)
const helper = new THREE.CameraHelper(camera);
scene.add(helper);

// Update helper after camera changes
helper.update();
```
