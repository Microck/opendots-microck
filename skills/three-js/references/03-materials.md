# Three.js Materials

All material types, PBR workflow, shader materials, and common properties.

## Material Types Overview

| Material | Use Case | Lighting |
|----------|----------|----------|
| MeshBasicMaterial | Unlit, flat colors, wireframes | No |
| MeshLambertMaterial | Matte surfaces, performance | Diffuse only |
| MeshPhongMaterial | Shiny surfaces, specular highlights | Yes |
| MeshStandardMaterial | PBR, realistic materials | Yes (PBR) |
| MeshPhysicalMaterial | Advanced PBR, glass, clearcoat | Yes (PBR+) |
| MeshToonMaterial | Cel-shaded, cartoon look | Toon |
| MeshNormalMaterial | Debug normals | No |
| MeshDepthMaterial | Depth visualization | No |
| MeshMatcapMaterial | Pre-baked lighting in texture | Matcap |
| PointsMaterial | Point clouds | No |
| LineBasicMaterial | Lines | No |
| LineDashedMaterial | Dashed lines | No |
| SpriteMaterial | Billboards | No |
| ShaderMaterial | Custom GLSL | Custom |
| RawShaderMaterial | Full shader control | Custom |

## MeshBasicMaterial

No lighting calculations. Always visible, fast.

```javascript
const material = new THREE.MeshBasicMaterial({
  color: 0xff0000,
  map: texture,                    // Diffuse texture
  alphaMap: alphaTexture,          // Transparency texture
  transparent: true,
  opacity: 0.5,
  side: THREE.DoubleSide,          // FrontSide, BackSide, DoubleSide
  wireframe: false,
  wireframeLinewidth: 1,
  envMap: envTexture,              // Reflection texture
  reflectivity: 1,                 // Env map intensity
  refractionRatio: 0.98,           // For refraction
  combine: THREE.MixOperation,     // MultiplyOperation, MixOperation, AddOperation
  fog: true,                       // Affected by scene fog
});
```

## MeshLambertMaterial

Diffuse-only lighting. Fast, good for matte surfaces.

```javascript
const material = new THREE.MeshLambertMaterial({
  color: 0x00ff00,
  emissive: 0x111111,              // Self-illumination color
  emissiveIntensity: 1,
  emissiveMap: emissiveTexture,
  map: texture,
  envMap: envTexture,
  reflectivity: 0.5,
  flatShading: false,              // Flat vs smooth shading
});
```

## MeshPhongMaterial

Specular highlights. Good for shiny, plastic-like surfaces.

```javascript
const material = new THREE.MeshPhongMaterial({
  color: 0x0000ff,
  specular: 0xffffff,              // Highlight color
  shininess: 100,                  // Highlight sharpness (0-1000)
  emissive: 0x000000,
  map: texture,
  specularMap: specTexture,        // Per-pixel shininess
  normalMap: normalTexture,
  normalScale: new THREE.Vector2(1, 1),
  bumpMap: bumpTexture,
  bumpScale: 1,
  displacementMap: dispTexture,
  displacementScale: 1,
  displacementBias: 0,
  flatShading: false,
});
```

## MeshStandardMaterial (PBR)

Physically-based rendering. Recommended for realistic results.

```javascript
const material = new THREE.MeshStandardMaterial({
  color: 0xffffff,

  // PBR properties
  roughness: 0.5,                  // 0 = mirror, 1 = diffuse
  metalness: 0.0,                  // 0 = dielectric, 1 = metal

  // Textures
  map: colorTexture,               // Base color (sRGB)
  roughnessMap: roughTexture,      // Per-pixel roughness (linear)
  metalnessMap: metalTexture,      // Per-pixel metalness (linear)
  normalMap: normalTexture,        // Surface detail
  normalScale: new THREE.Vector2(1, 1),
  normalMapType: THREE.TangentSpaceNormalMap,  // or ObjectSpaceNormalMap

  aoMap: aoTexture,                // Ambient occlusion (uses uv2!)
  aoMapIntensity: 1,

  displacementMap: dispTexture,    // Vertex displacement
  displacementScale: 0.1,
  displacementBias: 0,

  // Emissive
  emissive: 0x000000,
  emissiveIntensity: 1,
  emissiveMap: emissiveTexture,

  // Environment
  envMap: envTexture,
  envMapIntensity: 1,

  // Alpha
  alphaMap: alphaTexture,
  transparent: true,

  // Other
  flatShading: false,
  wireframe: false,
  fog: true,
});

// Important: aoMap requires second UV channel
geometry.setAttribute('uv2', geometry.attributes.uv);
```

