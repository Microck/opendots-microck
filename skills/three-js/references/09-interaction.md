# Three.js Interaction

Raycasting, mouse/touch input, selection, drag, and coordinate conversion.

## Raycaster Basics

```javascript
const raycaster = new THREE.Raycaster();
const pointer = new THREE.Vector2();

function onPointerMove(event) {
  // Convert to normalized device coordinates (-1 to +1)
  pointer.x = (event.clientX / window.innerWidth) * 2 - 1;
  pointer.y = -(event.clientY / window.innerHeight) * 2 + 1;
}

function checkIntersection() {
  raycaster.setFromCamera(pointer, camera);
  const intersects = raycaster.intersectObjects(scene.children, true);

  if (intersects.length > 0) {
    const hit = intersects[0];
    console.log('Hit:', hit.object.name);
    console.log('Point:', hit.point);
    console.log('Distance:', hit.distance);
    console.log('Face:', hit.face);
    console.log('UV:', hit.uv);
  }
}

window.addEventListener('pointermove', onPointerMove);
```

## Raycaster Configuration

```javascript
const raycaster = new THREE.Raycaster();

// Near/far distance limits
raycaster.near = 0;
raycaster.far = Infinity;

// Point threshold (for Points objects)
raycaster.params.Points.threshold = 0.1;

// Line threshold
raycaster.params.Line.threshold = 0.1;

// Mesh face culling
raycaster.params.Mesh.threshold = 0;

// Layer filtering
raycaster.layers.set(1);  // Only intersect layer 1
raycaster.layers.enableAll();
```

## Click/Tap Selection

```javascript
const raycaster = new THREE.Raycaster();
const pointer = new THREE.Vector2();
let selectedObject = null;

function onPointerDown(event) {
  pointer.x = (event.clientX / window.innerWidth) * 2 - 1;
  pointer.y = -(event.clientY / window.innerHeight) * 2 + 1;

  raycaster.setFromCamera(pointer, camera);
  const intersects = raycaster.intersectObjects(selectableObjects, true);

  if (intersects.length > 0) {
    // Deselect previous
    if (selectedObject) {
      selectedObject.material.emissive.setHex(0x000000);
    }

    // Select new
    selectedObject = intersects[0].object;
    selectedObject.material.emissive.setHex(0x444444);

    console.log('Selected:', selectedObject.name);
  } else {
    // Click on empty space - deselect
    if (selectedObject) {
      selectedObject.material.emissive.setHex(0x000000);
      selectedObject = null;
    }
  }
}

window.addEventListener('pointerdown', onPointerDown);
```

## Hover Effects

```javascript
const raycaster = new THREE.Raycaster();
const pointer = new THREE.Vector2();
let hoveredObject = null;

function onPointerMove(event) {
  pointer.x = (event.clientX / window.innerWidth) * 2 - 1;
  pointer.y = -(event.clientY / window.innerHeight) * 2 + 1;

  raycaster.setFromCamera(pointer, camera);
  const intersects = raycaster.intersectObjects(interactiveObjects);

  if (intersects.length > 0) {
    const newHovered = intersects[0].object;

    if (hoveredObject !== newHovered) {
      // Mouse leave previous
      if (hoveredObject) {
        hoveredObject.material.color.setHex(hoveredObject.userData.originalColor);
        document.body.style.cursor = 'default';
      }

      // Mouse enter new
      hoveredObject = newHovered;
      hoveredObject.userData.originalColor = hoveredObject.material.color.getHex();
      hoveredObject.material.color.setHex(0xff0000);
      document.body.style.cursor = 'pointer';
    }
  } else {
    // Mouse leave
    if (hoveredObject) {
      hoveredObject.material.color.setHex(hoveredObject.userData.originalColor);
      hoveredObject = null;
      document.body.style.cursor = 'default';
    }
  }
}

window.addEventListener('pointermove', onPointerMove);
```

## Drag and Drop

```javascript
const raycaster = new THREE.Raycaster();
const pointer = new THREE.Vector2();
const plane = new THREE.Plane(new THREE.Vector3(0, 1, 0), 0);  // Horizontal plane
const intersection = new THREE.Vector3();

let dragging = null;
let offset = new THREE.Vector3();

function onPointerDown(event) {
  pointer.x = (event.clientX / window.innerWidth) * 2 - 1;
  pointer.y = -(event.clientY / window.innerHeight) * 2 + 1;

  raycaster.setFromCamera(pointer, camera);
  const intersects = raycaster.intersectObjects(draggableObjects);

  if (intersects.length > 0) {
    dragging = intersects[0].object;

    // Calculate offset from object center to hit point
    raycaster.ray.intersectPlane(plane, intersection);
    offset.copy(intersection).sub(dragging.position);

    controls.enabled = false;  // Disable orbit controls while dragging
  }
}

function onPointerMove(event) {
  if (!dragging) return;

  pointer.x = (event.clientX / window.innerWidth) * 2 - 1;
  pointer.y = -(event.clientY / window.innerHeight) * 2 + 1;

  raycaster.setFromCamera(pointer, camera);
  raycaster.ray.intersectPlane(plane, intersection);

  dragging.position.copy(intersection.sub(offset));
}

function onPointerUp() {
  if (dragging) {
    dragging = null;
    controls.enabled = true;
  }
}

window.addEventListener('pointerdown', onPointerDown);
window.addEventListener('pointermove', onPointerMove);
window.addEventListener('pointerup', onPointerUp);
```

