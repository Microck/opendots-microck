# Three.js Math Utilities

Vector3, Matrix4, Quaternion, Euler, Color, Box3, Sphere, Plane, and MathUtils.

## Vector3

3D position, direction, or scale.

```javascript
const v = new THREE.Vector3(x, y, z);
const v = new THREE.Vector3();  // (0, 0, 0)

// Set values
v.set(1, 2, 3);
v.setX(1);
v.setY(2);
v.setZ(3);
v.setComponent(0, 1);  // x = 1
v.setScalar(5);        // all = 5

// Clone/copy
const copy = v.clone();
v.copy(otherVector);
```

### Vector3 Operations

```javascript
// Arithmetic
v.add(otherVector);
v.addVectors(a, b);         // v = a + b
v.addScalar(scalar);
v.addScaledVector(v2, s);   // v += v2 * s

v.sub(otherVector);
v.subVectors(a, b);
v.subScalar(scalar);

v.multiply(otherVector);    // Component-wise
v.multiplyScalar(scalar);
v.multiplyVectors(a, b);

v.divide(otherVector);
v.divideScalar(scalar);

// Negate/invert
v.negate();                 // v = -v

// Analysis
v.length();                 // Magnitude
v.lengthSq();               // Squared (faster)
v.manhattanLength();        // |x| + |y| + |z|

v.normalize();              // Make length = 1
v.setLength(length);        // Scale to specific length

v.dot(otherVector);         // Dot product
v.cross(otherVector);       // Cross product
v.crossVectors(a, b);       // v = a × b

v.distanceTo(otherVector);
v.distanceToSquared(otherVector);
v.manhattanDistanceTo(otherVector);

v.angleTo(otherVector);     // Radians between vectors
```

### Vector3 Interpolation

```javascript
v.lerp(targetVector, alpha);      // Linear interpolation
v.lerpVectors(v1, v2, alpha);     // v = lerp(v1, v2, alpha)

// Spherical linear interpolation (for directions)
v.normalize();
target.normalize();
v.lerp(target, alpha);
v.normalize();  // Re-normalize for slerp approximation
```

### Vector3 Clamping

```javascript
v.clamp(minVector, maxVector);
v.clampLength(minLength, maxLength);
v.clampScalar(minVal, maxVal);
v.floor();
v.ceil();
v.round();
v.roundToZero();  // Towards zero
```

### Vector3 Transformation

```javascript
v.applyMatrix3(matrix3);
v.applyMatrix4(matrix4);
v.applyNormalMatrix(normalMatrix);
v.applyQuaternion(quaternion);
v.applyEuler(euler);
v.applyAxisAngle(axis, angle);

// Project/unproject
v.project(camera);      // World to NDC
v.unproject(camera);    // NDC to world

// Reflection
v.reflect(normal);      // Reflect off surface
```

### Vector3 Utility

```javascript
// Random
v.random();             // Components 0-1
v.randomDirection();    // Unit vector, random direction

// Direction to target
const direction = new THREE.Vector3();
direction.subVectors(target.position, source.position).normalize();

// Min/max
v.min(otherVector);     // Component-wise min
v.max(otherVector);     // Component-wise max

// Comparison
v.equals(otherVector);  // Exact equality
v.distanceTo(other) < 0.001  // Approximate

// Array conversion
const array = v.toArray();
v.fromArray([x, y, z]);
v.fromBufferAttribute(attribute, index);
```

## Vector2 & Vector4

Same API as Vector3, different dimensions.

```javascript
const v2 = new THREE.Vector2(x, y);
const v4 = new THREE.Vector4(x, y, z, w);

// Vector2 specific
v2.rotateAround(center, angle);
v2.angle();  // Angle from positive x-axis

// Vector4 specific
v4.applyMatrix4(matrix4);
```

## Quaternion

Rotation without gimbal lock.

```javascript
const q = new THREE.Quaternion();
const q = new THREE.Quaternion(x, y, z, w);

// Identity (no rotation)
q.identity();

// From Euler angles
q.setFromEuler(new THREE.Euler(x, y, z, 'XYZ'));

// From axis-angle
const axis = new THREE.Vector3(0, 1, 0).normalize();
q.setFromAxisAngle(axis, Math.PI / 2);

// From rotation matrix
q.setFromRotationMatrix(matrix4);

// From unit vectors (rotate a to b)
q.setFromUnitVectors(vFrom, vTo);
```

### Quaternion Operations

```javascript
// Multiply (combine rotations)
q.multiply(q2);              // q = q * q2
q.premultiply(q2);           // q = q2 * q
q.multiplyQuaternions(a, b); // q = a * b

// Inverse
q.invert();                  // Conjugate for unit quaternions
q.conjugate();

// Normalize
q.normalize();               // Keep unit length

// Dot product
q.dot(q2);

// Angular distance
q.angleTo(q2);               // Radians between quaternions

// Length
q.length();
q.lengthSq();
```

