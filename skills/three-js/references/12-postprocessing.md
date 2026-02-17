# Three.js Post-Processing

EffectComposer, bloom, DOF, SSAO, custom effects, and screen-space shaders.

## EffectComposer Setup

```javascript
import { EffectComposer } from 'three/addons/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/addons/postprocessing/RenderPass.js';

const composer = new EffectComposer(renderer);

// First pass: render scene
const renderPass = new RenderPass(scene, camera);
composer.addPass(renderPass);

// Add more passes...
composer.addPass(effectPass);

// Use composer instead of renderer
function animate() {
  requestAnimationFrame(animate);
  composer.render();  // NOT renderer.render()
}

// Handle resize
function onResize() {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
  composer.setSize(window.innerWidth, window.innerHeight);
}
```

## Bloom (Glow)

```javascript
import { UnrealBloomPass } from 'three/addons/postprocessing/UnrealBloomPass.js';

const bloomPass = new UnrealBloomPass(
  new THREE.Vector2(window.innerWidth, window.innerHeight),
  1.5,   // strength - intensity of glow
  0.4,   // radius - spread of glow
  0.85   // threshold - brightness threshold
);

composer.addPass(bloomPass);

// Adjust at runtime
bloomPass.strength = 2.0;
bloomPass.threshold = 0.5;
bloomPass.radius = 0.8;
```

### Selective Bloom

Apply bloom only to specific objects.