## MeshPhysicalMaterial (Advanced PBR)

Extends MeshStandardMaterial with advanced features.

```javascript
const material = new THREE.MeshPhysicalMaterial({
  // All MeshStandardMaterial properties plus:

  // Clearcoat (car paint, lacquer)
  clearcoat: 1.0,                  // 0-1 clearcoat layer strength
  clearcoatRoughness: 0.1,
  clearcoatMap: ccTexture,
  clearcoatRoughnessMap: ccrTexture,
  clearcoatNormalMap: ccnTexture,
  clearcoatNormalScale: new THREE.Vector2(1, 1),

  // Transmission (glass, water)
  transmission: 1.0,               // 0 = opaque, 1 = fully transparent
  transmissionMap: transTexture,
  thickness: 0.5,                  // Volume thickness for refraction
  thicknessMap: thickTexture,
  attenuationDistance: Infinity,   // Absorption distance
  attenuationColor: new THREE.Color(0xffffff),

  // Refraction
  ior: 1.5,                        // Index of refraction (1.0-2.333)

  // Sheen (fabric, velvet)
  sheen: 1.0,
  sheenRoughness: 0.5,
  sheenColor: new THREE.Color(0xffffff),
  sheenColorMap: sheenTexture,
  sheenRoughnessMap: sheenRoughTexture,

  // Iridescence (soap bubbles, oil slicks)
  iridescence: 1.0,
  iridescenceIOR: 1.3,
  iridescenceThicknessRange: [100, 400],
  iridescenceMap: iridTexture,
  iridescenceThicknessMap: iridThickTexture,

  // Anisotropy (brushed metal)
  anisotropy: 1.0,
  anisotropyRotation: 0,
  anisotropyMap: anisoTexture,

  // Specular
  specularIntensity: 1,
  specularColor: new THREE.Color(0xffffff),
  specularIntensityMap: specIntTexture,
  specularColorMap: specColorTexture,
});
```

### Common Physical Material Recipes

```javascript
// Glass
const glass = new THREE.MeshPhysicalMaterial({
  color: 0xffffff,
  metalness: 0,
  roughness: 0,
  transmission: 1,
  thickness: 0.5,
  ior: 1.5,
});

// Tinted glass
const tintedGlass = new THREE.MeshPhysicalMaterial({
  color: 0x88ccff,
  metalness: 0,
  roughness: 0,
  transmission: 0.9,
  thickness: 1,
  ior: 1.5,
  attenuationColor: new THREE.Color(0x0066ff),
  attenuationDistance: 0.5,
});

// Car paint
const carPaint = new THREE.MeshPhysicalMaterial({
  color: 0xff0000,
  metalness: 0.9,
  roughness: 0.5,
  clearcoat: 1,
  clearcoatRoughness: 0.1,
});

// Fabric/velvet
const fabric = new THREE.MeshPhysicalMaterial({
  color: 0x8b0000,
  roughness: 1,
  metalness: 0,
  sheen: 1,
  sheenRoughness: 0.5,
  sheenColor: new THREE.Color(0xff4444),
});

// Brushed metal
const brushedMetal = new THREE.MeshPhysicalMaterial({
  color: 0xaaaaaa,
  metalness: 1,
  roughness: 0.4,
  anisotropy: 1,              // 0-1 strength of directional reflection
  anisotropyRotation: 0,       // Rotation in radians (counter-clockwise)
});

// With anisotropy map for complex surfaces (hair, scratches)
const scratched = new THREE.MeshPhysicalMaterial({
  color: 0xcccccc,
  metalness: 1,
  roughness: 0.3,
  anisotropy: 1,
  anisotropyMap: textureLoader.load('anisotropy.png'),
  // Map channels:
  // R,G = direction in tangent space [-1, 1]
  // B = strength [0, 1] (multiplied by anisotropy)
});
```

