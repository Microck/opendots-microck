# Three.js Physics & VR/XR

Physics engines integration and WebXR for virtual/augmented reality.

## Physics Integration

Three.js doesn't include physics - use external libraries.

### Rapier Physics (Recommended)

High-performance Rust-based physics engine.

```javascript
import { RapierPhysics } from 'three/addons/physics/RapierPhysics.js';

// Initialize (async)
const physics = await RapierPhysics();

// Create visual mesh
const box = new THREE.Mesh(
  new THREE.BoxGeometry(1, 1, 1),
  new THREE.MeshStandardMaterial({ color: 0x00ff00 })
);
scene.add(box);

// Add physics body (mass > 0 = dynamic)
physics.addMesh(box, 1);  // mass = 1

// Static ground (mass = 0 or omitted)
const ground = new THREE.Mesh(
  new THREE.BoxGeometry(50, 0.5, 50),
  new THREE.MeshStandardMaterial({ color: 0x888888 })
);
ground.position.y = -2;
scene.add(ground);
physics.addMesh(ground);  // No mass = static

// Animation loop
function animate() {
  requestAnimationFrame(animate);
  physics.step();  // Update physics simulation
  renderer.render(scene, camera);
}
```

### Physics Body Types

```javascript
// Dynamic (affected by forces, gravity)
physics.addMesh(mesh, 1);  // mass = 1

// Static (never moves, infinite mass)
physics.addMesh(mesh);  // No mass

// Kinematic (moved by code, affects dynamics)
physics.addMesh(mesh, 0, true);  // mass = 0, kinematic = true

// Apply force
physics.setMeshVelocity(mesh, new THREE.Vector3(0, 10, 0));

// Set position directly (kinematic)
physics.setMeshPosition(mesh, new THREE.Vector3(0, 5, 0));
```

### Collision Shapes

```javascript
// Automatic shape from geometry
physics.addMesh(boxMesh, 1);      // Box collider
physics.addMesh(sphereMesh, 1);   // Sphere collider

// Compound shapes (groups)
const group = new THREE.Group();
group.add(mesh1);
group.add(mesh2);
physics.addMesh(group, 1);

// Convex hull (for complex shapes)
// Note: Rapier auto-generates from BufferGeometry
const complexMesh = new THREE.Mesh(complexGeometry, material);
physics.addMesh(complexMesh, 1);
```

### Ammo Physics

Port of Bullet physics engine.

```javascript
import { AmmoPhysics } from 'three/addons/physics/AmmoPhysics.js';

const physics = await AmmoPhysics();

// Same API as Rapier
physics.addMesh(mesh, mass);

function animate() {
  physics.step();
  renderer.render(scene, camera);
  requestAnimationFrame(animate);
}
```

### Jolt Physics

High-performance alternative.

```javascript
import { JoltPhysics } from 'three/addons/physics/JoltPhysics.js';

const physics = await JoltPhysics();
physics.addMesh(mesh, mass);
```

### Cannon-es (Standalone)

Popular JavaScript physics library.

```javascript
import * as CANNON from 'cannon-es';

// Create physics world
const world = new CANNON.World();
world.gravity.set(0, -9.82, 0);

// Create physics body
const shape = new CANNON.Box(new CANNON.Vec3(0.5, 0.5, 0.5));
const body = new CANNON.Body({
  mass: 1,
  shape: shape,
  position: new CANNON.Vec3(0, 10, 0)
});
world.addBody(body);

// Create Three.js mesh
const mesh = new THREE.Mesh(
  new THREE.BoxGeometry(1, 1, 1),
  new THREE.MeshStandardMaterial()
);
scene.add(mesh);

// Sync in animation loop
function animate() {
  world.step(1 / 60);

  // Copy physics to visual
  mesh.position.copy(body.position);
  mesh.quaternion.copy(body.quaternion);

  renderer.render(scene, camera);
  requestAnimationFrame(animate);
}
```

### Physics Constraints

```javascript
// Rapier constraints
physics.addConstraint(meshA, meshB, 'fixed');
physics.addConstraint(meshA, meshB, 'spring', { stiffness: 100 });

// Cannon-es constraints
const constraint = new CANNON.PointToPointConstraint(
  bodyA,
  new CANNON.Vec3(0, 0, 0),  // pivot on A
  bodyB,
  new CANNON.Vec3(0, 0, 0)   // pivot on B
);
world.addConstraint(constraint);

// Hinge constraint
const hinge = new CANNON.HingeConstraint(bodyA, bodyB, {
  pivotA: new CANNON.Vec3(0, 0, 0),
  pivotB: new CANNON.Vec3(0, 0, 0),
  axisA: new CANNON.Vec3(0, 1, 0),
  axisB: new CANNON.Vec3(0, 1, 0)
});
world.addConstraint(hinge);
```