### Quaternion Interpolation

```javascript
// Spherical linear interpolation (smooth rotation)
q.slerp(targetQuaternion, alpha);
q.slerpQuaternions(q1, q2, alpha);

// Fast approximate slerp
q.lerp(target, alpha);
q.normalize();  // Re-normalize after lerp
```

### Apply Quaternion

```javascript
// To vector
const v = new THREE.Vector3(1, 0, 0);
v.applyQuaternion(q);

// To object
mesh.quaternion.copy(q);
mesh.setRotationFromQuaternion(q);
```

## Euler

Rotation as XYZ angles.

```javascript
const euler = new THREE.Euler(x, y, z, 'XYZ');
// Order: 'XYZ', 'YXZ', 'ZXY', 'ZYX', 'YZX', 'XZY'

// From quaternion
euler.setFromQuaternion(quaternion);
euler.setFromQuaternion(quaternion, 'YXZ');

// From rotation matrix
euler.setFromRotationMatrix(matrix4);
euler.setFromRotationMatrix(matrix4, 'XYZ');

// From vector3 (interpret as rotation)
euler.setFromVector3(vector3);

// Apply to object
mesh.rotation.copy(euler);
mesh.rotation.set(x, y, z);
mesh.rotation.order = 'YXZ';  // FPS games often use this

// Reorder
euler.reorder('YXZ');
```

### Degrees vs Radians

```javascript
// Three.js uses radians
const radians = THREE.MathUtils.degToRad(45);
const degrees = THREE.MathUtils.radToDeg(Math.PI / 4);

mesh.rotation.y = THREE.MathUtils.degToRad(90);
```

## Matrix4

4x4 transformation matrix.

```javascript
const m = new THREE.Matrix4();

// Identity
m.identity();

// Compose from components
m.compose(position, quaternion, scale);

// Decompose to components
const pos = new THREE.Vector3();
const quat = new THREE.Quaternion();
const scale = new THREE.Vector3();
m.decompose(pos, quat, scale);
```

### Matrix4 Creation

```javascript
// Translation
m.makeTranslation(x, y, z);
m.makeTranslation(vector3);

// Rotation
m.makeRotationX(theta);
m.makeRotationY(theta);
m.makeRotationZ(theta);
m.makeRotationAxis(axis, theta);
m.makeRotationFromEuler(euler);
m.makeRotationFromQuaternion(quaternion);

// Scale
m.makeScale(x, y, z);

// Shear
m.makeShear(xy, xz, yx, yz, zx, zy);

// Look at
m.lookAt(eye, target, up);

// Basis vectors
m.makeBasis(xAxis, yAxis, zAxis);
```

### Matrix4 Operations

```javascript
// Multiply
m.multiply(m2);          // m = m * m2
m.premultiply(m2);       // m = m2 * m
m.multiplyMatrices(a, b);

// Scale
m.multiplyScalar(s);

// Invert
m.invert();

// Transpose
m.transpose();

// Extract rotation
const rotationMatrix = new THREE.Matrix4();
rotationMatrix.extractRotation(m);

// Get position
const position = new THREE.Vector3();
position.setFromMatrixPosition(m);

// Get scale
const scale = new THREE.Vector3();
scale.setFromMatrixScale(m);

// Get basis vectors
const xAxis = new THREE.Vector3();
const yAxis = new THREE.Vector3();
const zAxis = new THREE.Vector3();
m.extractBasis(xAxis, yAxis, zAxis);
```

### Matrix4 Camera

```javascript
// Perspective projection
m.makePerspective(left, right, top, bottom, near, far);
m.makePerspective(fov, aspect, near, far);  // Shorthand

// Orthographic projection
m.makeOrthographic(left, right, top, bottom, near, far);

// View matrix (inverse of camera world matrix)
const viewMatrix = camera.matrixWorldInverse;
```

### Apply Matrix4

```javascript
// To vector (position)
v.applyMatrix4(m);

// To vector (direction, ignore translation)
v.transformDirection(m);

// To object
mesh.applyMatrix4(m);
```

## Matrix3

3x3 matrix, often for normals.

```javascript
const m3 = new THREE.Matrix3();

// From Matrix4 (upper-left 3x3)
m3.setFromMatrix4(matrix4);

// Normal matrix
m3.getNormalMatrix(modelViewMatrix);

// Apply to vector
v.applyMatrix3(m3);
v.applyNormalMatrix(m3);
```

## Color

Color manipulation.