## MeshToonMaterial

Cel-shaded cartoon look.

```javascript
const material = new THREE.MeshToonMaterial({
  color: 0x00ff00,
  gradientMap: gradientTexture,    // Optional custom shading gradient
});

// Create step gradient texture (3 tones)
const colors = new Uint8Array([0, 128, 255]);
const gradientMap = new THREE.DataTexture(colors, 3, 1, THREE.RedFormat);
gradientMap.minFilter = THREE.NearestFilter;
gradientMap.magFilter = THREE.NearestFilter;
gradientMap.needsUpdate = true;

// 5 tones
const colors5 = new Uint8Array([0, 64, 128, 192, 255]);
const gradientMap5 = new THREE.DataTexture(colors5, 5, 1, THREE.RedFormat);
gradientMap5.minFilter = THREE.NearestFilter;
gradientMap5.magFilter = THREE.NearestFilter;
gradientMap5.needsUpdate = true;
```

## MeshMatcapMaterial

Pre-baked lighting from matcap texture.

```javascript
const material = new THREE.MeshMatcapMaterial({
  matcap: matcapTexture,           // Matcap image
  color: 0xffffff,
  flatShading: false,
  normalMap: normalTexture,
  normalScale: new THREE.Vector2(1, 1),
});
```

## MeshNormalMaterial

Visualize surface normals. Useful for debugging.

```javascript
const material = new THREE.MeshNormalMaterial({
  flatShading: false,
  wireframe: false,
});
```

## MeshDepthMaterial

Render depth values. Used for shadow maps, DOF effects.

```javascript
const material = new THREE.MeshDepthMaterial({
  depthPacking: THREE.RGBADepthPacking,  // or BasicDepthPacking
});
```

## PointsMaterial

For point clouds.

```javascript
const material = new THREE.PointsMaterial({
  color: 0xffffff,
  size: 0.1,
  sizeAttenuation: true,           // Scale with distance
  map: pointTexture,
  alphaMap: alphaTexture,
  transparent: true,
  alphaTest: 0.5,                  // Discard pixels below threshold
  vertexColors: true,              // Use per-vertex colors
  depthWrite: false,               // For transparency
});

const points = new THREE.Points(geometry, material);
```

## LineBasicMaterial & LineDashedMaterial

```javascript
// Solid lines
const lineMaterial = new THREE.LineBasicMaterial({
  color: 0xffffff,
  linewidth: 1,                    // Note: >1 only works on some systems
  linecap: 'round',
  linejoin: 'round',
  vertexColors: false,
});

// Dashed lines
const dashedMaterial = new THREE.LineDashedMaterial({
  color: 0xffffff,
  dashSize: 0.5,
  gapSize: 0.25,
  scale: 1,
});

const line = new THREE.Line(geometry, dashedMaterial);
line.computeLineDistances();       // Required for dashed lines
```

## SpriteMaterial

For billboards that always face camera.

```javascript
const material = new THREE.SpriteMaterial({
  map: texture,
  color: 0xffffff,
  rotation: 0,
  sizeAttenuation: true,
  transparent: true,
});

const sprite = new THREE.Sprite(material);
sprite.scale.set(2, 2, 1);
scene.add(sprite);
```

## ShaderMaterial

Custom GLSL shaders with Three.js uniforms.