### Raycasting with Physics

```javascript
// Cannon-es
const ray = new CANNON.Ray(
  new CANNON.Vec3(0, 10, 0),  // from
  new CANNON.Vec3(0, -1, 0)   // direction
);

const result = new CANNON.RaycastResult();
ray.intersectWorld(world, { result });

if (result.hasHit) {
  console.log('Hit body:', result.body);
  console.log('Hit point:', result.hitPointWorld);
  console.log('Hit normal:', result.hitNormalWorld);
}
```

## WebXR Setup

### Basic VR

```javascript
import { VRButton } from 'three/addons/webxr/VRButton.js';

// Enable XR on renderer
renderer.xr.enabled = true;

// Add VR button to page
document.body.appendChild(VRButton.createButton(renderer));

// IMPORTANT: Use setAnimationLoop instead of requestAnimationFrame
renderer.setAnimationLoop(() => {
  renderer.render(scene, camera);
});
```

### Basic AR

```javascript
import { ARButton } from 'three/addons/webxr/ARButton.js';

renderer.xr.enabled = true;
document.body.appendChild(ARButton.createButton(renderer));

// AR-specific: request features
document.body.appendChild(ARButton.createButton(renderer, {
  requiredFeatures: ['hit-test'],
  optionalFeatures: ['dom-overlay'],
  domOverlay: { root: document.body }
}));

renderer.setAnimationLoop(() => {
  renderer.render(scene, camera);
});
```

### XR Session Management

```javascript
renderer.xr.addEventListener('sessionstart', () => {
  console.log('XR session started');
});

renderer.xr.addEventListener('sessionend', () => {
  console.log('XR session ended');
});

// Check if in XR
if (renderer.xr.isPresenting) {
  // In VR/AR mode
}

// Get session
const session = renderer.xr.getSession();
```

## VR Controllers

### Basic Controller Setup

```javascript
// Get controllers (0 = left, 1 = right)
const controller1 = renderer.xr.getController(0);
const controller2 = renderer.xr.getController(1);

scene.add(controller1);
scene.add(controller2);

// Controller events
controller1.addEventListener('selectstart', onSelectStart);
controller1.addEventListener('selectend', onSelectEnd);
controller1.addEventListener('squeezestart', onSqueezeStart);
controller1.addEventListener('squeezeend', onSqueezeEnd);
controller1.addEventListener('connected', (event) => {
  const data = event.data;
  console.log('Controller connected:', data.handedness);  // 'left' or 'right'
});

function onSelectStart(event) {
  const controller = event.target;
  // Trigger button pressed
}
```

### Controller Models

```javascript
import { XRControllerModelFactory } from 'three/addons/webxr/XRControllerModelFactory.js';

const controllerModelFactory = new XRControllerModelFactory();

// Get controller grip space (for holding objects)
const controllerGrip1 = renderer.xr.getControllerGrip(0);
const controllerGrip2 = renderer.xr.getControllerGrip(1);

// Add official controller models
controllerGrip1.add(controllerModelFactory.createControllerModel(controllerGrip1));
controllerGrip2.add(controllerModelFactory.createControllerModel(controllerGrip2));

scene.add(controllerGrip1);
scene.add(controllerGrip2);
```

### Controller Ray Visualization

```javascript
// Add ray line for pointing
function buildController(controller) {
  const geometry = new THREE.BufferGeometry();
  geometry.setAttribute('position', new THREE.Float32BufferAttribute([0, 0, 0, 0, 0, -1], 3));

  const line = new THREE.Line(geometry, new THREE.LineBasicMaterial());
  line.scale.z = 5;  // Ray length

  controller.add(line);
}

buildController(controller1);
buildController(controller2);
```

### Controller Raycasting

```javascript
const raycaster = new THREE.Raycaster();
const tempMatrix = new THREE.Matrix4();

function getControllerIntersections(controller) {
  tempMatrix.identity().extractRotation(controller.matrixWorld);

  raycaster.ray.origin.setFromMatrixPosition(controller.matrixWorld);
  raycaster.ray.direction.set(0, 0, -1).applyMatrix4(tempMatrix);

  return raycaster.intersectObjects(interactiveObjects, true);
}

// In animation loop
renderer.setAnimationLoop(() => {
  const intersects = getControllerIntersections(controller1);
  if (intersects.length > 0) {
    // Hovering over object
    intersects[0].object.material.emissive.setHex(0x444444);
  }

  renderer.render(scene, camera);
});
```

