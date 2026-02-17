# Three.js Loaders

Asset loading: GLTF, textures, HDR, compression, async patterns, and error handling.

## LoadingManager

Coordinate multiple loaders and track progress.

```javascript
const manager = new THREE.LoadingManager();

manager.onStart = (url, loaded, total) => {
  console.log(`Started: ${url} (${loaded}/${total})`);
};

manager.onProgress = (url, loaded, total) => {
  const progress = (loaded / total) * 100;
  updateProgressBar(progress);
};

manager.onLoad = () => {
  hideLoadingScreen();
  startApp();
};

manager.onError = (url) => {
  console.error(`Error loading: ${url}`);
};

// Use manager with all loaders
const textureLoader = new THREE.TextureLoader(manager);
const gltfLoader = new GLTFLoader(manager);
```

## GLTF/GLB Loading

The most common 3D format for web.

```javascript
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';

const loader = new GLTFLoader();

loader.load('model.glb', (gltf) => {
  const model = gltf.scene;
  scene.add(model);

  // Animations
  if (gltf.animations.length > 0) {
    const mixer = new THREE.AnimationMixer(model);
    gltf.animations.forEach(clip => {
      mixer.clipAction(clip).play();
    });
  }

  // Cameras (if any)
  const cameras = gltf.cameras;

  // Asset info
  console.log(gltf.asset);  // Version, generator, etc.
});
```

### GLTF with Draco Compression

```javascript
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { DRACOLoader } from 'three/addons/loaders/DRACOLoader.js';

const dracoLoader = new DRACOLoader();
dracoLoader.setDecoderPath('https://www.gstatic.com/draco/versioned/decoders/1.5.6/');
dracoLoader.preload();

const gltfLoader = new GLTFLoader();
gltfLoader.setDRACOLoader(dracoLoader);

gltfLoader.load('compressed-model.glb', (gltf) => {
  scene.add(gltf.scene);
});
```

### GLTF with Meshopt Compression

Meshopt provides better compression ratios than Draco for many models:

```javascript
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { MeshoptDecoder } from 'three/addons/libs/meshopt_decoder.module.js';

const gltfLoader = new GLTFLoader();
gltfLoader.setMeshoptDecoder(MeshoptDecoder);

gltfLoader.load('meshopt-model.glb', (gltf) => {
  scene.add(gltf.scene);
});
```

### GLTF with KTX2 Textures

```javascript
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { KTX2Loader } from 'three/addons/loaders/KTX2Loader.js';

const ktx2Loader = new KTX2Loader();
ktx2Loader.setTranscoderPath('https://cdn.jsdelivr.net/npm/three@0.160.0/examples/jsm/libs/basis/');
ktx2Loader.detectSupport(renderer);

const gltfLoader = new GLTFLoader();
gltfLoader.setKTX2Loader(ktx2Loader);

gltfLoader.load('model-with-ktx2.glb', (gltf) => {
  scene.add(gltf.scene);
});
```

### Process GLTF Content

```javascript
loader.load('model.glb', (gltf) => {
  const model = gltf.scene;

  // Enable shadows
  model.traverse((child) => {
    if (child.isMesh) {
      child.castShadow = true;
      child.receiveShadow = true;
    }
  });

  // Find specific mesh by name
  const head = model.getObjectByName('Head');

  // Adjust materials
  model.traverse((child) => {
    if (child.isMesh && child.material) {
      child.material.envMapIntensity = 0.5;
      // Fix double-sided rendering if needed
      child.material.side = THREE.FrontSide;
    }
  });

  // Center and scale
  const box = new THREE.Box3().setFromObject(model);
  const center = box.getCenter(new THREE.Vector3());
  const size = box.getSize(new THREE.Vector3());

  model.position.sub(center);
  const maxDim = Math.max(size.x, size.y, size.z);
  model.scale.setScalar(1 / maxDim);

  scene.add(model);
});
```

## Other Model Formats

### OBJ + MTL

```javascript
import { OBJLoader } from 'three/addons/loaders/OBJLoader.js';
import { MTLLoader } from 'three/addons/loaders/MTLLoader.js';

const mtlLoader = new MTLLoader();
mtlLoader.load('model.mtl', (materials) => {
  materials.preload();

  const objLoader = new OBJLoader();
  objLoader.setMaterials(materials);
  objLoader.load('model.obj', (object) => {
    scene.add(object);
  });
});
```

