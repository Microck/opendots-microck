# Three.js Textures

Texture loading, types, configuration, UV mapping, render targets, and environment maps.

## Texture Loading

### Basic Loading

```javascript
const loader = new THREE.TextureLoader();

// Synchronous style (returns texture, loads async)
const texture = loader.load('texture.jpg');
material.map = texture;

// With callbacks
loader.load(
  'texture.jpg',
  (texture) => { console.log('Loaded'); },
  (progress) => { console.log('Progress'); },  // Not always supported
  (error) => { console.error('Error'); }
);
```

### Promise Wrapper

```javascript
function loadTexture(url) {
  return new Promise((resolve, reject) => {
    new THREE.TextureLoader().load(url, resolve, undefined, reject);
  });
}

// Load multiple textures in parallel
const [colorMap, normalMap, roughnessMap] = await Promise.all([
  loadTexture('color.jpg'),
  loadTexture('normal.jpg'),
  loadTexture('roughness.jpg'),
]);
```

## Texture Configuration

### Color Space (Critical!)

```javascript
// Color/albedo/emissive textures - use sRGB
colorTexture.colorSpace = THREE.SRGBColorSpace;
emissiveTexture.colorSpace = THREE.SRGBColorSpace;

// Data textures (normal, roughness, metalness, AO, displacement) - use Linear
// Don't set colorSpace (default is NoColorSpace/Linear)
normalTexture.colorSpace = THREE.NoColorSpace;  // or just don't set it
```

### Wrapping Modes

```javascript
texture.wrapS = THREE.RepeatWrapping;      // Horizontal
texture.wrapT = THREE.RepeatWrapping;      // Vertical

// Options:
// THREE.ClampToEdgeWrapping - Stretch edge pixels (default)
// THREE.RepeatWrapping - Tile the texture
// THREE.MirroredRepeatWrapping - Tile with mirror flip
```

### Repeat, Offset, Rotation

```javascript
// Tile texture 4x4
texture.repeat.set(4, 4);
texture.wrapS = THREE.RepeatWrapping;
texture.wrapT = THREE.RepeatWrapping;

// Offset (0-1 range)
texture.offset.set(0.5, 0.25);

// Rotation (radians, around center)
texture.rotation = Math.PI / 4;
texture.center.set(0.5, 0.5);  // Rotation pivot
```

### Filtering

```javascript
// Minification (texture larger than screen pixels)
texture.minFilter = THREE.LinearMipmapLinearFilter;  // Default, smooth
texture.minFilter = THREE.NearestFilter;             // Pixelated
texture.minFilter = THREE.LinearFilter;              // Smooth, no mipmaps
texture.minFilter = THREE.NearestMipmapNearestFilter;
texture.minFilter = THREE.LinearMipmapNearestFilter;
texture.minFilter = THREE.NearestMipmapLinearFilter;

// Magnification (texture smaller than screen pixels)
texture.magFilter = THREE.LinearFilter;   // Smooth (default)
texture.magFilter = THREE.NearestFilter;  // Pixelated (retro games)

// Anisotropic filtering (sharper at angles)
texture.anisotropy = renderer.capabilities.getMaxAnisotropy();
```

### Mipmaps

```javascript
// Usually true by default
texture.generateMipmaps = true;

// Disable for non-power-of-2 textures or data textures
texture.generateMipmaps = false;
texture.minFilter = THREE.LinearFilter;  // Required when no mipmaps
```

### Flip Y

```javascript
texture.flipY = true;   // Default: flip Y axis (standard for images)
texture.flipY = false;  // For some data textures or video
```

## Texture Types

### Data Texture

Create texture from raw data.

```javascript
// Create gradient texture
const size = 256;
const data = new Uint8Array(size * size * 4);

for (let i = 0; i < size; i++) {
  for (let j = 0; j < size; j++) {
    const index = (i * size + j) * 4;
    data[index] = i;           // R
    data[index + 1] = j;       // G
    data[index + 2] = 128;     // B
    data[index + 3] = 255;     // A
  }
}

const texture = new THREE.DataTexture(data, size, size);
texture.needsUpdate = true;

// Float data texture
const floatData = new Float32Array(size * size * 4);
const floatTexture = new THREE.DataTexture(
  floatData, size, size,
  THREE.RGBAFormat,
  THREE.FloatType
);
```