## Hand Tracking

```javascript
import { XRHandModelFactory } from 'three/addons/webxr/XRHandModelFactory.js';

const handModelFactory = new XRHandModelFactory();

// Get hands
const hand1 = renderer.xr.getHand(0);
const hand2 = renderer.xr.getHand(1);

// Add hand models
hand1.add(handModelFactory.createHandModel(hand1, 'mesh'));  // 'mesh', 'spheres', or 'boxes'
hand2.add(handModelFactory.createHandModel(hand2, 'mesh'));

scene.add(hand1);
scene.add(hand2);

// Hand events
hand1.addEventListener('pinchstart', (event) => {
  console.log('Pinch started');
});

hand1.addEventListener('pinchend', (event) => {
  console.log('Pinch ended');
});

// Access joints
hand1.addEventListener('connected', () => {
  const joints = hand1.joints;
  const indexTip = joints['index-finger-tip'];
  const thumbTip = joints['thumb-tip'];
});
```

### Oculus Hand Model

```javascript
import { OculusHandModel } from 'three/addons/webxr/OculusHandModel.js';

const hand1 = renderer.xr.getHand(0);
const handModel1 = new OculusHandModel(hand1);
hand1.add(handModel1);
scene.add(hand1);

const hand2 = renderer.xr.getHand(1);
const handModel2 = new OculusHandModel(hand2);
hand2.add(handModel2);
scene.add(hand2);
```

## Teleportation

```javascript
// Teleport marker
const marker = new THREE.Mesh(
  new THREE.CircleGeometry(0.5, 32),
  new THREE.MeshBasicMaterial({ color: 0x00ff00 })
);
marker.rotation.x = -Math.PI / 2;
marker.visible = false;
scene.add(marker);

// Ground plane for teleportation
const floor = new THREE.Mesh(
  new THREE.PlaneGeometry(100, 100),
  new THREE.MeshStandardMaterial()
);
floor.rotation.x = -Math.PI / 2;
floor.userData.teleport = true;
scene.add(floor);

const baseReferenceSpace = renderer.xr.getReferenceSpace();
let teleportValid = false;
let teleportPoint = new THREE.Vector3();

// Update marker position
function updateTeleportMarker(controller) {
  const intersects = getControllerIntersections(controller);
  const teleportable = intersects.filter(i => i.object.userData.teleport);

  if (teleportable.length > 0) {
    teleportPoint.copy(teleportable[0].point);
    marker.position.copy(teleportPoint);
    marker.visible = true;
    teleportValid = true;
  } else {
    marker.visible = false;
    teleportValid = false;
  }
}

// Perform teleport
controller1.addEventListener('selectend', () => {
  if (teleportValid) {
    const offsetPosition = {
      x: -teleportPoint.x,
      y: -teleportPoint.y,
      z: -teleportPoint.z,
      w: 1
    };

    const transform = new XRRigidTransform(offsetPosition);
    const newReferenceSpace = baseReferenceSpace.getOffsetReferenceSpace(transform);
    renderer.xr.setReferenceSpace(newReferenceSpace);
  }
});
```

## AR Hit Testing

Place objects in real-world space.

```javascript
import { ARButton } from 'three/addons/webxr/ARButton.js';

document.body.appendChild(ARButton.createButton(renderer, {
  requiredFeatures: ['hit-test']
}));

let hitTestSource = null;
let hitTestSourceRequested = false;

// Reticle for placement preview
const reticle = new THREE.Mesh(
  new THREE.RingGeometry(0.15, 0.2, 32).rotateX(-Math.PI / 2),
  new THREE.MeshBasicMaterial()
);
reticle.visible = false;
scene.add(reticle);

renderer.setAnimationLoop((timestamp, frame) => {
  if (frame) {
    const referenceSpace = renderer.xr.getReferenceSpace();
    const session = renderer.xr.getSession();

    // Request hit test source
    if (!hitTestSourceRequested) {
      session.requestReferenceSpace('viewer').then((viewerSpace) => {
        session.requestHitTestSource({ space: viewerSpace }).then((source) => {
          hitTestSource = source;
        });
      });

      hitTestSourceRequested = true;

      // Handle placement tap
      session.addEventListener('select', () => {
        if (reticle.visible) {
          // Place object at reticle
          const clone = model.clone();
          clone.position.setFromMatrixPosition(reticle.matrix);
          scene.add(clone);
        }
      });
    }

    // Update hit test
    if (hitTestSource) {
      const hitTestResults = frame.getHitTestResults(hitTestSource);
      if (hitTestResults.length > 0) {
        const hit = hitTestResults[0];
        reticle.visible = true;
        reticle.matrix.fromArray(hit.getPose(referenceSpace).transform.matrix);
      } else {
        reticle.visible = false;
      }
    }
  }

  renderer.render(scene, camera);
});
```

