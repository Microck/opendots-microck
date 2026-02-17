# Three.js Lighting

Light types, shadows, IBL, light probes, and common lighting setups.

## Light Types Overview

| Light | Description | Shadow Support | Cost |
|-------|-------------|----------------|------|
| AmbientLight | Uniform everywhere | No | Very Low |
| HemisphereLight | Sky/ground gradient | No | Very Low |
| DirectionalLight | Parallel rays (sun) | Yes | Low |
| PointLight | Omnidirectional (bulb) | Yes | Medium |
| SpotLight | Cone-shaped | Yes | Medium |
| RectAreaLight | Area light (window) | No* | High |

*RectAreaLight shadows require custom solutions

## AmbientLight

Illuminates all objects equally. No direction, no shadows.

```javascript
// AmbientLight(color, intensity)
const ambient = new THREE.AmbientLight(0xffffff, 0.5);
scene.add(ambient);

// Modify at runtime
ambient.color.set(0xffffcc);
ambient.intensity = 0.3;
```

## HemisphereLight

Gradient from sky to ground color. Great for outdoor scenes.

```javascript
// HemisphereLight(skyColor, groundColor, intensity)
const hemi = new THREE.HemisphereLight(0x87ceeb, 0x8b4513, 0.6);
hemi.position.set(0, 50, 0);
scene.add(hemi);

// Properties
hemi.color;        // Sky color
hemi.groundColor;  // Ground color
hemi.intensity;
```

## DirectionalLight

Parallel light rays. Simulates distant light source (sun).

```javascript
// DirectionalLight(color, intensity)
const dirLight = new THREE.DirectionalLight(0xffffff, 1);
dirLight.position.set(5, 10, 5);

// Target (light points at this - default: 0,0,0)
dirLight.target.position.set(0, 0, 0);
scene.add(dirLight.target);

scene.add(dirLight);
```

### DirectionalLight Shadows

```javascript
dirLight.castShadow = true;

// Shadow map size (higher = sharper, more expensive)
dirLight.shadow.mapSize.width = 2048;
dirLight.shadow.mapSize.height = 2048;

// Shadow camera (orthographic)
dirLight.shadow.camera.near = 0.5;
dirLight.shadow.camera.far = 50;
dirLight.shadow.camera.left = -10;
dirLight.shadow.camera.right = 10;
dirLight.shadow.camera.top = 10;
dirLight.shadow.camera.bottom = -10;

// Shadow softness (PCFSoftShadowMap only)
dirLight.shadow.radius = 4;

// Shadow bias (fixes shadow acne)
dirLight.shadow.bias = -0.0001;
dirLight.shadow.normalBias = 0.02;

// Helper to visualize shadow camera
const helper = new THREE.CameraHelper(dirLight.shadow.camera);
scene.add(helper);
```

## PointLight

Emits light in all directions from a point. Like a light bulb.

```javascript
// PointLight(color, intensity, distance, decay)
const pointLight = new THREE.PointLight(0xffffff, 1, 100, 2);
pointLight.position.set(0, 5, 0);
scene.add(pointLight);

// Properties
pointLight.distance;  // Maximum range (0 = infinite)
pointLight.decay;     // Light falloff (physically correct = 2)
```

### PointLight Shadows

```javascript
pointLight.castShadow = true;
pointLight.shadow.mapSize.width = 1024;
pointLight.shadow.mapSize.height = 1024;

// Shadow camera (perspective - 6 directions for cube map)
pointLight.shadow.camera.near = 0.5;
pointLight.shadow.camera.far = 50;

pointLight.shadow.bias = -0.005;
```

## SpotLight

Cone-shaped light. Like a flashlight or stage light.

```javascript
// SpotLight(color, intensity, distance, angle, penumbra, decay)
const spotLight = new THREE.SpotLight(
  0xffffff,    // color
  1,           // intensity
  100,         // distance (0 = infinite)
  Math.PI / 6, // angle (cone half-angle)
  0.5,         // penumbra (soft edge 0-1)
  2            // decay
);
spotLight.position.set(0, 10, 0);

// Target
spotLight.target.position.set(0, 0, 0);
scene.add(spotLight.target);

scene.add(spotLight);
```

### SpotLight Shadows

```javascript
spotLight.castShadow = true;
spotLight.shadow.mapSize.width = 1024;
spotLight.shadow.mapSize.height = 1024;

// Shadow camera (perspective)
spotLight.shadow.camera.near = 0.5;
spotLight.shadow.camera.far = 50;
spotLight.shadow.camera.fov = 30;

spotLight.shadow.bias = -0.0001;
spotLight.shadow.focus = 1;  // Affects shadow projection
```