### Canvas Texture

```javascript
const canvas = document.createElement('canvas');
canvas.width = 256;
canvas.height = 256;
const ctx = canvas.getContext('2d');

// Draw on canvas
ctx.fillStyle = 'red';
ctx.fillRect(0, 0, 256, 256);
ctx.fillStyle = 'white';
ctx.font = '48px Arial';
ctx.fillText('Hello', 50, 150);

const texture = new THREE.CanvasTexture(canvas);

// Update when canvas changes
ctx.fillStyle = 'blue';
ctx.fillRect(0, 0, 100, 100);
texture.needsUpdate = true;
```

### Video Texture

```javascript
const video = document.createElement('video');
video.src = 'video.mp4';
video.loop = true;
video.muted = true;
video.playsInline = true;
video.play();

const texture = new THREE.VideoTexture(video);
texture.colorSpace = THREE.SRGBColorSpace;
texture.minFilter = THREE.LinearFilter;
texture.magFilter = THREE.LinearFilter;
// Auto-updates, no needsUpdate required
```

### Compressed Textures (KTX2)

```javascript
import { KTX2Loader } from 'three/addons/loaders/KTX2Loader.js';

const ktx2Loader = new KTX2Loader();
ktx2Loader.setTranscoderPath('https://cdn.jsdelivr.net/npm/three@0.160.0/examples/jsm/libs/basis/');
ktx2Loader.detectSupport(renderer);

ktx2Loader.load('texture.ktx2', (texture) => {
  material.map = texture;
  material.needsUpdate = true;
});
```

## Cube Textures

For environment maps and skyboxes.

```javascript
const loader = new THREE.CubeTextureLoader();
const cubeTexture = loader.load([
  'px.jpg', 'nx.jpg',  // +X, -X
  'py.jpg', 'ny.jpg',  // +Y, -Y
  'pz.jpg', 'nz.jpg',  // +Z, -Z
]);

// As background
scene.background = cubeTexture;

// As environment map
scene.environment = cubeTexture;
material.envMap = cubeTexture;
```

## HDR Textures

### RGBELoader

```javascript
import { RGBELoader } from 'three/addons/loaders/RGBELoader.js';

const loader = new RGBELoader();
loader.load('environment.hdr', (texture) => {
  texture.mapping = THREE.EquirectangularReflectionMapping;
  scene.environment = texture;
  scene.background = texture;
});
```

### EXRLoader

```javascript
import { EXRLoader } from 'three/addons/loaders/EXRLoader.js';

const loader = new EXRLoader();
loader.load('environment.exr', (texture) => {
  texture.mapping = THREE.EquirectangularReflectionMapping;
  scene.environment = texture;
});
```

### PMREMGenerator

Generate prefiltered environment maps for better PBR quality.

```javascript
const pmremGenerator = new THREE.PMREMGenerator(renderer);
pmremGenerator.compileEquirectangularShader();

new RGBELoader().load('environment.hdr', (texture) => {
  const envMap = pmremGenerator.fromEquirectangular(texture).texture;
  scene.environment = envMap;
  scene.background = envMap;

  texture.dispose();
  pmremGenerator.dispose();
});
```

### Background Options

```javascript
scene.background = texture;
scene.backgroundBlurriness = 0.5;     // 0-1, blur background
scene.backgroundIntensity = 1.0;      // Brightness
scene.backgroundRotation.y = Math.PI; // Rotate background
```

## Render Targets

Render to texture for effects.

```javascript
// Create render target
const renderTarget = new THREE.WebGLRenderTarget(512, 512, {
  minFilter: THREE.LinearFilter,
  magFilter: THREE.LinearFilter,
  format: THREE.RGBAFormat,
  type: THREE.UnsignedByteType,
  depthBuffer: true,
  stencilBuffer: false,
});

// Render scene to target
renderer.setRenderTarget(renderTarget);
renderer.render(scene, camera);
renderer.setRenderTarget(null);  // Back to screen

// Use as texture
material.map = renderTarget.texture;
```

