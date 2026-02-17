# Three.js Controls

Camera controls: OrbitControls, FlyControls, PointerLockControls, and more.

## OrbitControls

Most common camera control. Rotate, zoom, pan around a target.

```javascript
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

const controls = new OrbitControls(camera, renderer.domElement);

// Target (point camera orbits around)
controls.target.set(0, 0, 0);

// Update in animation loop
function animate() {
  controls.update();  // Required if damping or auto-rotate enabled
  renderer.render(scene, camera);
  requestAnimationFrame(animate);
}
```

### OrbitControls Options

```javascript
// Damping (smooth motion)
controls.enableDamping = true;
controls.dampingFactor = 0.05;

// Auto-rotate
controls.autoRotate = true;
controls.autoRotateSpeed = 2.0;  // 30 seconds per orbit at 60fps

// Rotation limits
controls.minPolarAngle = 0;                // Vertical angle min (0 = top)
controls.maxPolarAngle = Math.PI;          // Vertical angle max (PI = bottom)
controls.minAzimuthAngle = -Infinity;      // Horizontal angle min
controls.maxAzimuthAngle = Infinity;       // Horizontal angle max

// Zoom limits
controls.minDistance = 1;    // PerspectiveCamera
controls.maxDistance = 100;
controls.minZoom = 0.5;      // OrthographicCamera
controls.maxZoom = 10;

// Enable/disable
controls.enableRotate = true;
controls.enableZoom = true;
controls.enablePan = true;

// Mouse buttons
controls.mouseButtons = {
  LEFT: THREE.MOUSE.ROTATE,
  MIDDLE: THREE.MOUSE.DOLLY,
  RIGHT: THREE.MOUSE.PAN
};

// Touch gestures
controls.touches = {
  ONE: THREE.TOUCH.ROTATE,
  TWO: THREE.TOUCH.DOLLY_PAN
};

// Rotation speed
controls.rotateSpeed = 1.0;
controls.zoomSpeed = 1.0;
controls.panSpeed = 1.0;

// Screen space panning (vs world space)
controls.screenSpacePanning = true;

// Keyboard
controls.enableKeys = true;
controls.keys = {
  LEFT: 'ArrowLeft',
  UP: 'ArrowUp',
  RIGHT: 'ArrowRight',
  BOTTOM: 'ArrowDown'
};
```

### OrbitControls Events

```javascript
controls.addEventListener('change', () => {
  // Render when camera changes (for non-animated scenes)
  renderer.render(scene, camera);
});

controls.addEventListener('start', () => {
  console.log('Interaction started');
});

controls.addEventListener('end', () => {
  console.log('Interaction ended');
});
```

### Save/Restore OrbitControls State

```javascript
// Save state
controls.saveState();

// Reset to saved state
controls.reset();

// Custom state
const savedState = {
  target: controls.target.clone(),
  position: camera.position.clone()
};

function restoreState() {
  controls.target.copy(savedState.target);
  camera.position.copy(savedState.position);
  controls.update();
}
```

## MapControls

Like OrbitControls but optimized for top-down map views.

```javascript
import { MapControls } from 'three/addons/controls/MapControls.js';

const controls = new MapControls(camera, renderer.domElement);

// Typically used with perspective camera looking down
camera.position.set(0, 50, 0);
camera.lookAt(0, 0, 0);

controls.enableRotate = false;  // Optional: disable rotation for pure 2D
controls.screenSpacePanning = false;  // Pan in world space
```

## TrackballControls

360-degree rotation without gimbal lock.

```javascript
import { TrackballControls } from 'three/addons/controls/TrackballControls.js';

const controls = new TrackballControls(camera, renderer.domElement);

controls.rotateSpeed = 2.0;
controls.zoomSpeed = 1.2;
controls.panSpeed = 0.8;

controls.staticMoving = false;  // true = no damping
controls.dynamicDampingFactor = 0.2;

// Must update every frame
function animate() {
  controls.update();
  renderer.render(scene, camera);
  requestAnimationFrame(animate);
}
```

## FlyControls

Fly through scene like a spaceship.

```javascript
import { FlyControls } from 'three/addons/controls/FlyControls.js';

const controls = new FlyControls(camera, renderer.domElement);

controls.movementSpeed = 10;
controls.rollSpeed = Math.PI / 6;
controls.dragToLook = true;  // Require drag for rotation
controls.autoForward = false;

// Must pass delta time
const clock = new THREE.Clock();

function animate() {
  const delta = clock.getDelta();
  controls.update(delta);
  renderer.render(scene, camera);
  requestAnimationFrame(animate);
}
```

## FirstPersonControls

Similar to FlyControls but grounded.