## RectAreaLight

Rectangular area light. Great for soft, realistic lighting.

```javascript
import { RectAreaLightHelper } from 'three/addons/helpers/RectAreaLightHelper.js';
import { RectAreaLightUniformsLib } from 'three/addons/lights/RectAreaLightUniformsLib.js';

// Must initialize uniforms first!
RectAreaLightUniformsLib.init();

// RectAreaLight(color, intensity, width, height)
const rectLight = new THREE.RectAreaLight(0xffffff, 5, 4, 2);
rectLight.position.set(0, 5, 0);
rectLight.lookAt(0, 0, 0);
scene.add(rectLight);

// Helper
const helper = new RectAreaLightHelper(rectLight);
rectLight.add(helper);

// Note: Only works with MeshStandardMaterial and MeshPhysicalMaterial
// Does not cast shadows natively
```

## Shadow Setup

### Enable Shadows

```javascript
// 1. Enable on renderer
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;

// Shadow map types:
// THREE.BasicShadowMap - Fastest, low quality
// THREE.PCFShadowMap - Default, filtered
// THREE.PCFSoftShadowMap - Softer edges
// THREE.VSMShadowMap - Variance shadow map

// 2. Enable on light
light.castShadow = true;

// 3. Enable on objects
mesh.castShadow = true;
mesh.receiveShadow = true;

// Ground plane
floor.receiveShadow = true;
floor.castShadow = false;  // Usually false for floors
```

### Optimizing Shadows

```javascript
// Tight shadow camera frustum
const d = 10;
dirLight.shadow.camera.left = -d;
dirLight.shadow.camera.right = d;
dirLight.shadow.camera.top = d;
dirLight.shadow.camera.bottom = -d;
dirLight.shadow.camera.near = 0.5;
dirLight.shadow.camera.far = 30;

// Fix shadow acne
dirLight.shadow.bias = -0.0001;     // Depth bias
dirLight.shadow.normalBias = 0.02;  // Bias along normal

// Shadow map size guidelines:
// 512 - Low quality (fast)
// 1024 - Medium quality
// 2048 - High quality
// 4096 - Very high (expensive)
```

### Contact Shadows

Fake shadows that appear where objects meet surfaces. Fast alternative to real-time shadows.

#### Simple Blob Shadow

```javascript
// Pre-made shadow texture
const shadowGeometry = new THREE.PlaneGeometry(2, 2);
const shadowMaterial = new THREE.MeshBasicMaterial({
  map: shadowTexture,
  transparent: true,
  opacity: 0.5,
  depthWrite: false,
});
const shadow = new THREE.Mesh(shadowGeometry, shadowMaterial);
shadow.rotation.x = -Math.PI / 2;
shadow.position.y = 0.01;  // Slightly above ground
scene.add(shadow);

// Follow object
function animate() {
  shadow.position.x = object.position.x;
  shadow.position.z = object.position.z;
  // Scale based on height
  const scale = Math.max(0.5, 2 - object.position.y * 0.2);
  shadow.scale.setScalar(scale);
}
```

#### Render-Target Contact Shadows

High-quality contact shadows using render-to-texture.