### Depth Texture

```javascript
const renderTarget = new THREE.WebGLRenderTarget(512, 512);
renderTarget.depthTexture = new THREE.DepthTexture(512, 512);
renderTarget.depthTexture.type = THREE.UnsignedShortType;

// Access depth in shader
uniform sampler2D depthTexture;
// float depth = texture2D(depthTexture, vUv).r;
```

### Multi-Sample Render Target (MSAA)

```javascript
const renderTarget = new THREE.WebGLRenderTarget(512, 512, {
  samples: 4,  // MSAA samples
});
```

### Multiple Render Targets (MRT)

```javascript
const renderTarget = new THREE.WebGLMultipleRenderTargets(512, 512, 3);

// Access individual textures
const colorTexture = renderTarget.texture[0];
const normalTexture = renderTarget.texture[1];
const depthTexture = renderTarget.texture[2];
```

## CubeCamera

Dynamic environment maps for reflections.

```javascript
const cubeRenderTarget = new THREE.WebGLCubeRenderTarget(256, {
  generateMipmaps: true,
  minFilter: THREE.LinearMipmapLinearFilter,
});

const cubeCamera = new THREE.CubeCamera(0.1, 1000, cubeRenderTarget);
scene.add(cubeCamera);

// Apply to reflective material
reflectiveMaterial.envMap = cubeRenderTarget.texture;

// Update in animation loop (expensive!)
function animate() {
  // Hide reflective object during capture
  reflectiveObject.visible = false;
  cubeCamera.position.copy(reflectiveObject.position);
  cubeCamera.update(renderer, scene);
  reflectiveObject.visible = true;
}
```

## UV Mapping

### Accessing UVs

```javascript
const uvs = geometry.attributes.uv;

// Read UV
const u = uvs.getX(vertexIndex);
const v = uvs.getY(vertexIndex);

// Modify UV
uvs.setXY(vertexIndex, newU, newV);
uvs.needsUpdate = true;
```

### Second UV Channel (for AO maps)

```javascript
// Copy UV1 to UV2
geometry.setAttribute('uv2', geometry.attributes.uv);

// Or create custom second UV
const uv2 = new Float32Array(vertexCount * 2);
// ... fill uv2 data
geometry.setAttribute('uv2', new THREE.BufferAttribute(uv2, 2));
```

## Texture Atlas

Multiple images in one texture.

```javascript
const atlas = loader.load('atlas.png');
atlas.wrapS = THREE.ClampToEdgeWrapping;
atlas.wrapT = THREE.ClampToEdgeWrapping;

// Select sprite by UV offset/scale
function selectSprite(col, row, gridSize = 4) {
  atlas.offset.set(col / gridSize, 1 - (row + 1) / gridSize);
  atlas.repeat.set(1 / gridSize, 1 / gridSize);
}

// Select top-left sprite
selectSprite(0, 0);
```

## PBR Texture Set

```javascript
const material = new THREE.MeshStandardMaterial({
  // Base color (sRGB)
  map: colorTexture,

  // Surface detail (Linear)
  normalMap: normalTexture,
  normalScale: new THREE.Vector2(1, 1),

  // Roughness (Linear, grayscale)
  roughnessMap: roughnessTexture,
  roughness: 1,  // Multiplier

  // Metalness (Linear, grayscale)
  metalnessMap: metalnessTexture,
  metalness: 1,  // Multiplier

  // Ambient occlusion (Linear, uses uv2)
  aoMap: aoTexture,
  aoMapIntensity: 1,

  // Self-illumination (sRGB)
  emissiveMap: emissiveTexture,
  emissive: 0xffffff,
  emissiveIntensity: 1,

  // Vertex displacement (Linear)
  displacementMap: displacementTexture,
  displacementScale: 0.1,
  displacementBias: 0,

  // Alpha (Linear)
  alphaMap: alphaTexture,
  transparent: true,
});

// Don't forget UV2 for AO
geometry.setAttribute('uv2', geometry.attributes.uv);
```