```javascript
import { UnrealBloomPass } from 'three/addons/postprocessing/UnrealBloomPass.js';
import { ShaderPass } from 'three/addons/postprocessing/ShaderPass.js';

// Layer setup
const BLOOM_LAYER = 1;
const bloomLayer = new THREE.Layers();
bloomLayer.set(BLOOM_LAYER);

// Mark objects to bloom
glowingMesh.layers.enable(BLOOM_LAYER);

// Materials storage
const darkMaterial = new THREE.MeshBasicMaterial({ color: 0x000000 });
const materials = {};

function darkenNonBloomed(obj) {
  if (obj.isMesh && !bloomLayer.test(obj.layers)) {
    materials[obj.uuid] = obj.material;
    obj.material = darkMaterial;
  }
}

function restoreMaterial(obj) {
  if (materials[obj.uuid]) {
    obj.material = materials[obj.uuid];
    delete materials[obj.uuid];
  }
}

// Render bloom layer
const bloomComposer = new EffectComposer(renderer);
bloomComposer.renderToScreen = false;
bloomComposer.addPass(new RenderPass(scene, camera));
bloomComposer.addPass(bloomPass);

// Final composite shader
const finalShader = {
  uniforms: {
    baseTexture: { value: null },
    bloomTexture: { value: bloomComposer.renderTarget2.texture }
  },
  vertexShader: `
    varying vec2 vUv;
    void main() {
      vUv = uv;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
  `,
  fragmentShader: `
    uniform sampler2D baseTexture;
    uniform sampler2D bloomTexture;
    varying vec2 vUv;
    void main() {
      gl_FragColor = texture2D(baseTexture, vUv) + texture2D(bloomTexture, vUv);
    }
  `
};

const finalComposer = new EffectComposer(renderer);
finalComposer.addPass(new RenderPass(scene, camera));
const finalPass = new ShaderPass(finalShader, 'baseTexture');
finalComposer.addPass(finalPass);

function render() {
  // Render bloom
  scene.traverse(darkenNonBloomed);
  bloomComposer.render();
  scene.traverse(restoreMaterial);

  // Render final
  finalComposer.render();
}
```

## Anti-Aliasing

### FXAA

```javascript
import { ShaderPass } from 'three/addons/postprocessing/ShaderPass.js';
import { FXAAShader } from 'three/addons/shaders/FXAAShader.js';

const fxaaPass = new ShaderPass(FXAAShader);
fxaaPass.material.uniforms['resolution'].value.set(
  1 / window.innerWidth,
  1 / window.innerHeight
);
composer.addPass(fxaaPass);

// Update on resize
function onResize() {
  fxaaPass.material.uniforms['resolution'].value.set(
    1 / window.innerWidth,
    1 / window.innerHeight
  );
}
```

### SMAA (Better Quality)

```javascript
import { SMAAPass } from 'three/addons/postprocessing/SMAAPass.js';

const smaaPass = new SMAAPass(
  window.innerWidth * renderer.getPixelRatio(),
  window.innerHeight * renderer.getPixelRatio()
);
composer.addPass(smaaPass);
```

## SSAO (Ambient Occlusion)

```javascript
import { SSAOPass } from 'three/addons/postprocessing/SSAOPass.js';

const ssaoPass = new SSAOPass(scene, camera, window.innerWidth, window.innerHeight);
ssaoPass.kernelRadius = 16;
ssaoPass.minDistance = 0.005;
ssaoPass.maxDistance = 0.1;
composer.addPass(ssaoPass);

// Output modes
ssaoPass.output = SSAOPass.OUTPUT.Default;  // Final composited
// SSAOPass.OUTPUT.SSAO - Just the AO
// SSAOPass.OUTPUT.Blur - Blurred AO
// SSAOPass.OUTPUT.Depth - Depth buffer
// SSAOPass.OUTPUT.Normal - Normal buffer
```

## Depth of Field

### BokehPass

```javascript
import { BokehPass } from 'three/addons/postprocessing/BokehPass.js';

const bokehPass = new BokehPass(scene, camera, {
  focus: 10.0,      // Focus distance
  aperture: 0.025,  // Smaller = more DOF
  maxblur: 0.01,    // Max blur amount
});
composer.addPass(bokehPass);

// Update focus dynamically
function updateFocus(distance) {
  bokehPass.uniforms['focus'].value = distance;
}
```

## Film Effects

### Film Grain

```javascript
import { FilmPass } from 'three/addons/postprocessing/FilmPass.js';

const filmPass = new FilmPass(
  0.5,    // noise intensity (0-1)
  false   // grayscale
);
composer.addPass(filmPass);

// Adjust at runtime
filmPass.uniforms.intensity.value = 0.35;
filmPass.uniforms.grayscale.value = true;
```

> **Note**: Scanlines were removed from FilmPass. Use a custom shader for scanline effects.

### Glitch

```javascript
import { GlitchPass } from 'three/addons/postprocessing/GlitchPass.js';

const glitchPass = new GlitchPass();
glitchPass.goWild = false;  // Continuous glitching
composer.addPass(glitchPass);
```

## Color Effects

### Vignette

```javascript
import { ShaderPass } from 'three/addons/postprocessing/ShaderPass.js';
import { VignetteShader } from 'three/addons/shaders/VignetteShader.js';

const vignettePass = new ShaderPass(VignetteShader);
vignettePass.uniforms['offset'].value = 1.0;    // Vignette size
vignettePass.uniforms['darkness'].value = 1.0;  // Intensity
composer.addPass(vignettePass);
```

### Color Correction

```javascript
import { ShaderPass } from 'three/addons/postprocessing/ShaderPass.js';
import { ColorCorrectionShader } from 'three/addons/shaders/ColorCorrectionShader.js';

const colorPass = new ShaderPass(ColorCorrectionShader);
colorPass.uniforms['powRGB'].value = new THREE.Vector3(1.2, 1.2, 1.2);
colorPass.uniforms['mulRGB'].value = new THREE.Vector3(1.0, 1.0, 1.0);
composer.addPass(colorPass);
```

### Gamma Correction

```javascript
import { GammaCorrectionShader } from 'three/addons/shaders/GammaCorrectionShader.js';

const gammaPass = new ShaderPass(GammaCorrectionShader);
composer.addPass(gammaPass);
```

### Sepia

```javascript
import { SepiaShader } from 'three/addons/shaders/SepiaShader.js';

const sepiaPass = new ShaderPass(SepiaShader);
sepiaPass.uniforms['amount'].value = 0.9;
composer.addPass(sepiaPass);
```

## Stylized Effects

### Pixelation

```javascript
import { RenderPixelatedPass } from 'three/addons/postprocessing/RenderPixelatedPass.js';

const pixelPass = new RenderPixelatedPass(6, scene, camera);  // 6 = pixel size
composer.addPass(pixelPass);
```

### Halftone

```javascript
import { HalftonePass } from 'three/addons/postprocessing/HalftonePass.js';

const halftonePass = new HalftonePass(window.innerWidth, window.innerHeight, {
  shape: 1,              // 1 = dot, 2 = ellipse, 3 = line, 4 = square
  radius: 4,             // Dot size
  rotateR: Math.PI / 12,
  rotateB: Math.PI / 12 * 2,
  rotateG: Math.PI / 12 * 3,
  scatter: 0,
  blending: 1,
  blendingMode: 1,
  greyscale: false,
});
composer.addPass(halftonePass);
```

### Outline

```javascript
import { OutlinePass } from 'three/addons/postprocessing/OutlinePass.js';

const outlinePass = new OutlinePass(
  new THREE.Vector2(window.innerWidth, window.innerHeight),
  scene,
  camera
);

outlinePass.edgeStrength = 3;
outlinePass.edgeGlow = 0;
outlinePass.edgeThickness = 1;
outlinePass.pulsePeriod = 0;
outlinePass.visibleEdgeColor.set(0xffffff);
outlinePass.hiddenEdgeColor.set(0x190a05);

// Select objects to outline
outlinePass.selectedObjects = [mesh1, mesh2];

composer.addPass(outlinePass);
```

## Custom ShaderPass

```javascript
import { ShaderPass } from 'three/addons/postprocessing/ShaderPass.js';

const CustomShader = {
  uniforms: {
    tDiffuse: { value: null },  // Required: input texture
    time: { value: 0 },
    intensity: { value: 1.0 },
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
    uniform float time;
    uniform float intensity;
    varying vec2 vUv;

    void main() {
      vec2 uv = vUv;
      uv.x += sin(uv.y * 10.0 + time) * 0.01 * intensity;
      vec4 color = texture2D(tDiffuse, uv);
      gl_FragColor = color;
    }
  `,
};

