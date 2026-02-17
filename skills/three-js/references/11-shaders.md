# Three.js Shaders

Custom GLSL shaders, uniforms, varyings, common patterns, and shader modification.

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
});

// Update in animation loop
material.uniforms.time.value = clock.getElapsedTime();
```

## Built-in Uniforms & Attributes

Three.js automatically provides these in ShaderMaterial:

```glsl
// Vertex Shader - Uniforms
uniform mat4 modelMatrix;         // Object to world
uniform mat4 modelViewMatrix;     // Object to camera
uniform mat4 projectionMatrix;    // Camera projection
uniform mat4 viewMatrix;          // World to camera
uniform mat3 normalMatrix;        // Transform normals
uniform vec3 cameraPosition;      // Camera world position

// Vertex Shader - Attributes
attribute vec3 position;          // Vertex position
attribute vec3 normal;            // Vertex normal
attribute vec2 uv;                // Texture coordinates
attribute vec2 uv2;               // Second UV channel
attribute vec3 color;             // Vertex color (if using)
attribute vec3 tangent;           // Tangent (if computed)
```

## RawShaderMaterial

Full control - no built-in uniforms/attributes.

```javascript
const material = new THREE.RawShaderMaterial({
  glslVersion: THREE.GLSL3,
  uniforms: {
    modelViewMatrix: { value: new THREE.Matrix4() },
    projectionMatrix: { value: camera.projectionMatrix },
  },
  vertexShader: `#version 300 es
    in vec3 position;
    uniform mat4 modelViewMatrix;
    uniform mat4 projectionMatrix;

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

## Shader Defines

Conditional compilation using preprocessor directives:

```javascript
const material = new THREE.ShaderMaterial({
  defines: {
    USE_FOG: true,
    MAX_LIGHTS: 4,
    QUALITY: 'high'
  },
  vertexShader: `
    #ifdef USE_FOG
      varying float vFogDepth;
    #endif

    void main() {
      // Process up to MAX_LIGHTS lights
      for (int i = 0; i < MAX_LIGHTS; i++) {
        // lighting calculations
      }

      gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
  `,
  fragmentShader: `
    #if QUALITY == 'high'
      // High quality code path
    #else
      // Low quality fallback
    #endif
  `
});

// Update defines (triggers shader recompilation)
material.defines.USE_FOG = false;
material.needsUpdate = true;
```

## Uniform Types

```javascript
const material = new THREE.ShaderMaterial({
  uniforms: {
    // Numbers
    time: { value: 0.0 },
    intensity: { value: 1.0 },

    // Vectors
    resolution: { value: new THREE.Vector2(1920, 1080) },
    lightPosition: { value: new THREE.Vector3(10, 10, 10) },
    color: { value: new THREE.Vector4(1, 0, 0, 1) },

    // Color (automatically converted to vec3)
    diffuseColor: { value: new THREE.Color(0xff0000) },

    // Matrices
    customMatrix: { value: new THREE.Matrix3() },
    worldMatrix: { value: new THREE.Matrix4() },

    // Textures
    diffuseMap: { value: texture },
    normalMap: { value: normalTexture },
    cubeMap: { value: cubeTexture },

    // Arrays
    positions: { value: [
      new THREE.Vector3(0, 0, 0),
      new THREE.Vector3(1, 1, 1),
    ]},
    floatArray: { value: [0.1, 0.2, 0.3, 0.4] },
  },
});
```

### GLSL Uniform Declarations

```glsl
uniform float time;
uniform vec2 resolution;
uniform vec3 lightPosition;
uniform vec4 color;
uniform mat3 normalMatrix;
uniform mat4 modelMatrix;
uniform sampler2D diffuseMap;
uniform samplerCube cubeMap;
uniform vec3 positions[2];
uniform float floatArray[4];
```

## Varyings

Pass data from vertex to fragment shader.

```glsl
// Vertex shader
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
varying vec3 vWorldPosition;

void main() {
  vUv = uv;
  vNormal = normalize(normalMatrix * normal);
  vPosition = position;
  vWorldPosition = (modelMatrix * vec4(position, 1.0)).xyz;

  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

// Fragment shader
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
varying vec3 vWorldPosition;

void main() {
  // Use varyings
  vec3 normal = normalize(vNormal);
  vec2 uv = vUv;
}
```

## Common Shader Patterns

### Gradient

```glsl
// Vertical gradient
void main() {
  vec3 color1 = vec3(1.0, 0.0, 0.0);
  vec3 color2 = vec3(0.0, 0.0, 1.0);
  vec3 color = mix(color1, color2, vUv.y);
  gl_FragColor = vec4(color, 1.0);
}
```

### Fresnel Effect

```glsl
varying vec3 vNormal;
varying vec3 vPosition;

void main() {
  vec3 viewDirection = normalize(cameraPosition - vPosition);
  float fresnel = 1.0 - dot(viewDirection, vNormal);
  fresnel = pow(fresnel, 3.0);

  vec3 baseColor = vec3(0.1, 0.1, 0.3);
  vec3 fresnelColor = vec3(0.5, 0.5, 1.0);
  vec3 color = mix(baseColor, fresnelColor, fresnel);

  gl_FragColor = vec4(color, 1.0);
}
```

### Noise Displacement

```glsl
// Vertex shader
uniform float time;
uniform float amplitude;

// Simple noise function
float noise(vec3 p) {
  return fract(sin(dot(p, vec3(12.9898, 78.233, 45.5432))) * 43758.5453);
}

void main() {
  vec3 pos = position;
  float n = noise(position + time * 0.5);
  pos += normal * n * amplitude;

  gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}
```

### Dissolve Effect

```glsl
uniform float progress;
uniform sampler2D noiseMap;

void main() {
  float noise = texture2D(noiseMap, vUv).r;

  if (noise < progress) {
    discard;
  }

  // Edge glow
  float edge = 1.0 - smoothstep(progress, progress + 0.1, noise);
  vec3 edgeColor = vec3(1.0, 0.5, 0.0);
  vec3 baseColor = texture2D(diffuseMap, vUv).rgb;

  vec3 color = mix(baseColor, edgeColor, edge);
  gl_FragColor = vec4(color, 1.0);
}
```

### Hologram

```glsl
uniform float time;
varying vec3 vNormal;
varying vec3 vPosition;

void main() {
  // Scanlines
  float scanline = sin(vPosition.y * 100.0 + time * 5.0) * 0.5 + 0.5;
  scanline = pow(scanline, 2.0) * 0.3 + 0.7;

  // Fresnel
  vec3 viewDir = normalize(cameraPosition - vPosition);
  float fresnel = 1.0 - abs(dot(viewDir, vNormal));
  fresnel = pow(fresnel, 2.0);

  // Flicker
  float flicker = sin(time * 20.0) * 0.02 + 0.98;

  vec3 color = vec3(0.0, 1.0, 0.8);
  float alpha = (fresnel + 0.2) * scanline * flicker;

  gl_FragColor = vec4(color, alpha);
}
```

### Toon/Cel Shading

```glsl
uniform vec3 lightDirection;
varying vec3 vNormal;

void main() {
  float intensity = dot(normalize(vNormal), normalize(lightDirection));

  vec3 color;
  if (intensity > 0.95) {
    color = vec3(1.0);
  } else if (intensity > 0.5) {
    color = vec3(0.7);
  } else if (intensity > 0.25) {
    color = vec3(0.4);
  } else {
    color = vec3(0.2);
  }

  gl_FragColor = vec4(color, 1.0);
}
```

### UV Animation

```glsl
uniform float time;
uniform sampler2D map;
varying vec2 vUv;

void main() {
  vec2 uv = vUv;

  // Scroll
  uv.x += time * 0.1;

  // Wave distortion
  uv.x += sin(uv.y * 10.0 + time) * 0.1;

  vec4 color = texture2D(map, uv);
  gl_FragColor = color;
}
```

## Instanced Shaders

```javascript
const geometry = new THREE.InstancedBufferGeometry();
geometry.copy(new THREE.BoxGeometry(1, 1, 1));

// Per-instance attribute
const offsets = new Float32Array(instanceCount * 3);
// ... fill offsets
geometry.setAttribute('offset', new THREE.InstancedBufferAttribute(offsets, 3));

const material = new THREE.ShaderMaterial({
  vertexShader: `
    attribute vec3 offset;

    void main() {
      vec3 pos = position + offset;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
    }
  `,
  fragmentShader: `
    void main() {
      gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
  `,
});
```

## Modify Built-in Materials

Use `onBeforeCompile` to inject custom code.

```javascript
const material = new THREE.MeshStandardMaterial({ color: 0x00ff00 });

material.onBeforeCompile = (shader) => {
  // Add custom uniforms
  shader.uniforms.time = { value: 0 };

  // Inject into vertex shader
  shader.vertexShader = shader.vertexShader.replace(
    '#include <begin_vertex>',
    `
    #include <begin_vertex>
    transformed.z += sin(transformed.x * 10.0 + time) * 0.1;
    `
  );

  // Store reference
  material.userData.shader = shader;
};

// Update in animation loop
function animate() {
  if (material.userData.shader) {
    material.userData.shader.uniforms.time.value = clock.getElapsedTime();
  }
}
```

### Common Injection Points

```glsl
// Vertex shader
#include <begin_vertex>         // After position is set to 'transformed'
#include <project_vertex>       // Before gl_Position
#include <worldpos_vertex>      // After world position calculation

// Fragment shader
#include <color_fragment>       // After diffuse color
#include <normal_fragment_maps> // After normal mapping
#include <output_fragment>      // Before final output
```

## GLSL Functions Reference

```glsl
// Math
float x = abs(a);
float x = sign(a);           // -1, 0, or 1
float x = floor(a);
float x = ceil(a);
float x = fract(a);          // Fractional part
float x = mod(a, b);         // Modulo
float x = min(a, b);
float x = max(a, b);
float x = clamp(a, min, max);
float x = mix(a, b, t);      // Lerp
float x = step(edge, x);     // 0 if x < edge, else 1
float x = smoothstep(e0, e1, x);  // Smooth 0-1 transition

// Trigonometry
float x = sin(a);
float x = cos(a);
float x = tan(a);
float x = asin(a);
float x = acos(a);
float x = atan(y, x);

// Exponential
float x = pow(base, exp);
float x = exp(a);
float x = log(a);
float x = sqrt(a);
float x = inversesqrt(a);

// Vector
float len = length(v);
float d = distance(a, b);
float d = dot(a, b);
vec3 c = cross(a, b);
vec3 n = normalize(v);
vec3 r = reflect(incident, normal);
vec3 r = refract(incident, normal, eta);
```

## Debugging Shaders

```javascript
// Check for shader errors
material.onBeforeCompile = (shader) => {
  console.log('Vertex shader:', shader.vertexShader);
  console.log('Fragment shader:', shader.fragmentShader);
};

// Visual debugging in shader
void main() {
  // Output UV as color
  gl_FragColor = vec4(vUv, 0.0, 1.0);

  // Output normal as color
  gl_FragColor = vec4(vNormal * 0.5 + 0.5, 1.0);

  // Output depth
  float depth = gl_FragCoord.z;
  gl_FragColor = vec4(vec3(depth), 1.0);

  // Output world position
  gl_FragColor = vec4(fract(vWorldPosition), 1.0);
}

// Enable shader error logging
renderer.debug.checkShaderErrors = true;
```

## External Shader Files

Organize shaders in separate files for better maintainability.

### Vite

```javascript
// Import as raw string
import vertexShader from './shaders/vertex.glsl?raw';
import fragmentShader from './shaders/fragment.glsl?raw';

const material = new THREE.ShaderMaterial({
  vertexShader,
  fragmentShader,
  uniforms: { /* ... */ },
});
```

### Webpack

```javascript
// webpack.config.js - add raw-loader
module.exports = {
  module: {
    rules: [
      {
        test: /\.(glsl|vert|frag)$/,
        type: 'asset/source',  // Webpack 5
        // or use: 'raw-loader' for Webpack 4
      },
    ],
  },
};

// Then import normally
import vertexShader from './shaders/vertex.vert';
import fragmentShader from './shaders/fragment.frag';
```

### File Organization

```
src/
├── shaders/
│   ├── common/
│   │   ├── noise.glsl       # Shared functions
│   │   └── lighting.glsl
│   ├── materials/
│   │   ├── water.vert
│   │   ├── water.frag
│   │   ├── fire.vert
│   │   └── fire.frag
│   └── postprocessing/
│       ├── blur.frag
│       └── vignette.frag
```

### GLSL Includes (Manual)

```javascript
// common/noise.glsl
const noiseGLSL = `
  float noise(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
  }
`;

// Combine shaders
import baseFragment from './base.frag?raw';

const fragmentShader = `
  ${noiseGLSL}
  ${baseFragment}
`;
```

### Runtime Loading (Fetch)

```javascript
async function loadShader(url) {
  const response = await fetch(url);
  return response.text();
}

async function createMaterial() {
  const [vertexShader, fragmentShader] = await Promise.all([
    loadShader('/shaders/vertex.glsl'),
    loadShader('/shaders/fragment.glsl'),
  ]);

  return new THREE.ShaderMaterial({
    vertexShader,
    fragmentShader,
    uniforms: { /* ... */ },
  });
}
```

### TypeScript Declarations

```typescript
// shaders.d.ts
declare module '*.glsl' {
  const value: string;
  export default value;
}

declare module '*.vert' {
  const value: string;
  export default value;
}

declare module '*.frag' {
  const value: string;
  export default value;
}
```

## Performance Tips

1. **Minimize uniforms**: Each uniform has overhead
2. **Use lowp/mediump**: When full precision not needed
3. **Avoid branching**: Use step/mix instead of if/else
4. **Precompute**: Move calculations from fragment to vertex shader
5. **Texture lookups**: Minimize in fragment shader

```glsl
// Precision qualifiers
precision highp float;    // Default
precision mediump float;  // Good for most cases
precision lowp float;     // Colors, normalized values

// Avoid branching
// Bad:
if (x > 0.5) {
  color = red;
} else {
  color = blue;
}

// Good:
color = mix(blue, red, step(0.5, x));
```