```javascript
import { FirstPersonControls } from 'three/addons/controls/FirstPersonControls.js';

const controls = new FirstPersonControls(camera, renderer.domElement);

controls.movementSpeed = 10;
controls.lookSpeed = 0.1;
controls.lookVertical = true;
controls.constrainVertical = true;
controls.verticalMin = Math.PI / 4;
controls.verticalMax = Math.PI * 3 / 4;

// Must pass delta time
const clock = new THREE.Clock();

function animate() {
  controls.update(clock.getDelta());
  renderer.render(scene, camera);
  requestAnimationFrame(animate);
}
```

## PointerLockControls

First-person controls with mouse lock.

```javascript
import { PointerLockControls } from 'three/addons/controls/PointerLockControls.js';

const controls = new PointerLockControls(camera, document.body);

// Add to scene (required for getObject())
scene.add(controls.getObject());

// Click to lock
document.addEventListener('click', () => {
  controls.lock();
});

// Events
controls.addEventListener('lock', () => {
  console.log('Pointer locked');
  menu.style.display = 'none';
});

controls.addEventListener('unlock', () => {
  console.log('Pointer unlocked');
  menu.style.display = 'block';
});

// Movement
const velocity = new THREE.Vector3();
const direction = new THREE.Vector3();
let moveForward = false;
let moveBackward = false;
let moveLeft = false;
let moveRight = false;

document.addEventListener('keydown', (event) => {
  switch (event.code) {
    case 'KeyW': moveForward = true; break;
    case 'KeyS': moveBackward = true; break;
    case 'KeyA': moveLeft = true; break;
    case 'KeyD': moveRight = true; break;
  }
});

document.addEventListener('keyup', (event) => {
  switch (event.code) {
    case 'KeyW': moveForward = false; break;
    case 'KeyS': moveBackward = false; break;
    case 'KeyA': moveLeft = false; break;
    case 'KeyD': moveRight = false; break;
  }
});

function animate() {
  if (controls.isLocked) {
    const delta = clock.getDelta();

    // Damping
    velocity.x -= velocity.x * 10.0 * delta;
    velocity.z -= velocity.z * 10.0 * delta;

    // Direction
    direction.z = Number(moveForward) - Number(moveBackward);
    direction.x = Number(moveRight) - Number(moveLeft);
    direction.normalize();

    // Apply movement
    if (moveForward || moveBackward) velocity.z -= direction.z * 400.0 * delta;
    if (moveLeft || moveRight) velocity.x -= direction.x * 400.0 * delta;

    controls.moveRight(-velocity.x * delta);
    controls.moveForward(-velocity.z * delta);
  }

  renderer.render(scene, camera);
  requestAnimationFrame(animate);
}
```

## DragControls

Drag objects in the scene.

```javascript
import { DragControls } from 'three/addons/controls/DragControls.js';

const draggableObjects = [mesh1, mesh2, mesh3];
const controls = new DragControls(draggableObjects, camera, renderer.domElement);

// Events
controls.addEventListener('dragstart', (event) => {
  event.object.material.emissive.setHex(0xaaaaaa);
  orbitControls.enabled = false;  // Disable orbit while dragging
});

controls.addEventListener('drag', (event) => {
  // Constrain to plane
  event.object.position.y = 0;
});

controls.addEventListener('dragend', (event) => {
  event.object.material.emissive.setHex(0x000000);
  orbitControls.enabled = true;
});

// Hover
controls.addEventListener('hoveron', (event) => {
  event.object.material.emissive.setHex(0x444444);
  document.body.style.cursor = 'grab';
});

controls.addEventListener('hoveroff', (event) => {
  event.object.material.emissive.setHex(0x000000);
  document.body.style.cursor = 'default';
});

// Enable/disable
controls.enabled = true;
controls.transformGroup = false;  // true to drag parent group
```

## TransformControls

Gizmo for translate, rotate, scale.

```javascript
import { TransformControls } from 'three/addons/controls/TransformControls.js';

const transformControls = new TransformControls(camera, renderer.domElement);
scene.add(transformControls);

// Attach to object
transformControls.attach(mesh);

// Change mode
transformControls.setMode('translate');  // 'translate', 'rotate', 'scale'

// Keyboard shortcuts
document.addEventListener('keydown', (event) => {
  switch (event.key) {
    case 'g': transformControls.setMode('translate'); break;
    case 'r': transformControls.setMode('rotate'); break;
    case 's': transformControls.setMode('scale'); break;
    case 'Escape': transformControls.detach(); break;
  }
});

// Space (local/world)
transformControls.setSpace('world');  // 'local' or 'world'

// Size
transformControls.setSize(1);

// Snapping
transformControls.setTranslationSnap(1);
transformControls.setRotationSnap(THREE.MathUtils.degToRad(15));
transformControls.setScaleSnap(0.25);

// Axis visibility (constrain to specific axes)
transformControls.showX = true;
transformControls.showY = true;
transformControls.showZ = false;  // Hide Z axis gizmo

// Disable orbit controls while transforming
transformControls.addEventListener('dragging-changed', (event) => {
  orbitControls.enabled = !event.value;
});

// Change event
transformControls.addEventListener('change', () => {
  renderer.render(scene, camera);
});

// Object changed
transformControls.addEventListener('objectChange', () => {
  console.log('Object transformed');
});

// Detach
transformControls.detach();

// Dispose
transformControls.dispose();
```