### FBX

```javascript
import { FBXLoader } from 'three/addons/loaders/FBXLoader.js';

const loader = new FBXLoader();
loader.load('model.fbx', (object) => {
  // FBX often has large scale
  object.scale.setScalar(0.01);

  // Animations
  if (object.animations.length > 0) {
    const mixer = new THREE.AnimationMixer(object);
    object.animations.forEach(clip => {
      mixer.clipAction(clip).play();
    });
  }

  scene.add(object);
});
```

### STL

```javascript
import { STLLoader } from 'three/addons/loaders/STLLoader.js';

const loader = new STLLoader();
loader.load('model.stl', (geometry) => {
  geometry.computeVertexNormals();
  const material = new THREE.MeshStandardMaterial({ color: 0x888888 });
  const mesh = new THREE.Mesh(geometry, material);
  scene.add(mesh);
});
```

### PLY

```javascript
import { PLYLoader } from 'three/addons/loaders/PLYLoader.js';

const loader = new PLYLoader();
loader.load('model.ply', (geometry) => {
  geometry.computeVertexNormals();

  // Check for vertex colors
  const material = geometry.attributes.color
    ? new THREE.MeshStandardMaterial({ vertexColors: true })
    : new THREE.MeshStandardMaterial({ color: 0x888888 });

  const mesh = new THREE.Mesh(geometry, material);
  scene.add(mesh);
});
```

### Collada (DAE)

```javascript
import { ColladaLoader } from 'three/addons/loaders/ColladaLoader.js';

const loader = new ColladaLoader();
loader.load('model.dae', (collada) => {
  scene.add(collada.scene);

  // Animations
  const animations = collada.animations;
  const mixer = new THREE.AnimationMixer(collada.scene);
  animations.forEach(clip => mixer.clipAction(clip).play());
});
```

### 3DS

```javascript
import { TDSLoader } from 'three/addons/loaders/TDSLoader.js';

const loader = new TDSLoader();
loader.load('model.3ds', (object) => {
  scene.add(object);
});
```

## Specialized Loaders

### SVG Loader

```javascript
import { SVGLoader } from 'three/addons/loaders/SVGLoader.js';

const loader = new SVGLoader();
loader.load('image.svg', (data) => {
  const paths = data.paths;
  const group = new THREE.Group();

  paths.forEach((path) => {
    const material = new THREE.MeshBasicMaterial({
      color: path.color,
      side: THREE.DoubleSide,
      depthWrite: false
    });

    const shapes = SVGLoader.createShapes(path);
    shapes.forEach((shape) => {
      // Flat 2D
      const geometry = new THREE.ShapeGeometry(shape);
      // Or extruded 3D
      // const geometry = new THREE.ExtrudeGeometry(shape, { depth: 10, bevelEnabled: false });

      const mesh = new THREE.Mesh(geometry, material);
      group.add(mesh);
    });
  });

  scene.add(group);
});
```

### Font Loader (Text)

```javascript
import { FontLoader } from 'three/addons/loaders/FontLoader.js';
import { TextGeometry } from 'three/addons/geometries/TextGeometry.js';

const fontLoader = new FontLoader();
fontLoader.load('fonts/helvetiker_regular.typeface.json', (font) => {
  const geometry = new TextGeometry('Hello World', {
    font: font,
    size: 80,
    depth: 5,
    curveSegments: 12,
    bevelEnabled: true,
    bevelThickness: 10,
    bevelSize: 8,
    bevelSegments: 5
  });

  const mesh = new THREE.Mesh(geometry, material);
  scene.add(mesh);
});
```

### PDB Loader (Molecules)

```javascript
import { PDBLoader } from 'three/addons/loaders/PDBLoader.js';

const loader = new PDBLoader();
loader.load('molecule.pdb', (pdb) => {
  const geometryAtoms = pdb.geometryAtoms;
  const geometryBonds = pdb.geometryBonds;
  const json = pdb.json;

  // Render atoms
  const atoms = new THREE.Points(geometryAtoms, atomMaterial);
  scene.add(atoms);

  // Render bonds
  const bonds = new THREE.LineSegments(geometryBonds, bondMaterial);
  scene.add(bonds);
});
```

### LDraw Loader (LEGO)