```javascript
// Construction
const color = new THREE.Color(0xff0000);      // Hex
const color = new THREE.Color('red');          // CSS name
const color = new THREE.Color('#ff0000');      // CSS hex
const color = new THREE.Color('rgb(255,0,0)'); // CSS rgb
const color = new THREE.Color(1, 0, 0);        // RGB 0-1

// Set
color.set(0x00ff00);
color.setHex(0x00ff00);
color.setRGB(0, 1, 0);
color.setHSL(0.33, 1, 0.5);  // Hue, Saturation, Lightness
color.setColorName('blue');
color.setStyle('rgb(0, 0, 255)');
color.setScalar(0.5);        // All channels same
```

### Color Conversion

```javascript
// Get values
color.getHex();           // 0xff0000
color.getHexString();     // "ff0000"
color.getStyle();         // "rgb(255,0,0)"

// HSL
const hsl = {};
color.getHSL(hsl);        // { h, s, l }
color.setHSL(hsl.h, hsl.s, hsl.l);

// Components
color.r;  // 0-1
color.g;
color.b;
```

### Color Operations

```javascript
color.add(otherColor);
color.addColors(c1, c2);
color.addScalar(s);

color.sub(otherColor);

color.multiply(otherColor);
color.multiplyScalar(s);

// Interpolation
color.lerp(targetColor, alpha);
color.lerpColors(c1, c2, alpha);
color.lerpHSL(targetColor, alpha);

// Comparison
color.equals(otherColor);

// Clone/copy
const copy = color.clone();
color.copy(otherColor);

// Convert between color spaces
color.convertLinearToSRGB();
color.convertSRGBToLinear();

// Offset HSL
color.offsetHSL(deltaH, deltaS, deltaL);
```

## Box3

Axis-aligned bounding box.

```javascript
const box = new THREE.Box3();
const box = new THREE.Box3(min, max);

// From object
box.setFromObject(mesh);
box.setFromObject(mesh, true);  // Precise (slower)

// From points
box.setFromPoints(arrayOfVector3);

// From center + size
box.setFromCenterAndSize(center, size);

// From buffer attribute
box.setFromBufferAttribute(positionAttribute);
```

### Box3 Properties

```javascript
box.min;  // Vector3
box.max;  // Vector3

// Center
const center = new THREE.Vector3();
box.getCenter(center);

// Size
const size = new THREE.Vector3();
box.getSize(size);
```

### Box3 Tests

```javascript
box.containsPoint(point);
box.containsBox(otherBox);

box.intersectsBox(otherBox);
box.intersectsSphere(sphere);
box.intersectsPlane(plane);
box.intersectsTriangle(triangle);

box.isEmpty();  // Zero or negative volume
```

### Box3 Operations

```javascript
box.expandByPoint(point);
box.expandByVector(vector);
box.expandByScalar(scalar);
box.expandByObject(object);

box.intersect(otherBox);   // In-place intersection
box.union(otherBox);       // In-place union

box.applyMatrix4(matrix);  // Transform

box.translate(offset);

box.clampPoint(point, target);  // Clamp point to box

box.distanceToPoint(point);

// Bounding sphere
const sphere = new THREE.Sphere();
box.getBoundingSphere(sphere);
```

## Sphere

Bounding sphere.

```javascript
const sphere = new THREE.Sphere(center, radius);
const sphere = new THREE.Sphere();

// From points
sphere.setFromPoints(arrayOfVector3);
sphere.setFromPoints(points, optionalCenter);

// From box
const box = new THREE.Box3().setFromObject(mesh);
box.getBoundingSphere(sphere);
```

### Sphere Tests

```javascript
sphere.containsPoint(point);
sphere.intersectsSphere(otherSphere);
sphere.intersectsBox(box);
sphere.intersectsPlane(plane);

sphere.isEmpty();  // radius <= 0
```

### Sphere Operations

```javascript
sphere.expandByPoint(point);

sphere.applyMatrix4(matrix);  // Transform

sphere.translate(offset);

sphere.clampPoint(point, target);

sphere.distanceToPoint(point);

sphere.getBoundingBox(box);
```

## Plane

Infinite plane.

```javascript
const plane = new THREE.Plane(normal, constant);
// normal: direction (should be normalized)
// constant: distance from origin along normal

// From normal + point
plane.setFromNormalAndCoplanarPoint(normal, point);

// From 3 coplanar points
plane.setFromCoplanarPoints(a, b, c);

// Normalize
plane.normalize();
```

### Plane Operations

```javascript
// Distance to point (signed)
plane.distanceToPoint(point);

// Distance to sphere
plane.distanceToSphere(sphere);

// Project point onto plane
const projected = new THREE.Vector3();
plane.projectPoint(point, projected);

// Coplanar point
const coplanar = new THREE.Vector3();
plane.coplanarPoint(coplanar);

// Intersection
const line = new THREE.Line3(start, end);
const intersect = new THREE.Vector3();
plane.intersectLine(line, intersect);

// Negate
plane.negate();

// Transform
plane.applyMatrix4(matrix);
```