## Box Selection

```javascript
const selectionBox = new THREE.Box2();
const startPoint = new THREE.Vector2();
const endPoint = new THREE.Vector2();
let isSelecting = false;

// HTML overlay for selection rectangle
const selectionRect = document.createElement('div');
selectionRect.style.cssText = `
  position: absolute;
  border: 1px dashed #fff;
  background: rgba(255, 255, 255, 0.1);
  pointer-events: none;
  display: none;
`;
document.body.appendChild(selectionRect);

function onPointerDown(event) {
  if (event.button !== 0) return;  // Left click only

  isSelecting = true;
  startPoint.set(event.clientX, event.clientY);
  endPoint.copy(startPoint);

  selectionRect.style.display = 'block';
  updateSelectionRect();
}

function onPointerMove(event) {
  if (!isSelecting) return;

  endPoint.set(event.clientX, event.clientY);
  updateSelectionRect();
}

function onPointerUp() {
  if (!isSelecting) return;

  isSelecting = false;
  selectionRect.style.display = 'none';

  // Get selected objects
  const selected = getObjectsInSelectionBox();
  console.log('Selected:', selected);
}

function updateSelectionRect() {
  const left = Math.min(startPoint.x, endPoint.x);
  const top = Math.min(startPoint.y, endPoint.y);
  const width = Math.abs(endPoint.x - startPoint.x);
  const height = Math.abs(endPoint.y - startPoint.y);

  selectionRect.style.left = `${left}px`;
  selectionRect.style.top = `${top}px`;
  selectionRect.style.width = `${width}px`;
  selectionRect.style.height = `${height}px`;
}

function getObjectsInSelectionBox() {
  const selected = [];

  // Normalize selection box to NDC
  const box = new THREE.Box2(
    new THREE.Vector2(
      Math.min(startPoint.x, endPoint.x) / window.innerWidth * 2 - 1,
      -(Math.max(startPoint.y, endPoint.y) / window.innerHeight) * 2 + 1
    ),
    new THREE.Vector2(
      Math.max(startPoint.x, endPoint.x) / window.innerWidth * 2 - 1,
      -(Math.min(startPoint.y, endPoint.y) / window.innerHeight) * 2 + 1
    )
  );

  selectableObjects.forEach(object => {
    const screenPos = toScreenNDC(object, camera);
    if (box.containsPoint(screenPos)) {
      selected.push(object);
    }
  });

  return selected;
}

function toScreenNDC(object, camera) {
  const pos = new THREE.Vector3();
  object.getWorldPosition(pos);
  pos.project(camera);
  return new THREE.Vector2(pos.x, pos.y);
}
```

## Coordinate Conversion

### World to Screen

```javascript
function worldToScreen(worldPosition, camera) {
  const vector = worldPosition.clone();
  vector.project(camera);

  return {
    x: (vector.x + 1) / 2 * window.innerWidth,
    y: -(vector.y - 1) / 2 * window.innerHeight
  };
}

// For object position
function objectToScreen(object, camera) {
  const worldPos = new THREE.Vector3();
  object.getWorldPosition(worldPos);
  return worldToScreen(worldPos, camera);
}
```

### Screen to World (on plane)

```javascript
function screenToWorld(screenX, screenY, camera, targetPlane) {
  const pointer = new THREE.Vector2(
    (screenX / window.innerWidth) * 2 - 1,
    -(screenY / window.innerHeight) * 2 + 1
  );

  const raycaster = new THREE.Raycaster();
  raycaster.setFromCamera(pointer, camera);

  const intersection = new THREE.Vector3();
  raycaster.ray.intersectPlane(targetPlane, intersection);

  return intersection;
}

// Usage - point on ground plane
const groundPlane = new THREE.Plane(new THREE.Vector3(0, 1, 0), 0);
const worldPos = screenToWorld(event.clientX, event.clientY, camera, groundPlane);
```

### Screen to World (at depth)

