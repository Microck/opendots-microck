# Three.js Geometry

Creating shapes, BufferGeometry, custom geometry, instancing, points, and lines.

## Built-in Geometries

### Basic Shapes

```javascript
// BoxGeometry(width, height, depth, widthSegments, heightSegments, depthSegments)
new THREE.BoxGeometry(1, 1, 1);
new THREE.BoxGeometry(1, 2, 0.5, 2, 4, 1);  // With segments

// SphereGeometry(radius, widthSegments, heightSegments, phiStart, phiLength, thetaStart, thetaLength)
new THREE.SphereGeometry(1, 32, 32);
new THREE.SphereGeometry(1, 32, 16, 0, Math.PI * 2, 0, Math.PI / 2);  // Hemisphere

// PlaneGeometry(width, height, widthSegments, heightSegments)
new THREE.PlaneGeometry(10, 10);
new THREE.PlaneGeometry(10, 10, 64, 64);  // For displacement

// CircleGeometry(radius, segments, thetaStart, thetaLength)
new THREE.CircleGeometry(1, 32);
new THREE.CircleGeometry(1, 32, 0, Math.PI);  // Semicircle

// CylinderGeometry(radiusTop, radiusBottom, height, radialSegments, heightSegments, openEnded, thetaStart, thetaLength)
new THREE.CylinderGeometry(1, 1, 2, 32);
new THREE.CylinderGeometry(0, 1, 2, 32);    // Cone shape
new THREE.CylinderGeometry(1, 1, 2, 6);     // Hexagonal prism

// ConeGeometry(radius, height, radialSegments, heightSegments, openEnded)
new THREE.ConeGeometry(1, 2, 32);

// TorusGeometry(radius, tube, radialSegments, tubularSegments, arc)
new THREE.TorusGeometry(1, 0.4, 16, 100);
new THREE.TorusGeometry(1, 0.4, 16, 100, Math.PI);  // Half torus

// TorusKnotGeometry(radius, tube, tubularSegments, radialSegments, p, q)
new THREE.TorusKnotGeometry(1, 0.3, 100, 16, 2, 3);

// RingGeometry(innerRadius, outerRadius, thetaSegments, phiSegments, thetaStart, thetaLength)
new THREE.RingGeometry(0.5, 1, 32);

// CapsuleGeometry(radius, length, capSegments, radialSegments)
new THREE.CapsuleGeometry(0.5, 1, 4, 8);
```

### Platonic Solids

```javascript
// IcosahedronGeometry(radius, detail) - 20 faces
new THREE.IcosahedronGeometry(1, 0);
new THREE.IcosahedronGeometry(1, 2);  // Subdivided = smoother

// OctahedronGeometry(radius, detail) - 8 faces
new THREE.OctahedronGeometry(1, 0);

// TetrahedronGeometry(radius, detail) - 4 faces
new THREE.TetrahedronGeometry(1, 0);

// DodecahedronGeometry(radius, detail) - 12 faces
new THREE.DodecahedronGeometry(1, 0);

// Custom PolyhedronGeometry
const vertices = [
  1, 1, 1,  -1, -1, 1,  -1, 1, -1,  1, -1, -1
];
const indices = [
  2, 1, 0,  0, 3, 2,  1, 3, 0,  2, 3, 1
];
new THREE.PolyhedronGeometry(vertices, indices, 1, 0);
```

### Path-Based Shapes

```javascript
// LatheGeometry - rotate 2D points around Y axis
const points = [
  new THREE.Vector2(0, 0),
  new THREE.Vector2(0.5, 0),
  new THREE.Vector2(0.5, 0.5),
  new THREE.Vector2(0.3, 1),
  new THREE.Vector2(0, 1),
];
new THREE.LatheGeometry(points, 32);  // points, segments

// TubeGeometry - extrude along a curve
const curve = new THREE.CatmullRomCurve3([
  new THREE.Vector3(-2, 0, 0),
  new THREE.Vector3(0, 2, 0),
  new THREE.Vector3(2, 0, 0),
]);
new THREE.TubeGeometry(curve, 64, 0.2, 8, false);  // path, segments, radius, radialSegments, closed

// ExtrudeGeometry - extrude a 2D shape
const shape = new THREE.Shape();
shape.moveTo(0, 0);
shape.lineTo(1, 0);
shape.lineTo(1, 1);
shape.lineTo(0, 1);
shape.closePath();

// Add hole
const hole = new THREE.Path();
hole.moveTo(0.3, 0.3);
hole.lineTo(0.7, 0.3);
hole.lineTo(0.7, 0.7);
hole.lineTo(0.3, 0.7);
hole.closePath();
shape.holes.push(hole);

new THREE.ExtrudeGeometry(shape, {
  steps: 2,
  depth: 1,
  bevelEnabled: true,
  bevelThickness: 0.1,
  bevelSize: 0.1,
  bevelSegments: 3,
  curveSegments: 12,
});

// ShapeGeometry - flat 2D shape
new THREE.ShapeGeometry(shape, 12);  // shape, curveSegments
```