## Procedural Textures

### Noise Texture

```javascript
function generateNoiseTexture(size = 256) {
  const data = new Uint8Array(size * size * 4);

  for (let i = 0; i < size * size; i++) {
    const value = Math.random() * 255;
    data[i * 4] = value;
    data[i * 4 + 1] = value;
    data[i * 4 + 2] = value;
    data[i * 4 + 3] = 255;
  }

  const texture = new THREE.DataTexture(data, size, size);
  texture.needsUpdate = true;
  return texture;
}
```

### Gradient Texture

```javascript
function generateGradientTexture(color1, color2, size = 256) {
  const canvas = document.createElement('canvas');
  canvas.width = size;
  canvas.height = 1;
  const ctx = canvas.getContext('2d');

  const gradient = ctx.createLinearGradient(0, 0, size, 0);
  gradient.addColorStop(0, color1);
  gradient.addColorStop(1, color2);

  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, size, 1);

  return new THREE.CanvasTexture(canvas);
}
```

### Checkerboard Texture

```javascript
function generateCheckerboard(size = 256, divisions = 8) {
  const canvas = document.createElement('canvas');
  canvas.width = size;
  canvas.height = size;
  const ctx = canvas.getContext('2d');

  const cellSize = size / divisions;

  for (let i = 0; i < divisions; i++) {
    for (let j = 0; j < divisions; j++) {
      ctx.fillStyle = (i + j) % 2 === 0 ? '#ffffff' : '#000000';
      ctx.fillRect(i * cellSize, j * cellSize, cellSize, cellSize);
    }
  }

  const texture = new THREE.CanvasTexture(canvas);
  texture.colorSpace = THREE.SRGBColorSpace;
  return texture;
}
```

## Texture Memory Management

### Dispose Textures

```javascript
// Single texture
texture.dispose();

// All material textures
function disposeMaterialTextures(material) {
  const maps = [
    'map', 'normalMap', 'roughnessMap', 'metalnessMap',
    'aoMap', 'emissiveMap', 'displacementMap', 'alphaMap',
    'envMap', 'lightMap', 'bumpMap', 'specularMap',
    'clearcoatMap', 'clearcoatRoughnessMap', 'clearcoatNormalMap',
    'transmissionMap', 'thicknessMap', 'sheenColorMap', 'sheenRoughnessMap'
  ];

  maps.forEach(mapName => {
    if (material[mapName]) {
      material[mapName].dispose();
    }
  });
}
```

### Texture Pooling

```javascript
class TexturePool {
  constructor() {
    this.textures = new Map();
    this.loader = new THREE.TextureLoader();
  }

  async get(url) {
    if (this.textures.has(url)) {
      return this.textures.get(url);
    }

    const texture = await new Promise((resolve, reject) => {
      this.loader.load(url, resolve, undefined, reject);
    });

    this.textures.set(url, texture);
    return texture;
  }

  dispose(url) {
    const texture = this.textures.get(url);
    if (texture) {
      texture.dispose();
      this.textures.delete(url);
    }
  }

  disposeAll() {
    this.textures.forEach(t => t.dispose());
    this.textures.clear();
  }
}
```

## Performance Tips

1. **Use power-of-2 dimensions**: 256, 512, 1024, 2048
2. **Compress textures**: KTX2/Basis for web delivery
3. **Use texture atlases**: Reduce texture switches
4. **Enable mipmaps**: For distant objects
5. **Limit texture size**: 2048 usually sufficient for web
6. **Reuse textures**: Same texture = better batching

```javascript
// Check texture memory
console.log(renderer.info.memory.textures);

// Optimize for mobile
const maxSize = renderer.capabilities.maxTextureSize;
const isMobile = /iPhone|iPad|Android/i.test(navigator.userAgent);
const textureSize = isMobile ? 1024 : 2048;
```