## Spatial Audio

```javascript
const listener = new THREE.AudioListener();
camera.add(listener);

// Positional audio (3D)
const sound = new THREE.PositionalAudio(listener);
const audioLoader = new THREE.AudioLoader();

audioLoader.load('sound.mp3', (buffer) => {
  sound.setBuffer(buffer);
  sound.setRefDistance(1);    // Distance at full volume
  sound.setRolloffFactor(1);  // Volume falloff
  sound.setDistanceModel('inverse');  // 'linear', 'inverse', 'exponential'
  sound.setLoop(true);
  sound.play();
});

// Attach to object
soundSource.add(sound);

// Ambient audio (non-positional)
const ambient = new THREE.Audio(listener);
audioLoader.load('ambient.mp3', (buffer) => {
  ambient.setBuffer(buffer);
  ambient.setVolume(0.5);
  ambient.setLoop(true);
  ambient.play();
});
```

## VR Performance Tips

```javascript
// Target 90 FPS (11.1ms per frame)

// 1. Lower resolution
renderer.xr.setFramebufferScaleFactor(0.8);  // 80% resolution

// 2. Foveated rendering (Quest 2+)
const gl = renderer.getContext();
const ext = gl.getExtension('WEBGL_foveated_rendering');
if (ext) {
  ext.foveatedRenderingModeWEBGL(gl.FOVEATED_RENDERING_MODE_ENABLE_WEBGL);
}

// 3. Reduce complexity
// - Lower polygon counts
// - Fewer lights
// - Simpler materials
// - No/reduced post-processing
// - Lower shadow resolution

// 4. Use instancing
// 5. Bake lighting
// 6. Use LOD aggressively

// 7. Profile
const vrStats = new Stats();
vrStats.showPanel(0);  // FPS
document.body.appendChild(vrStats.dom);
```

## Room-Scale VR

```javascript
// Request bounded reference space
navigator.xr.requestSession('immersive-vr', {
  requiredFeatures: ['local-floor'],
  optionalFeatures: ['bounded-floor']
}).then((session) => {
  session.requestReferenceSpace('bounded-floor').then((space) => {
    // Get play area bounds
    const bounds = space.boundsGeometry;
    if (bounds) {
      // Create visual boundary
      const points = [];
      for (let i = 0; i < bounds.length; i++) {
        const point = bounds[i];
        points.push(new THREE.Vector3(point.x, 0, point.z));
      }
      points.push(points[0]);  // Close loop

      const boundaryGeometry = new THREE.BufferGeometry().setFromPoints(points);
      const boundaryLine = new THREE.Line(
        boundaryGeometry,
        new THREE.LineBasicMaterial({ color: 0xff0000 })
      );
      scene.add(boundaryLine);
    }
  }).catch(() => {
    // Fall back to local-floor
    session.requestReferenceSpace('local-floor');
  });
});
```

## Mixed Reality (MR)

```javascript
import { XRButton } from 'three/addons/webxr/XRButton.js';

// Request MR features
document.body.appendChild(XRButton.createButton(renderer, {
  requiredFeatures: ['hand-tracking'],
  optionalFeatures: [
    'local-floor',
    'bounded-floor',
    'plane-detection',
    'mesh-detection'
  ]
}));

// Passthrough (Quest Pro/3)
renderer.xr.addEventListener('sessionstart', () => {
  const session = renderer.xr.getSession();

  // Enable passthrough
  if (session.environmentBlendMode === 'alpha-blend') {
    // Passthrough is available
    renderer.setClearColor(0x000000, 0);  // Transparent background
  }
});
```

## Common Patterns

```javascript
// Detect VR mode
function isInVR() {
  return renderer.xr.isPresenting;
}

// Different behavior for VR vs desktop
renderer.setAnimationLoop(() => {
  if (renderer.xr.isPresenting) {
    // VR-specific logic
    updateControllers();
  } else {
    // Desktop logic
    controls.update();
  }
  renderer.render(scene, camera);
});

// Get VR camera (for custom raycasting)
const vrCamera = renderer.xr.getCamera();

// Reference space types
// - 'viewer': Head-locked content
// - 'local': Seated experiences
// - 'local-floor': Standing, origin at floor
// - 'bounded-floor': Room-scale with boundaries
// - 'unbounded': Unlimited movement
```