```javascript
import { LDrawLoader } from 'three/addons/loaders/LDrawLoader.js';

const loader = new LDrawLoader();
loader.setPath('ldraw/');

loader.load('model.mpd', (group) => {
  scene.add(group);
});
```

## HDR/Environment Loaders

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

```javascript
const pmremGenerator = new THREE.PMREMGenerator(renderer);
pmremGenerator.compileEquirectangularShader();

new RGBELoader().load('environment.hdr', (texture) => {
  const envMap = pmremGenerator.fromEquirectangular(texture).texture;
  scene.environment = envMap;

  texture.dispose();
  pmremGenerator.dispose();
});
```

## Async/Promise Loading

### Promisified Loader

```javascript
function loadModel(url) {
  return new Promise((resolve, reject) => {
    const loader = new GLTFLoader();
    loader.load(url, resolve, undefined, reject);
  });
}

function loadTexture(url) {
  return new Promise((resolve, reject) => {
    new THREE.TextureLoader().load(url, resolve, undefined, reject);
  });
}

function loadHDR(url) {
  return new Promise((resolve, reject) => {
    new RGBELoader().load(url, (texture) => {
      texture.mapping = THREE.EquirectangularReflectionMapping;
      resolve(texture);
    }, undefined, reject);
  });
}

// Usage
async function init() {
  try {
    const gltf = await loadModel('model.glb');
    scene.add(gltf.scene);
  } catch (error) {
    console.error('Failed to load:', error);
  }
}
```

### Load Multiple Assets in Parallel

```javascript
async function loadAssets() {
  const [modelGltf, envTexture, colorTexture, normalTexture] = await Promise.all([
    loadModel('model.glb'),
    loadHDR('environment.hdr'),
    loadTexture('color.jpg'),
    loadTexture('normal.jpg'),
  ]);

  scene.add(modelGltf.scene);
  scene.environment = envTexture;

  material.map = colorTexture;
  material.normalMap = normalTexture;
}
```

## Error Handling

### Graceful Fallback

```javascript
async function loadWithFallback(primaryUrl, fallbackUrl) {
  try {
    return await loadModel(primaryUrl);
  } catch (error) {
    console.warn(`Primary failed, trying fallback: ${error}`);
    return await loadModel(fallbackUrl);
  }
}
```

### Retry Logic

```javascript
async function loadWithRetry(url, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await loadModel(url);
    } catch (error) {
      console.warn(`Attempt ${i + 1} failed: ${error}`);
      if (i === maxRetries - 1) throw error;
      await new Promise(r => setTimeout(r, 1000 * (i + 1)));  // Exponential backoff
    }
  }
}
```

### Timeout

```javascript
function loadWithTimeout(url, timeout = 30000) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      reject(new Error('Loading timed out'));
    }, timeout);

    loadModel(url)
      .then((result) => {
        clearTimeout(timer);
        resolve(result);
      })
      .catch((error) => {
        clearTimeout(timer);
        reject(error);
      });
  });
}
```

## Caching

### Built-in Cache

```javascript
// Enable cache
THREE.Cache.enabled = true;

// Clear cache
THREE.Cache.clear();

// Manual cache management
THREE.Cache.add('key', data);
THREE.Cache.get('key');
THREE.Cache.remove('key');
```

### Custom Asset Manager

```javascript
class AssetManager {
  constructor() {
    this.textures = new Map();
    this.models = new Map();
    this.gltfLoader = new GLTFLoader();
    this.textureLoader = new THREE.TextureLoader();
  }

  async loadTexture(key, url) {
    if (this.textures.has(key)) {
      return this.textures.get(key);
    }

    const texture = await new Promise((resolve, reject) => {
      this.textureLoader.load(url, resolve, undefined, reject);
    });

    this.textures.set(key, texture);
    return texture;
  }

  async loadModel(key, url) {
    if (this.models.has(key)) {
      return this.models.get(key).clone();
    }

    const gltf = await new Promise((resolve, reject) => {
      this.gltfLoader.load(url, resolve, undefined, reject);
    });

    this.models.set(key, gltf.scene);
    return gltf.scene.clone();
  }

  getModel(key) {
    const model = this.models.get(key);
    return model ? model.clone() : null;
  }

  dispose() {
    this.textures.forEach(t => t.dispose());
    this.textures.clear();
    this.models.clear();
  }
}

// Usage
const assets = new AssetManager();
const texture = await assets.loadTexture('brick', 'brick.jpg');
const model = await assets.loadModel('tree', 'tree.glb');
```