const customPass = new ShaderPass(CustomShader);
composer.addPass(customPass);

// Update
customPass.uniforms.time.value = clock.getElapsedTime();
```

### Common Custom Effects

```javascript
// Invert colors
const InvertShader = {
  uniforms: { tDiffuse: { value: null } },
  vertexShader: `
    varying vec2 vUv;
    void main() {
      vUv = uv;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
  `,
  fragmentShader: `
    uniform sampler2D tDiffuse;
    varying vec2 vUv;
    void main() {
      vec4 color = texture2D(tDiffuse, vUv);
      gl_FragColor = vec4(1.0 - color.rgb, color.a);
    }
  `,
};

// Chromatic aberration
const ChromaticAberrationShader = {
  uniforms: {
    tDiffuse: { value: null },
    amount: { value: 0.005 },
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
    uniform float amount;
    varying vec2 vUv;

    void main() {
      vec2 dir = vUv - 0.5;
      float dist = length(dir);

      float r = texture2D(tDiffuse, vUv - dir * amount * dist).r;
      float g = texture2D(tDiffuse, vUv).g;
      float b = texture2D(tDiffuse, vUv + dir * amount * dist).b;

      gl_FragColor = vec4(r, g, b, 1.0);
    }
  `,
};

// Grayscale
const GrayscaleShader = {
  uniforms: { tDiffuse: { value: null } },
  fragmentShader: `
    uniform sampler2D tDiffuse;
    varying vec2 vUv;
    void main() {
      vec4 color = texture2D(tDiffuse, vUv);
      float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
      gl_FragColor = vec4(vec3(gray), color.a);
    }
  `,
};
```

## OutputPass (Required)

OutputPass applies tone mapping and color space conversion. **Required at end of pass chain.**

```javascript
import { OutputPass } from 'three/addons/postprocessing/OutputPass.js';

const composer = new EffectComposer(renderer);
composer.addPass(new RenderPass(scene, camera));
composer.addPass(bloomPass);
composer.addPass(new OutputPass());  // REQUIRED - applies tone mapping
```

> **Important**: Effects requiring sRGB input (like FXAA) must come **after** OutputPass.

## Combining Effects

```javascript
import { OutputPass } from 'three/addons/postprocessing/OutputPass.js';

// Order matters!
const composer = new EffectComposer(renderer);

// 1. Render scene
composer.addPass(new RenderPass(scene, camera));

// 2. SSAO (needs depth/normals)
composer.addPass(ssaoPass);

// 3. Bloom
composer.addPass(bloomPass);

// 4. Color grading
composer.addPass(colorPass);

// 5. Vignette
composer.addPass(vignettePass);

// 6. OutputPass (tone mapping + color space)
composer.addPass(new OutputPass());

// 7. Anti-aliasing (after OutputPass - needs sRGB)
composer.addPass(fxaaPass);
```

## Multi-Pass Rendering

```javascript
// Background composer
const bgComposer = new EffectComposer(renderer);
bgComposer.addPass(new RenderPass(bgScene, camera));

// Foreground composer
const fgComposer = new EffectComposer(renderer);
fgComposer.addPass(new RenderPass(fgScene, camera));
fgComposer.addPass(bloomPass);

// Combine
function animate() {
  renderer.autoClear = false;
  renderer.clear();

  bgComposer.render();
  renderer.clearDepth();
  fgComposer.render();

  renderer.autoClear = true;
}
```

## WebGPU Post-Processing

```javascript
import { pass, bloom, renderOutput, mrt, output } from 'three/tsl';

// PostProcessing is available on THREE in WebGPU builds
const postProcessing = new THREE.PostProcessing(renderer);

// Node-based system
const scenePass = pass(scene, camera);
const scenePassColor = scenePass.getTextureNode();

// Apply effects
let result = scenePassColor;
result = bloom(result, 0.5, 0.4, 0.85);

postProcessing.outputNode = result;

// Render
function animate() {
  postProcessing.render();
}
```

### Manual Tone Mapping Control

For effects requiring sRGB input (like FXAA):

```javascript
import { pass, renderOutput } from 'three/tsl';
import { fxaa } from 'three/addons/tsl/display/FXAANode.js';

const postProcessing = new THREE.PostProcessing(renderer);
postProcessing.outputColorTransform = false;  // Disable automatic conversion

const scenePass = pass(scene, camera);
const outputPass = renderOutput(scenePass);  // Manual tone mapping

// FXAA must be computed in sRGB color space
const fxaaPass = fxaa(outputPass);
postProcessing.outputNode = fxaaPass;
```

### Multi-Render-Target (MRT) for Deferred

```javascript
import { pass, mrt, output, normalView } from 'three/tsl';

const scenePass = pass(scene, camera);
scenePass.setMRT(mrt({
  output: output,
  normal: normalView
}));

const colorTexture = scenePass.getTextureNode();
const normalTexture = scenePass.getTextureNode('normal');
```

## Performance Tips

1. **Limit passes**: Each pass = full-screen render
2. **Lower resolution**: Use smaller render targets for blur
3. **Disable unused effects**: `pass.enabled = false`
4. **Use FXAA over MSAA**: Less expensive
5. **Mobile considerations**: Reduce effect complexity

```javascript
// Disable pass
bloomPass.enabled = false;

// Reduce bloom resolution
const bloomPass = new UnrealBloomPass(
  new THREE.Vector2(window.innerWidth / 2, window.innerHeight / 2),
  strength, radius, threshold
);

// Mobile detection
const isMobile = /iPhone|iPad|Android/i.test(navigator.userAgent);
if (isMobile) {
  // Use simpler effects
  bloomPass.strength = 0.5;
  ssaoPass.enabled = false;
}
```