## ArcballControls

Advanced rotation with arcball interface.

```javascript
import { ArcballControls } from 'three/addons/controls/ArcballControls.js';

const controls = new ArcballControls(camera, renderer.domElement, scene);

controls.setGizmosVisible(true);  // Show rotation gizmos

// Adjust arcball size
controls.radiusFactor = 0.67;

// Enable/disable features
controls.enableRotate = true;
controls.enablePan = true;
controls.enableZoom = true;
controls.enableFocus = true;  // Double-click to focus

// Cursor
controls.cursorZoom = true;

// Reset
controls.reset();

// Update
function animate() {
  controls.update();
  renderer.render(scene, camera);
  requestAnimationFrame(animate);
}
```

## Custom Controls Pattern

```javascript
class SimpleOrbitControls {
  constructor(camera, domElement) {
    this.camera = camera;
    this.domElement = domElement;

    this.target = new THREE.Vector3();
    this.spherical = new THREE.Spherical();
    this.sphericalDelta = new THREE.Spherical();

    this.rotateSpeed = 1.0;
    this.zoomSpeed = 1.0;

    this.isMouseDown = false;
    this.previousMousePosition = { x: 0, y: 0 };

    this.setupEvents();
    this.updateSpherical();
  }

  setupEvents() {
    this.domElement.addEventListener('mousedown', (e) => this.onMouseDown(e));
    this.domElement.addEventListener('mousemove', (e) => this.onMouseMove(e));
    this.domElement.addEventListener('mouseup', () => this.onMouseUp());
    this.domElement.addEventListener('wheel', (e) => this.onWheel(e));
  }

  onMouseDown(event) {
    this.isMouseDown = true;
    this.previousMousePosition = { x: event.clientX, y: event.clientY };
  }

  onMouseMove(event) {
    if (!this.isMouseDown) return;

    const deltaX = event.clientX - this.previousMousePosition.x;
    const deltaY = event.clientY - this.previousMousePosition.y;

    this.sphericalDelta.theta -= deltaX * 0.005 * this.rotateSpeed;
    this.sphericalDelta.phi -= deltaY * 0.005 * this.rotateSpeed;

    this.previousMousePosition = { x: event.clientX, y: event.clientY };
  }

  onMouseUp() {
    this.isMouseDown = false;
  }

  onWheel(event) {
    event.preventDefault();
    const delta = event.deltaY > 0 ? 1.1 : 0.9;
    this.spherical.radius *= delta;
  }

  updateSpherical() {
    const offset = this.camera.position.clone().sub(this.target);
    this.spherical.setFromVector3(offset);
  }

  update() {
    // Apply deltas
    this.spherical.theta += this.sphericalDelta.theta;
    this.spherical.phi += this.sphericalDelta.phi;

    // Clamp phi
    this.spherical.phi = Math.max(0.1, Math.min(Math.PI - 0.1, this.spherical.phi));

    // Apply to camera
    const offset = new THREE.Vector3().setFromSpherical(this.spherical);
    this.camera.position.copy(this.target).add(offset);
    this.camera.lookAt(this.target);

    // Damping
    this.sphericalDelta.theta *= 0.9;
    this.sphericalDelta.phi *= 0.9;
  }
}
```

## Combining Controls

```javascript
// Orbit controls for normal view
const orbitControls = new OrbitControls(camera, renderer.domElement);

// Transform controls for editing
const transformControls = new TransformControls(camera, renderer.domElement);
scene.add(transformControls);

// Disable orbit when transforming
transformControls.addEventListener('dragging-changed', (event) => {
  orbitControls.enabled = !event.value;
});

// Drag controls for moving objects
const dragControls = new DragControls(draggables, camera, renderer.domElement);

dragControls.addEventListener('dragstart', () => {
  orbitControls.enabled = false;
});

dragControls.addEventListener('dragend', () => {
  orbitControls.enabled = true;
});
```

## Mobile-Friendly Controls

```javascript
const controls = new OrbitControls(camera, renderer.domElement);

// Enable touch
controls.touches = {
  ONE: THREE.TOUCH.ROTATE,
  TWO: THREE.TOUCH.DOLLY_PAN
};

// Disable on mobile for performance
const isMobile = /iPhone|iPad|Android/i.test(navigator.userAgent);
if (isMobile) {
  controls.enableDamping = false;  // Reduce CPU usage
  controls.rotateSpeed = 0.5;      // Slower for touch
}

// Prevent default touch behavior
renderer.domElement.style.touchAction = 'none';
```