```javascript
function screenToWorldAtDepth(screenX, screenY, camera, depth) {
  const pointer = new THREE.Vector3(
    (screenX / window.innerWidth) * 2 - 1,
    -(screenY / window.innerHeight) * 2 + 1,
    0.5  // NDC z
  );

  pointer.unproject(camera);

  const dir = pointer.sub(camera.position).normalize();
  return camera.position.clone().add(dir.multiplyScalar(depth));
}
```

### Ray from Screen Point

```javascript
function getRayFromScreen(screenX, screenY, camera) {
  const pointer = new THREE.Vector2(
    (screenX / window.innerWidth) * 2 - 1,
    -(screenY / window.innerHeight) * 2 + 1
  );

  const raycaster = new THREE.Raycaster();
  raycaster.setFromCamera(pointer, camera);

  return {
    origin: raycaster.ray.origin.clone(),
    direction: raycaster.ray.direction.clone()
  };
}
```

## Touch Input

```javascript
function onTouchStart(event) {
  event.preventDefault();

  if (event.touches.length === 1) {
    const touch = event.touches[0];
    pointer.x = (touch.clientX / window.innerWidth) * 2 - 1;
    pointer.y = -(touch.clientY / window.innerHeight) * 2 + 1;

    checkSelection();
  }
}

function onTouchMove(event) {
  event.preventDefault();

  if (event.touches.length === 1 && dragging) {
    const touch = event.touches[0];
    pointer.x = (touch.clientX / window.innerWidth) * 2 - 1;
    pointer.y = -(touch.clientY / window.innerHeight) * 2 + 1;

    updateDrag();
  }
}

function onTouchEnd(event) {
  dragging = null;
}

renderer.domElement.addEventListener('touchstart', onTouchStart, { passive: false });
renderer.domElement.addEventListener('touchmove', onTouchMove, { passive: false });
renderer.domElement.addEventListener('touchend', onTouchEnd);
```

## Layer-Based Interaction

```javascript
// Define layers
const LAYER_DEFAULT = 0;
const LAYER_INTERACTIVE = 1;
const LAYER_UI = 2;

// Assign objects to layers
interactiveMesh.layers.set(LAYER_INTERACTIVE);
uiElement.layers.set(LAYER_UI);

// Raycaster only checks specific layers
const interactionRaycaster = new THREE.Raycaster();
interactionRaycaster.layers.set(LAYER_INTERACTIVE);

// Check only interactive objects
interactionRaycaster.setFromCamera(pointer, camera);
const intersects = interactionRaycaster.intersectObjects(scene.children, true);
```

## Event Manager Class

```javascript
class InteractionManager {
  constructor(camera, domElement) {
    this.camera = camera;
    this.domElement = domElement;
    this.raycaster = new THREE.Raycaster();
    this.pointer = new THREE.Vector2();

    this.interactiveObjects = [];
    this.hoveredObject = null;
    this.selectedObject = null;

    this.setupEvents();
  }

  add(object, callbacks = {}) {
    object.userData.interactive = true;
    object.userData.callbacks = callbacks;
    this.interactiveObjects.push(object);
  }

  remove(object) {
    const index = this.interactiveObjects.indexOf(object);
    if (index > -1) {
      this.interactiveObjects.splice(index, 1);
    }
  }

  setupEvents() {
    this.domElement.addEventListener('pointermove', (e) => this.onPointerMove(e));
    this.domElement.addEventListener('pointerdown', (e) => this.onPointerDown(e));
    this.domElement.addEventListener('pointerup', (e) => this.onPointerUp(e));
  }

  updatePointer(event) {
    const rect = this.domElement.getBoundingClientRect();
    this.pointer.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
    this.pointer.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;
  }

  raycast() {
    this.raycaster.setFromCamera(this.pointer, this.camera);
    return this.raycaster.intersectObjects(this.interactiveObjects, true);
  }

  onPointerMove(event) {
    this.updatePointer(event);
    const intersects = this.raycast();

    if (intersects.length > 0) {
      const object = this.findInteractiveParent(intersects[0].object);

      if (this.hoveredObject !== object) {
        if (this.hoveredObject) {
          this.triggerCallback(this.hoveredObject, 'onPointerLeave');
        }
        this.hoveredObject = object;
        this.triggerCallback(object, 'onPointerEnter');
      }

      this.triggerCallback(object, 'onPointerMove', intersects[0]);
    } else {
      if (this.hoveredObject) {
        this.triggerCallback(this.hoveredObject, 'onPointerLeave');
        this.hoveredObject = null;
      }
    }
  }

  onPointerDown(event) {
    this.updatePointer(event);
    const intersects = this.raycast();

    if (intersects.length > 0) {
      const object = this.findInteractiveParent(intersects[0].object);
      this.selectedObject = object;
      this.triggerCallback(object, 'onPointerDown', intersects[0]);
    }
  }

  onPointerUp(event) {
    if (this.selectedObject) {
      this.triggerCallback(this.selectedObject, 'onPointerUp');
      this.triggerCallback(this.selectedObject, 'onClick');
      this.selectedObject = null;
    }
  }

  findInteractiveParent(object) {
    while (object) {
      if (object.userData.interactive) return object;
      object = object.parent;
    }
    return null;
  }

  triggerCallback(object, callbackName, data) {
    const callbacks = object.userData.callbacks;
    if (callbacks && callbacks[callbackName]) {
      callbacks[callbackName](object, data);
    }
  }

  dispose() {
    this.domElement.removeEventListener('pointermove', this.onPointerMove);
    this.domElement.removeEventListener('pointerdown', this.onPointerDown);
    this.domElement.removeEventListener('pointerup', this.onPointerUp);
  }
}

// Usage
const interaction = new InteractionManager(camera, renderer.domElement);

interaction.add(mesh, {
  onPointerEnter: (obj) => {
    obj.material.emissive.setHex(0x222222);
    document.body.style.cursor = 'pointer';
  },
  onPointerLeave: (obj) => {
    obj.material.emissive.setHex(0x000000);
    document.body.style.cursor = 'default';
  },
  onClick: (obj) => {
    console.log('Clicked:', obj.name);
  }
});
```