### Text Geometry

```javascript
import { FontLoader } from 'three/addons/loaders/FontLoader.js';
import { TextGeometry } from 'three/addons/geometries/TextGeometry.js';

const loader = new FontLoader();
loader.load('fonts/helvetiker_regular.typeface.json', (font) => {
  const geometry = new TextGeometry('Hello', {
    font: font,
    size: 1,
    depth: 0.2,           // Was 'height' in older versions
    curveSegments: 12,
    bevelEnabled: true,
    bevelThickness: 0.03,
    bevelSize: 0.02,
    bevelSegments: 5,
  });

  // Center text
  geometry.computeBoundingBox();
  geometry.center();

  const mesh = new THREE.Mesh(geometry, material);
  scene.add(mesh);
});
```

## BufferGeometry

The base class for all geometries. Stores data as typed arrays for GPU efficiency.

### Create Custom Geometry

```javascript
const geometry = new THREE.BufferGeometry();

// Positions (required) - 3 floats per vertex
const positions = new Float32Array([
  -1, -1,  0,   // vertex 0
   1, -1,  0,   // vertex 1
   1,  1,  0,   // vertex 2
  -1,  1,  0,   // vertex 3
]);
geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));

// Indices (optional) - reuse vertices
const indices = new Uint16Array([
  0, 1, 2,   // triangle 1
  0, 2, 3,   // triangle 2
]);
geometry.setIndex(new THREE.BufferAttribute(indices, 1));

// Normals (required for lighting)
const normals = new Float32Array([
  0, 0, 1,
  0, 0, 1,
  0, 0, 1,
  0, 0, 1,
]);
geometry.setAttribute('normal', new THREE.BufferAttribute(normals, 3));

// UVs (required for texturing) - 2 floats per vertex
const uvs = new Float32Array([
  0, 0,
  1, 0,
  1, 1,
  0, 1,
]);
geometry.setAttribute('uv', new THREE.BufferAttribute(uvs, 2));

// Colors (optional) - 3 floats per vertex
const colors = new Float32Array([
  1, 0, 0,   // red
  0, 1, 0,   // green
  0, 0, 1,   // blue
  1, 1, 0,   // yellow
]);
geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
// Use with: material.vertexColors = true

// Compute bounding volumes (required for frustum culling)
geometry.computeBoundingBox();
geometry.computeBoundingSphere();
```

### BufferAttribute Item Sizes

| Attribute | Item Size | Type |
|-----------|-----------|------|
| position | 3 | Float32Array |
| normal | 3 | Float32Array |
| uv | 2 | Float32Array |
| uv2 | 2 | Float32Array |
| color | 3 or 4 | Float32Array |
| index | 1 | Uint16Array or Uint32Array |
| tangent | 4 | Float32Array |

### Modify Geometry

```javascript
const positions = geometry.attributes.position;

// Read vertex
const x = positions.getX(index);
const y = positions.getY(index);
const z = positions.getZ(index);

// Write vertex
positions.setXYZ(index, x, y, z);

// Flag for GPU update
positions.needsUpdate = true;

// Recompute derived data
geometry.computeVertexNormals();
geometry.computeBoundingBox();
geometry.computeBoundingSphere();
```

### Geometry Groups (Multi-Material)

```javascript
const geometry = new THREE.BufferGeometry();
// ... set up attributes

// Define material groups: start index, count, material index
geometry.addGroup(0, 6, 0);     // First 6 indices use material[0]
geometry.addGroup(6, 6, 1);     // Next 6 indices use material[1]

const mesh = new THREE.Mesh(geometry, [material1, material2]);
```

### Compute Normals & Tangents

```javascript
// Compute smooth normals from positions
geometry.computeVertexNormals();

// Compute tangents (required for normal maps)
import { computeTangents } from 'three/addons/utils/BufferGeometryUtils.js';
computeTangents(geometry);
// Or use BufferGeometryUtils
BufferGeometryUtils.computeTangents(geometry);
```

## EdgesGeometry & WireframeGeometry