## Ray

Infinite ray from origin in direction.

```javascript
const ray = new THREE.Ray(origin, direction);

// From camera + mouse
const raycaster = new THREE.Raycaster();
raycaster.setFromCamera(mouse, camera);
const ray = raycaster.ray;
```

### Ray Operations

```javascript
// Point at distance
const point = new THREE.Vector3();
ray.at(distance, point);

// Closest point to target
ray.closestPointToPoint(point, target);

// Distance to point
ray.distanceToPoint(point);
ray.distanceSqToPoint(point);

// Distance to plane
ray.distanceToPlane(plane);

// Intersections
ray.intersectSphere(sphere, target);
ray.intersectBox(box, target);
ray.intersectTriangle(a, b, c, backfaceCulling, target);
ray.intersectsPlane(plane);
ray.intersectsBox(box);
ray.intersectsSphere(sphere);
```

## Curves

Parametric curves for paths.

```javascript
// Built-in curves
const line = new THREE.LineCurve3(start, end);

const quadratic = new THREE.QuadraticBezierCurve3(p0, p1, p2);

const cubic = new THREE.CubicBezierCurve3(p0, p1, p2, p3);

const catmullRom = new THREE.CatmullRomCurve3([
  new THREE.Vector3(-10, 0, 10),
  new THREE.Vector3(-5, 5, 5),
  new THREE.Vector3(0, 0, 0),
  new THREE.Vector3(5, -5, 5),
  new THREE.Vector3(10, 0, 10)
]);

// Closed loop
catmullRom.closed = true;

// Tension
catmullRom.tension = 0.5;  // 0 = smooth, 1 = sharp

// Curve type
catmullRom.curveType = 'catmullrom';  // 'centripetal', 'chordal'
```

### Curve Operations

```javascript
// Get point at t (0-1)
const point = curve.getPoint(0.5);

// Get point at distance (arc length parameterization)
const point = curve.getPointAt(0.5);

// Sample points
const points = curve.getPoints(50);  // 50 segments
const points = curve.getSpacedPoints(50);  // Evenly spaced

// Tangent
const tangent = curve.getTangent(0.5);
const tangent = curve.getTangentAt(0.5);

// Length
const length = curve.getLength();
const lengths = curve.getLengths(50);

// Create geometry
const geometry = new THREE.BufferGeometry().setFromPoints(points);
const line = new THREE.Line(geometry, material);

// Tube geometry
const tubeGeometry = new THREE.TubeGeometry(curve, 64, 1, 8, false);
```

### CurvePath

Combine multiple curves.

```javascript
const path = new THREE.CurvePath();

path.add(curve1);
path.add(curve2);
path.add(curve3);

// Or auto-connect
path.autoClose = true;

const points = path.getPoints(100);
```

## MathUtils

Utility functions.

```javascript
// Conversion
THREE.MathUtils.degToRad(degrees);
THREE.MathUtils.radToDeg(radians);

// Clamping
THREE.MathUtils.clamp(value, min, max);

// Interpolation
THREE.MathUtils.lerp(start, end, alpha);
THREE.MathUtils.inverseLerp(min, max, value);  // Returns alpha
THREE.MathUtils.mapLinear(value, a1, a2, b1, b2);  // Map range

// Smoothing
THREE.MathUtils.smoothstep(x, min, max);   // Hermite
THREE.MathUtils.smootherstep(x, min, max); // Ken Perlin's

// Damping
THREE.MathUtils.damp(current, target, lambda, dt);

// Euclidean modulo (always positive)
THREE.MathUtils.euclideanModulo(n, m);

// Random
THREE.MathUtils.randFloat(low, high);
THREE.MathUtils.randFloatSpread(range);  // -range/2 to range/2
THREE.MathUtils.randInt(low, high);
THREE.MathUtils.seededRandom(seed);

// UUID
THREE.MathUtils.generateUUID();

// Power of two
THREE.MathUtils.isPowerOfTwo(value);
THREE.MathUtils.ceilPowerOfTwo(value);
THREE.MathUtils.floorPowerOfTwo(value);

// Ping-pong (oscillate)
THREE.MathUtils.pingpong(x, length);  // 0→length→0→length...
```

### Common Patterns

```javascript
// Smooth follow
function smoothFollow(current, target, smoothTime, deltaTime) {
  return THREE.MathUtils.damp(current, target, smoothTime, deltaTime);
}

// Wrap angle to -PI to PI
function wrapAngle(angle) {
  return THREE.MathUtils.euclideanModulo(angle + Math.PI, Math.PI * 2) - Math.PI;
}

// Oscillate between 0 and 1
function oscillate(time, frequency = 1) {
  return (Math.sin(time * frequency * Math.PI * 2) + 1) / 2;
}

// Ease in-out
function easeInOut(t) {
  return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
}
```