## SelectionBox (Official Helper)

Three.js provides official selection helpers for box selection.

```javascript
import { SelectionBox } from 'three/addons/interactive/SelectionBox.js';
import { SelectionHelper } from 'three/addons/interactive/SelectionHelper.js';

// Create selection box
const selectionBox = new SelectionBox(camera, scene);
const selectionHelper = new SelectionHelper(renderer, 'selectBox');

// CSS for selection rectangle
// .selectBox { border: 1px solid #55aaff; background: rgba(75, 160, 255, 0.3); position: fixed; }

document.addEventListener('pointerdown', (event) => {
  if (event.button !== 0) return;  // Left click only

  selectionBox.startPoint.set(
    (event.clientX / window.innerWidth) * 2 - 1,
    -(event.clientY / window.innerHeight) * 2 + 1,
    0.5
  );
});

document.addEventListener('pointermove', (event) => {
  if (selectionHelper.isDown) {
    selectionBox.endPoint.set(
      (event.clientX / window.innerWidth) * 2 - 1,
      -(event.clientY / window.innerHeight) * 2 + 1,
      0.5
    );
  }
});

document.addEventListener('pointerup', (event) => {
  selectionBox.endPoint.set(
    (event.clientX / window.innerWidth) * 2 - 1,
    -(event.clientY / window.innerHeight) * 2 + 1,
    0.5
  );

  // Get selected objects
  const selected = selectionBox.select();

  // Highlight selected
  selected.forEach((object) => {
    if (object.isMesh) {
      object.material.emissive.set(0x444444);
    }
  });

  console.log('Selected:', selected.length, 'objects');
});
```

### SelectionBox with Deep Selection

```javascript
// Select nested objects (recursive)
const selectionBox = new SelectionBox(camera, scene);

document.addEventListener('pointerup', () => {
  // select() with 'deep' flag
  const selected = selectionBox.select();

  // Filter only meshes
  const meshes = selected.filter(obj => obj.isMesh);

  // Or use selectDeep for recursive search
  selectionBox.collection = [];
  selectionBox.startPoint.set(startX, startY, 0.5);
  selectionBox.endPoint.set(endX, endY, 0.5);

  // Update collection with all intersecting objects
  selectionBox.select();

  meshes.forEach(mesh => {
    // Process selected meshes
  });
});
```

### Custom SelectionHelper Styles

```javascript
// Custom CSS class
const selectionHelper = new SelectionHelper(renderer, 'myCustomSelection');

// styles.css
// .myCustomSelection {
//   position: fixed;
//   border: 2px dashed #00ff00;
//   background: rgba(0, 255, 0, 0.1);
//   pointer-events: none;
// }
```

## Performance Tips

1. **Throttle raycasting**: Don't raycast every frame
2. **Use layers**: Filter objects before raycasting
3. **Limit recursive search**: Set `recursive = false` when possible
4. **Use simpler collision geometry**: Raycast against bounding boxes first
5. **Cache raycaster**: Reuse single instance

```javascript
// Throttled raycasting
let lastRaycast = 0;
const RAYCAST_INTERVAL = 50;  // ms

function onPointerMove(event) {
  const now = performance.now();
  if (now - lastRaycast < RAYCAST_INTERVAL) return;
  lastRaycast = now;

  // Do raycast
}

// BVH acceleration for complex meshes
import { MeshBVH, acceleratedRaycast } from 'three-mesh-bvh';

THREE.Mesh.prototype.raycast = acceleratedRaycast;
mesh.geometry.boundsTree = new MeshBVH(mesh.geometry);
```