```javascript
// EdgesGeometry - only hard edges (based on angle threshold)
const edges = new THREE.EdgesGeometry(boxGeometry, 15);  // 15 degrees
const edgeMesh = new THREE.LineSegments(
  edges,
  new THREE.LineBasicMaterial({ color: 0xffffff })
);

// WireframeGeometry - all triangle edges
const wireframe = new THREE.WireframeGeometry(boxGeometry);
const wireMesh = new THREE.LineSegments(
  wireframe,
  new THREE.LineBasicMaterial({ color: 0xffffff })
);
```

## Points (Point Cloud)

```javascript
const geometry = new THREE.BufferGeometry();
const count = 10000;
const positions = new Float32Array(count * 3);
const colors = new Float32Array(count * 3);

for (let i = 0; i < count; i++) {
  positions[i * 3] = (Math.random() - 0.5) * 10;
  positions[i * 3 + 1] = (Math.random() - 0.5) * 10;
  positions[i * 3 + 2] = (Math.random() - 0.5) * 10;

  colors[i * 3] = Math.random();
  colors[i * 3 + 1] = Math.random();
  colors[i * 3 + 2] = Math.random();
}

geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));

const material = new THREE.PointsMaterial({
  size: 0.1,
  sizeAttenuation: true,    // Size decreases with distance
  vertexColors: true,
  map: pointTexture,
  alphaMap: alphaTexture,
  transparent: true,
  alphaTest: 0.01,
  depthWrite: false,        // For transparency
});

const points = new THREE.Points(geometry, material);
scene.add(points);
```

## Lines

```javascript
// Line - connected vertices
const points = [
  new THREE.Vector3(-1, 0, 0),
  new THREE.Vector3(0, 1, 0),
  new THREE.Vector3(1, 0, 0),
];
const geometry = new THREE.BufferGeometry().setFromPoints(points);
const line = new THREE.Line(geometry, new THREE.LineBasicMaterial({ color: 0xff0000 }));

// LineLoop - closed loop
const loop = new THREE.LineLoop(geometry, material);

// LineSegments - pairs of points (each pair is a separate line)
const segmentPositions = new Float32Array([
  -1, 0, 0,   0, 1, 0,   // segment 1
   0, 1, 0,   1, 0, 0,   // segment 2
]);
const segmentGeometry = new THREE.BufferGeometry();
segmentGeometry.setAttribute('position', new THREE.BufferAttribute(segmentPositions, 3));
const segments = new THREE.LineSegments(segmentGeometry, material);

// LineDashedMaterial
const dashedMaterial = new THREE.LineDashedMaterial({
  color: 0xffffff,
  dashSize: 0.5,
  gapSize: 0.25,
  scale: 1,
});
const dashedLine = new THREE.Line(geometry, dashedMaterial);
dashedLine.computeLineDistances();  // Required for dashed lines
```

### Fat Lines (Line2)

For lines with actual width:

```javascript
import { Line2 } from 'three/addons/lines/Line2.js';
import { LineMaterial } from 'three/addons/lines/LineMaterial.js';
import { LineGeometry } from 'three/addons/lines/LineGeometry.js';

const geometry = new LineGeometry();
geometry.setPositions([
  -1, 0, 0,
   0, 1, 0,
   1, 0, 0,
]);

const material = new LineMaterial({
  color: 0xff0000,
  linewidth: 5,  // Actual pixel width
  resolution: new THREE.Vector2(window.innerWidth, window.innerHeight),
});

const line = new Line2(geometry, material);
scene.add(line);

// Update resolution on resize
window.addEventListener('resize', () => {
  material.resolution.set(window.innerWidth, window.innerHeight);
});
```

## InstancedMesh

Efficiently render many copies of the same geometry.

```javascript
const geometry = new THREE.BoxGeometry(0.5, 0.5, 0.5);
const material = new THREE.MeshStandardMaterial({ color: 0x00ff00 });
const count = 1000;

const instancedMesh = new THREE.InstancedMesh(geometry, material, count);
instancedMesh.instanceMatrix.setUsage(THREE.DynamicDrawUsage);  // If updating frequently

const dummy = new THREE.Object3D();

for (let i = 0; i < count; i++) {
  dummy.position.set(
    (Math.random() - 0.5) * 20,
    (Math.random() - 0.5) * 20,
    (Math.random() - 0.5) * 20
  );
  dummy.rotation.set(
    Math.random() * Math.PI,
    Math.random() * Math.PI,
    0
  );
  dummy.scale.setScalar(0.5 + Math.random());
  dummy.updateMatrix();

  instancedMesh.setMatrixAt(i, dummy.matrix);
}

instancedMesh.instanceMatrix.needsUpdate = true;
scene.add(instancedMesh);

// Per-instance colors
for (let i = 0; i < count; i++) {
  instancedMesh.setColorAt(i, new THREE.Color(Math.random(), Math.random(), Math.random()));
}
instancedMesh.instanceColor.needsUpdate = true;
```