```javascript
class ContactShadow {
  constructor(options = {}) {
    const {
      width = 10,
      height = 10,
      resolution = 512,
      blur = 2,
      opacity = 0.5,
      darkness = 1,
    } = options;

    // Shadow render target
    this.renderTarget = new THREE.WebGLRenderTarget(resolution, resolution);

    // Camera looking down at ground plane
    this.shadowCamera = new THREE.OrthographicCamera(
      -width / 2, width / 2,
      height / 2, -height / 2,
      0, 20
    );
    this.shadowCamera.rotation.x = Math.PI;  // Look down

    // Depth material for shadow capture
    this.depthMaterial = new THREE.MeshDepthMaterial({
      depthPacking: THREE.BasicDepthPacking,
    });

    // Blur material
    this.blurMaterial = new THREE.ShaderMaterial({
      uniforms: {
        tDiffuse: { value: null },
        resolution: { value: new THREE.Vector2(resolution, resolution) },
        blur: { value: blur },
      },
      vertexShader: `
        varying vec2 vUv;
        void main() {
          vUv = uv;
          gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
        }
      `,
      fragmentShader: `
        uniform sampler2D tDiffuse;
        uniform vec2 resolution;
        uniform float blur;
        varying vec2 vUv;

        void main() {
          vec4 sum = vec4(0.0);
          float blurSize = blur / resolution.x;

          for (float x = -4.0; x <= 4.0; x++) {
            for (float y = -4.0; y <= 4.0; y++) {
              vec2 offset = vec2(x, y) * blurSize;
              sum += texture2D(tDiffuse, vUv + offset);
            }
          }

          gl_FragColor = sum / 81.0;
        }
      `,
    });

    // Shadow plane
    this.plane = new THREE.Mesh(
      new THREE.PlaneGeometry(width, height),
      new THREE.MeshBasicMaterial({
        map: this.renderTarget.texture,
        transparent: true,
        opacity: opacity,
        depthWrite: false,
      })
    );
    this.plane.rotation.x = -Math.PI / 2;
    this.plane.position.y = 0.001;

    this.darkness = darkness;
  }

  update(renderer, scene, excludeList = []) {
    // Store original materials
    const originalMaterials = new Map();
    scene.traverse((obj) => {
      if (obj.isMesh && !excludeList.includes(obj)) {
        originalMaterials.set(obj, obj.material);
        obj.material = this.depthMaterial;
      }
    });

    // Render depth
    renderer.setRenderTarget(this.renderTarget);
    renderer.render(scene, this.shadowCamera);

    // Restore materials
    originalMaterials.forEach((material, obj) => {
      obj.material = material;
    });

    renderer.setRenderTarget(null);
  }
}

// Usage
const contactShadow = new ContactShadow({
  width: 10,
  height: 10,
  resolution: 512,
  blur: 2,
  opacity: 0.4,
});
scene.add(contactShadow.plane);

function animate() {
  contactShadow.update(renderer, scene, [groundPlane]);
  renderer.render(scene, camera);
}
```

#### React Three Fiber / Drei ContactShadows

```jsx
// If using React Three Fiber
import { ContactShadows } from '@react-three/drei';

function Scene() {
  return (
    <>
      <ContactShadows
        position={[0, 0, 0]}
        opacity={0.5}
        scale={10}
        blur={2}
        far={4}
        resolution={256}
        color="#000000"
        frames={1}  // 1 = render once, Infinity = every frame
      />
      <mesh>
        <boxGeometry />
        <meshStandardMaterial />
      </mesh>
    </>
  );
}
```

## Light Helpers

```javascript
import { RectAreaLightHelper } from 'three/addons/helpers/RectAreaLightHelper.js';

// DirectionalLight helper
const dirHelper = new THREE.DirectionalLightHelper(dirLight, 5);
scene.add(dirHelper);

// PointLight helper
const pointHelper = new THREE.PointLightHelper(pointLight, 1);
scene.add(pointHelper);

// SpotLight helper
const spotHelper = new THREE.SpotLightHelper(spotLight);
scene.add(spotHelper);

// Hemisphere helper
const hemiHelper = new THREE.HemisphereLightHelper(hemiLight, 5);
scene.add(hemiHelper);

// RectAreaLight helper
const rectHelper = new RectAreaLightHelper(rectLight);
rectLight.add(rectHelper);

// Update helpers when light changes
dirHelper.update();
spotHelper.update();
```

## Environment Lighting (IBL)

Image-Based Lighting using HDR environment maps.

```javascript
import { RGBELoader } from 'three/addons/loaders/RGBELoader.js';

const rgbeLoader = new RGBELoader();
rgbeLoader.load('environment.hdr', (texture) => {
  texture.mapping = THREE.EquirectangularReflectionMapping;

  // Set as scene environment (affects all PBR materials)
  scene.environment = texture;

  // Optional: also use as background
  scene.background = texture;
  scene.backgroundBlurriness = 0;   // 0-1
  scene.backgroundIntensity = 1;
});
```

### PMREMGenerator for Better Reflections

```javascript
const pmremGenerator = new THREE.PMREMGenerator(renderer);
pmremGenerator.compileEquirectangularShader();

rgbeLoader.load('environment.hdr', (texture) => {
  const envMap = pmremGenerator.fromEquirectangular(texture).texture;
  scene.environment = envMap;
  texture.dispose();
  pmremGenerator.dispose();
});
```

### Cube Texture Environment

```javascript
const cubeLoader = new THREE.CubeTextureLoader();
const envMap = cubeLoader.load([
  'px.jpg', 'nx.jpg',
  'py.jpg', 'ny.jpg',
  'pz.jpg', 'nz.jpg',
]);

scene.environment = envMap;
scene.background = envMap;
```

## Light Probes

Capture lighting from a point in space for ambient lighting.