## Loading from Different Sources

### Data URL / Base64

```javascript
const texture = new THREE.TextureLoader().load('data:image/png;base64,iVBORw0KGgo...');
```

### Blob URL

```javascript
async function loadFromBlob(blob) {
  const url = URL.createObjectURL(blob);
  try {
    const texture = await loadTexture(url);
    return texture;
  } finally {
    URL.revokeObjectURL(url);
  }
}
```

### ArrayBuffer

```javascript
const response = await fetch('model.glb');
const buffer = await response.arrayBuffer();

const loader = new GLTFLoader();
loader.parse(buffer, '', (gltf) => {
  scene.add(gltf.scene);
});
```

### Custom Path/URL

```javascript
// Set base path
loader.setPath('assets/models/');
loader.load('model.glb');  // Loads from assets/models/model.glb

// Set resource path (for textures referenced in model)
loader.setResourcePath('assets/textures/');

// Custom URL modifier
manager.setURLModifier((url) => {
  return `https://cdn.example.com/${url}`;
});
```

## Additional Specialized Loaders

### 3MF Loader (Modern 3D Printing)

```javascript
import { ThreeMFLoader } from 'three/addons/loaders/3MFLoader.js';

const loader = new ThreeMFLoader();
loader.load('model.3mf', (object) => {
  scene.add(object);

  // 3MF supports colors and materials
  object.traverse((child) => {
    if (child.isMesh) {
      child.castShadow = true;
      child.receiveShadow = true;
    }
  });
});
```

### VRML Loader (Virtual Reality Modeling Language)

```javascript
import { VRMLLoader } from 'three/addons/loaders/VRMLLoader.js';

const loader = new VRMLLoader();
loader.load('model.wrl', (scene) => {
  // VRML scenes may have their own coordinate system
  scene.rotation.x = -Math.PI / 2;  // Often needed
  scene.add(scene);
});
```

### VTK Loader (Scientific Visualization)

```javascript
import { VTKLoader } from 'three/addons/loaders/VTKLoader.js';

const loader = new VTKLoader();
loader.load('model.vtk', (geometry) => {
  geometry.computeVertexNormals();

  // VTK often contains scientific data
  const material = new THREE.MeshStandardMaterial({
    color: 0x0077ff,
    flatShading: true,
  });

  const mesh = new THREE.Mesh(geometry, material);
  scene.add(mesh);
});
```

### USDZ Exporter (Apple AR Quick Look)

Export scenes for iOS AR viewing.

```javascript
import { USDZExporter } from 'three/addons/exporters/USDZExporter.js';

async function exportToUSDZ(scene) {
  const exporter = new USDZExporter();
  const arraybuffer = await exporter.parse(scene);

  // Create download link
  const blob = new Blob([arraybuffer], { type: 'application/octet-stream' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = 'model.usdz';
  link.click();

  URL.revokeObjectURL(link.href);
}

// AR Quick Look button for iOS
function createARButton(scene) {
  const button = document.createElement('a');
  button.rel = 'ar';
  button.href = 'model.usdz';

  // Add AR icon
  const icon = document.createElement('img');
  icon.src = 'ar-icon.png';
  icon.alt = 'View in AR';
  button.appendChild(icon);

  // Generate USDZ on click
  button.addEventListener('click', async (e) => {
    e.preventDefault();
    const exporter = new USDZExporter();
    const arraybuffer = await exporter.parse(scene);
    const blob = new Blob([arraybuffer], { type: 'model/vnd.usdz+zip' });
    button.href = URL.createObjectURL(blob);
    button.click();
  });

  return button;
}
```

## Performance Tips

1. **Use compressed formats**: DRACO for geometry, KTX2/Basis for textures
2. **Load progressively**: Show placeholders while loading
3. **Lazy load**: Only load what's needed
4. **Use CDN**: Faster asset delivery
5. **Enable cache**: `THREE.Cache.enabled = true`
6. **Preload critical assets**: Load during splash screen

```javascript
// Progressive loading with placeholder
const placeholder = new THREE.Mesh(
  new THREE.BoxGeometry(1, 1, 1),
  new THREE.MeshBasicMaterial({ wireframe: true })
);
scene.add(placeholder);

loadModel('model.glb').then((gltf) => {
  scene.remove(placeholder);
  scene.add(gltf.scene);
});
```