```javascript
const material = new THREE.ShaderMaterial({
  uniforms: {
    time: { value: 0 },
    color: { value: new THREE.Color(0xff0000) },
    map: { value: texture },
  },
  vertexShader: `
    varying vec2 vUv;
    uniform float time;

    void main() {
      vUv = uv;
      vec3 pos = position;
      pos.z += sin(pos.x * 10.0 + time) * 0.1;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
    }
  `,
  fragmentShader: `
    varying vec2 vUv;
    uniform vec3 color;
    uniform sampler2D map;

    void main() {
      vec4 texColor = texture2D(map, vUv);
      gl_FragColor = vec4(color * texColor.rgb, 1.0);
    }
  `,
  transparent: true,
  side: THREE.DoubleSide,
  wireframe: false,
  depthTest: true,
  depthWrite: true,
});

// Update in animation loop
material.uniforms.time.value = clock.getElapsedTime();
```

### Built-in Uniforms & Attributes

```glsl
// Vertex shader - automatically provided
uniform mat4 modelMatrix;         // Object to world
uniform mat4 modelViewMatrix;     // Object to camera
uniform mat4 projectionMatrix;    // Camera projection
uniform mat4 viewMatrix;          // World to camera
uniform mat3 normalMatrix;        // Transform normals
uniform vec3 cameraPosition;      // Camera world position

attribute vec3 position;          // Vertex position
attribute vec3 normal;            // Vertex normal
attribute vec2 uv;                // Texture coordinates
attribute vec2 uv2;               // Second UV channel
attribute vec3 color;             // Vertex color (if using)
```

## RawShaderMaterial

Full control - no built-in uniforms/attributes.