```javascript
import { LightProbeGenerator } from 'three/addons/lights/LightProbeGenerator.js';

// Generate from cube texture
const lightProbe = new THREE.LightProbe();
scene.add(lightProbe);

lightProbe.copy(LightProbeGenerator.fromCubeTexture(cubeTexture));

// Or from cube camera render
const cubeCamera = new THREE.CubeCamera(0.1, 100, new THREE.WebGLCubeRenderTarget(256));
cubeCamera.update(renderer, scene);
lightProbe.copy(LightProbeGenerator.fromCubeRenderTarget(renderer, cubeCamera.renderTarget));
```

## Common Lighting Setups

### Three-Point Lighting

```javascript
// Key light (main light)
const keyLight = new THREE.DirectionalLight(0xffffff, 1);
keyLight.position.set(5, 5, 5);
keyLight.castShadow = true;
scene.add(keyLight);

// Fill light (softer, opposite side)
const fillLight = new THREE.DirectionalLight(0xffffff, 0.5);
fillLight.position.set(-5, 3, 5);
scene.add(fillLight);

// Back light (rim lighting)
const backLight = new THREE.DirectionalLight(0xffffff, 0.3);
backLight.position.set(0, 5, -5);
scene.add(backLight);

// Ambient fill
const ambient = new THREE.AmbientLight(0x404040, 0.3);
scene.add(ambient);
```

### Outdoor Daylight

```javascript
// Sun
const sun = new THREE.DirectionalLight(0xffffcc, 1.5);
sun.position.set(50, 100, 50);
sun.castShadow = true;
sun.shadow.mapSize.set(2048, 2048);
sun.shadow.camera.near = 10;
sun.shadow.camera.far = 200;
sun.shadow.camera.left = -50;
sun.shadow.camera.right = 50;
sun.shadow.camera.top = 50;
sun.shadow.camera.bottom = -50;
scene.add(sun);

// Sky ambient
const hemi = new THREE.HemisphereLight(0x87ceeb, 0x8b4513, 0.6);
scene.add(hemi);
```

### Indoor Studio

```javascript
RectAreaLightUniformsLib.init();

// Multiple area lights
const light1 = new THREE.RectAreaLight(0xffffff, 5, 2, 2);
light1.position.set(3, 3, 3);
light1.lookAt(0, 0, 0);
scene.add(light1);

const light2 = new THREE.RectAreaLight(0xffffff, 3, 2, 2);
light2.position.set(-3, 3, 3);
light2.lookAt(0, 0, 0);
scene.add(light2);

// Ambient fill
const ambient = new THREE.AmbientLight(0x404040, 0.2);
scene.add(ambient);
```

### Night Scene

```javascript
// Moonlight
const moonLight = new THREE.DirectionalLight(0x4466ff, 0.3);
moonLight.position.set(10, 20, -10);
scene.add(moonLight);

// Point lights (street lamps)
const lampLight = new THREE.PointLight(0xffaa44, 1, 15, 2);
lampLight.position.set(0, 3, 0);
lampLight.castShadow = true;
scene.add(lampLight);

// Dark ambient
const ambient = new THREE.AmbientLight(0x111122, 0.3);
scene.add(ambient);
```

## Light Animation

```javascript
const clock = new THREE.Clock();

function animate() {
  const time = clock.getElapsedTime();

  // Orbit light around scene
  light.position.x = Math.cos(time) * 5;
  light.position.z = Math.sin(time) * 5;

  // Pulsing intensity
  light.intensity = 1 + Math.sin(time * 2) * 0.5;

  // Color cycling
  light.color.setHSL((time * 0.1) % 1, 1, 0.5);

  // Update helpers if using
  lightHelper.update();
}
```

## Light Layers

```javascript
// Light only affects objects on specific layers
light.layers.set(1);            // Light only affects layer 1
mesh.layers.enable(1);          // Mesh is on layer 1
otherMesh.layers.disable(1);    // Other mesh not affected by this light

// Camera must also see the layer
camera.layers.enable(1);
```

## Performance Tips

1. **Limit light count**: Each light adds shader complexity
2. **Use baked lighting**: For static scenes, bake to lightmaps
3. **Smaller shadow maps**: 512-1024 often sufficient
4. **Tight shadow frustums**: Only cover needed area
5. **Disable unused shadows**: Not all lights need shadows
6. **Use light layers**: Exclude objects from certain lights

```javascript
// Selective shadows
mesh.castShadow = true;
mesh.receiveShadow = true;
smallDecorMesh.castShadow = false;   // Small objects often don't need to cast

// Check light count
console.log('Lights:', scene.children.filter(c => c.isLight).length);
```