### Update Instance at Runtime

```javascript
const matrix = new THREE.Matrix4();

// Get current matrix
instancedMesh.getMatrixAt(index, matrix);

// Decompose, modify, recompose
const position = new THREE.Vector3();
const quaternion = new THREE.Quaternion();
const scale = new THREE.Vector3();
matrix.decompose(position, quaternion, scale);

position.y += 0.1;
matrix.compose(position, quaternion, scale);

// Set back
instancedMesh.setMatrixAt(index, matrix);
instancedMesh.instanceMatrix.needsUpdate = true;
```

### Raycasting InstancedMesh

```javascript
const intersects = raycaster.intersectObject(instancedMesh);
if (intersects.length > 0) {
  const instanceId = intersects[0].instanceId;
  console.log(`Hit instance ${instanceId}`);

  // Highlight hit instance
  instancedMesh.setColorAt(instanceId, new THREE.Color(0xff0000));
  instancedMesh.instanceColor.needsUpdate = true;
}
```

## InstancedBufferGeometry

For custom per-instance attributes beyond matrix/color.

```javascript
const geometry = new THREE.InstancedBufferGeometry();
geometry.copy(new THREE.BoxGeometry(1, 1, 1));

// Per-instance offset
const offsets = new Float32Array(count * 3);
for (let i = 0; i < count; i++) {
  offsets[i * 3] = Math.random() * 10;
  offsets[i * 3 + 1] = Math.random() * 10;
  offsets[i * 3 + 2] = Math.random() * 10;
}
geometry.setAttribute('offset', new THREE.InstancedBufferAttribute(offsets, 3));

// Use in custom shader:
// attribute vec3 offset;
// vec3 transformed = position + offset;
```

## BufferGeometryUtils

```javascript
import * as BufferGeometryUtils from 'three/addons/utils/BufferGeometryUtils.js';

// Merge geometries (must have same attributes)
const merged = BufferGeometryUtils.mergeGeometries([geo1, geo2, geo3]);

// Merge with groups (for multi-material)
const merged = BufferGeometryUtils.mergeGeometries([geo1, geo2, geo3], true);

// Compute tangents
BufferGeometryUtils.computeTangents(geometry);

// Interleave attributes (better GPU performance)
const interleaved = BufferGeometryUtils.interleaveAttributes([
  geometry.attributes.position,
  geometry.attributes.normal,
  geometry.attributes.uv,
]);

// Estimate vertex count needed for draw calls
const count = BufferGeometryUtils.estimateBytesUsed(geometry);

// Deep clone
const clone = BufferGeometryUtils.deepClone(geometry);
```

## Morph Targets

```javascript
// Base geometry
const geometry = new THREE.BoxGeometry(1, 1, 1, 4, 4, 4);
const positionAttribute = geometry.attributes.position;

// Create morph target (stretched X, squashed Y)
const morphPositions = new Float32Array(positionAttribute.count * 3);
for (let i = 0; i < positionAttribute.count; i++) {
  morphPositions[i * 3] = positionAttribute.getX(i) * 2;      // Stretch X
  morphPositions[i * 3 + 1] = positionAttribute.getY(i) * 0.5; // Squash Y
  morphPositions[i * 3 + 2] = positionAttribute.getZ(i);
}

geometry.morphAttributes.position = [
  new THREE.BufferAttribute(morphPositions, 3)
];

// Use with mesh
const mesh = new THREE.Mesh(geometry, material);
mesh.morphTargetInfluences[0] = 0.5;  // 50% blend to morph target

// Animate
function animate() {
  mesh.morphTargetInfluences[0] = (Math.sin(time) + 1) / 2;
}
```

## Geometry Transformations

```javascript
// Transform geometry (affects vertices directly)
geometry.translate(x, y, z);
geometry.rotateX(angle);
geometry.rotateY(angle);
geometry.rotateZ(angle);
geometry.scale(x, y, z);

// Center geometry at origin
geometry.center();

// Apply matrix
geometry.applyMatrix4(matrix);

// Look at direction
geometry.lookAt(vector);
```

## Bounding Volumes

```javascript
// Compute bounding box
geometry.computeBoundingBox();
const box = geometry.boundingBox;
const size = new THREE.Vector3();
box.getSize(size);
const center = new THREE.Vector3();
box.getCenter(center);

// Compute bounding sphere
geometry.computeBoundingSphere();
const sphere = geometry.boundingSphere;
console.log(sphere.center, sphere.radius);
```

## Disposal

```javascript
geometry.dispose();  // Free GPU memory
```