```javascript
const material = new THREE.RawShaderMaterial({
  glslVersion: THREE.GLSL3,
  uniforms: {
    projectionMatrix: { value: camera.projectionMatrix },
    modelViewMatrix: { value: new THREE.Matrix4() },
  },
  vertexShader: `#version 300 es
    in vec3 position;
    uniform mat4 projectionMatrix;
    uniform mat4 modelViewMatrix;

    void main() {
      gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
  `,
  fragmentShader: `#version 300 es
    precision highp float;
    out vec4 fragColor;

    void main() {
      fragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
  `,
});
```

## Common Material Properties

All materials share these base properties:

```javascript
// Visibility
material.visible = true;
material.transparent = false;
material.opacity = 1.0;
material.alphaTest = 0;            // Discard pixels with alpha < value
material.alphaToCoverage = false;  // MSAA alpha

// Rendering
material.side = THREE.FrontSide;   // FrontSide, BackSide, DoubleSide
material.depthTest = true;
material.depthWrite = true;
material.depthFunc = THREE.LessEqualDepth;
material.colorWrite = true;

// Blending
material.blending = THREE.NormalBlending;
// NormalBlending, AdditiveBlending, SubtractiveBlending,
// MultiplyBlending, CustomBlending

// Custom blending
material.blending = THREE.CustomBlending;
material.blendSrc = THREE.SrcAlphaFactor;
material.blendDst = THREE.OneMinusSrcAlphaFactor;
material.blendEquation = THREE.AddEquation;

// Stencil
material.stencilWrite = false;
material.stencilFunc = THREE.AlwaysStencilFunc;
material.stencilRef = 0;
material.stencilMask = 0xff;
material.stencilFail = THREE.KeepStencilOp;
material.stencilZFail = THREE.KeepStencilOp;
material.stencilZPass = THREE.KeepStencilOp;

// Polygon offset (z-fighting fix)
material.polygonOffset = true;
material.polygonOffsetFactor = 1;
material.polygonOffsetUnits = 1;

// Misc
material.dithering = false;
material.toneMapped = true;
material.premultipliedAlpha = false;
material.forceSinglePass = false;
```

## Multiple Materials

```javascript
// BoxGeometry has 6 groups by default
const materials = [
  new THREE.MeshBasicMaterial({ color: 0xff0000 }),  // right (+X)
  new THREE.MeshBasicMaterial({ color: 0x00ff00 }),  // left (-X)
  new THREE.MeshBasicMaterial({ color: 0x0000ff }),  // top (+Y)
  new THREE.MeshBasicMaterial({ color: 0xffff00 }),  // bottom (-Y)
  new THREE.MeshBasicMaterial({ color: 0xff00ff }),  // front (+Z)
  new THREE.MeshBasicMaterial({ color: 0x00ffff }),  // back (-Z)
];
const mesh = new THREE.Mesh(new THREE.BoxGeometry(), materials);

// Custom groups
geometry.clearGroups();
geometry.addGroup(0, 6, 0);    // start index, count, material index
geometry.addGroup(6, 6, 1);
```

## Environment Maps

```javascript
// Cube texture environment
const cubeLoader = new THREE.CubeTextureLoader();
const envMap = cubeLoader.load([
  'px.jpg', 'nx.jpg',
  'py.jpg', 'ny.jpg',
  'pz.jpg', 'nz.jpg',
]);

material.envMap = envMap;
material.envMapIntensity = 1;

// Or set scene environment (affects all PBR materials)
scene.environment = envMap;

// HDR environment (recommended)
import { RGBELoader } from 'three/addons/loaders/RGBELoader.js';

new RGBELoader().load('environment.hdr', (texture) => {
  texture.mapping = THREE.EquirectangularReflectionMapping;
  scene.environment = texture;
  scene.background = texture;
});
```

## Material Modification

```javascript
// Clone material
const clone = material.clone();
clone.color.set(0x00ff00);

// Modify at runtime
material.color.set(0xff0000);
material.opacity = 0.5;
material.transparent = true;
material.needsUpdate = true;  // Required for some changes

// When needsUpdate is required:
// - Changing flatShading
// - Changing transparent
// - Modifying defines
// - Changing shader code
```

## onBeforeCompile

Modify built-in material shaders:

```javascript
material.onBeforeCompile = (shader) => {
  // Add uniforms
  shader.uniforms.time = { value: 0 };

  // Modify vertex shader
  shader.vertexShader = shader.vertexShader.replace(
    '#include <begin_vertex>',
    `
    #include <begin_vertex>
    transformed.z += sin(transformed.x * 10.0 + time) * 0.1;
    `
  );

  // Store reference for updates
  material.userData.shader = shader;
};

// Update in animation loop
if (material.userData.shader) {
  material.userData.shader.uniforms.time.value = clock.getElapsedTime();
}
```

## Depth, Alpha & Render Order

### Alpha Testing (Cutout Transparency)

Discard pixels below alpha threshold. Faster than transparency.

```javascript
// Cutout material (leaves, fences, etc.)
const material = new THREE.MeshStandardMaterial({
  map: leafTexture,
  alphaMap: leafAlphaTexture,
  alphaTest: 0.5,         // Discard pixels with alpha < 0.5
  side: THREE.DoubleSide,
  // Note: transparent is NOT needed with alphaTest
});

// Compare: alphaTest vs transparency
// alphaTest: Hard edges, no sorting needed, fast
// transparent: Soft edges, requires sorting, slower
```

### Depth Testing Modes

```javascript
// depthFunc options
material.depthFunc = THREE.LessEqualDepth;      // Default
material.depthFunc = THREE.LessDepth;
material.depthFunc = THREE.EqualDepth;
material.depthFunc = THREE.GreaterEqualDepth;
material.depthFunc = THREE.GreaterDepth;
material.depthFunc = THREE.NotEqualDepth;
material.depthFunc = THREE.AlwaysDepth;         // Always pass
material.depthFunc = THREE.NeverDepth;          // Never pass

// Disable depth testing (always visible)
material.depthTest = false;

// Disable depth writing (doesn't occlude others)
material.depthWrite = false;
```

### Polygon Offset (Z-Fighting Fix)

Prevent flickering between coplanar surfaces.

```javascript
// Decal on surface
const decalMaterial = new THREE.MeshBasicMaterial({
  map: decalTexture,
  transparent: true,
  polygonOffset: true,
  polygonOffsetFactor: -1,  // Negative = closer to camera
  polygonOffsetUnits: -1,
});

// Outline effect (render slightly larger behind)
const outlineMaterial = new THREE.MeshBasicMaterial({
  color: 0x000000,
  side: THREE.BackSide,
  polygonOffset: true,
  polygonOffsetFactor: 1,   // Positive = further from camera
  polygonOffsetUnits: 1,
});
```

### Render Order

Control draw order for correct transparency.

```javascript
// Render order is on the mesh, not material
mesh.renderOrder = 0;           // Default
backgroundMesh.renderOrder = -1; // Render first
foregroundMesh.renderOrder = 1;  // Render last

// Example: Layered transparent objects
const background = new THREE.Mesh(bgGeometry, bgMaterial);
const midground = new THREE.Mesh(midGeometry, midMaterial);
const foreground = new THREE.Mesh(fgGeometry, fgMaterial);

background.renderOrder = 0;
midground.renderOrder = 1;
foreground.renderOrder = 2;

// Disable auto-sorting for manual control
renderer.sortObjects = false;
```

### Custom Blending

Full control over how colors combine.

```javascript
// Additive glow (fire, lasers, lights)
const glowMaterial = new THREE.MeshBasicMaterial({
  color: 0xff6600,
  transparent: true,
  blending: THREE.AdditiveBlending,
  depthWrite: false,
});

// Multiply (shadows, darkening)
const shadowMaterial = new THREE.MeshBasicMaterial({
  color: 0x000000,
  transparent: true,
  opacity: 0.5,
  blending: THREE.MultiplyBlending,
});

// Custom blend function
const customMaterial = new THREE.MeshBasicMaterial({
  transparent: true,
  blending: THREE.CustomBlending,
  blendEquation: THREE.AddEquation,           // Add, Subtract, ReverseSubtract, Min, Max
  blendSrc: THREE.SrcAlphaFactor,             // Source factor
  blendDst: THREE.OneMinusSrcAlphaFactor,     // Destination factor
  blendSrcAlpha: THREE.OneFactor,             // Source alpha factor
  blendDstAlpha: THREE.OneMinusSrcAlphaFactor,// Destination alpha factor
});

// Blend factors:
// ZeroFactor, OneFactor, SrcColorFactor, OneMinusSrcColorFactor,
// SrcAlphaFactor, OneMinusSrcAlphaFactor, DstAlphaFactor,
// OneMinusDstAlphaFactor, DstColorFactor, OneMinusDstColorFactor,
// SrcAlphaSaturateFactor
```

### Stencil Buffer

Advanced masking effects.

```javascript
// Write to stencil (mask shape)
const maskMaterial = new THREE.MeshBasicMaterial({
  colorWrite: false,
  depthWrite: false,
  stencilWrite: true,
  stencilFunc: THREE.AlwaysStencilFunc,
  stencilRef: 1,
  stencilZPass: THREE.ReplaceStencilOp,
});

// Read from stencil (only draw where mask exists)
const maskedMaterial = new THREE.MeshBasicMaterial({
  color: 0xff0000,
  stencilWrite: false,
  stencilFunc: THREE.EqualStencilFunc,
  stencilRef: 1,
});

// Portal/window effect
const portalMask = new THREE.Mesh(portalGeometry, maskMaterial);
portalMask.renderOrder = 1;

const portalContent = new THREE.Mesh(contentGeometry, maskedMaterial);
portalContent.renderOrder = 2;
```

## Performance Tips

1. **Reuse materials**: Same material instance = batched draw calls
2. **Use simpler materials**: Basic > Lambert > Phong > Standard > Physical
3. **Avoid transparency when possible**: Requires sorting
4. **Use alphaTest instead of transparency**: When applicable
5. **Limit active lights**: Each light adds shader complexity

```javascript
// Material pooling
const materialCache = new Map();

function getMaterial(color) {
  const key = color.toString(16);
  if (!materialCache.has(key)) {
    materialCache.set(key, new THREE.MeshStandardMaterial({ color }));
  }
  return materialCache.get(key);
}

// Dispose when done
material.dispose();
```
