# Three.js Advanced Patterns

Architecture patterns, asset management, state management, cleanup, and best practices.

## Application Architecture

### Scene Manager

```javascript
class SceneManager {
  constructor(renderer) {
    this.renderer = renderer;
    this.scenes = new Map();
    this.currentScene = null;
  }

  addScene(name, scene, camera) {
    this.scenes.set(name, { scene, camera });
  }

  switchScene(name) {
    if (this.currentScene) {
      this.onSceneExit(this.currentScene);
    }

    this.currentScene = this.scenes.get(name);

    if (this.currentScene) {
      this.onSceneEnter(this.currentScene);
    }
  }

  onSceneEnter({ scene, camera }) {
    // Initialize scene
  }

  onSceneExit({ scene, camera }) {
    // Cleanup if needed
  }

  update(delta) {
    if (this.currentScene) {
      // Update current scene
    }
  }

  render() {
    if (this.currentScene) {
      const { scene, camera } = this.currentScene;
      this.renderer.render(scene, camera);
    }
  }
}
```

### Game Loop

```javascript
class GameLoop {
  constructor() {
    this.isRunning = false;
    this.lastTime = 0;
    this.accumulator = 0;
    this.fixedTimeStep = 1 / 60;  // 60 Hz physics
    this.maxFrameTime = 0.25;      // Prevent spiral of death

    this.updateCallbacks = [];
    this.fixedUpdateCallbacks = [];
    this.renderCallbacks = [];
  }

  start() {
    this.isRunning = true;
    this.lastTime = performance.now();
    this.loop();
  }

  stop() {
    this.isRunning = false;
  }

  loop = () => {
    if (!this.isRunning) return;

    const currentTime = performance.now();
    let frameTime = (currentTime - this.lastTime) / 1000;
    this.lastTime = currentTime;

    // Clamp frame time
    if (frameTime > this.maxFrameTime) {
      frameTime = this.maxFrameTime;
    }

    this.accumulator += frameTime;

    // Fixed timestep updates (physics)
    while (this.accumulator >= this.fixedTimeStep) {
      this.fixedUpdateCallbacks.forEach(cb => cb(this.fixedTimeStep));
      this.accumulator -= this.fixedTimeStep;
    }

    // Variable timestep updates
    const alpha = this.accumulator / this.fixedTimeStep;
    this.updateCallbacks.forEach(cb => cb(frameTime, alpha));

    // Render
    this.renderCallbacks.forEach(cb => cb());

    requestAnimationFrame(this.loop);
  };

  onUpdate(callback) {
    this.updateCallbacks.push(callback);
  }

  onFixedUpdate(callback) {
    this.fixedUpdateCallbacks.push(callback);
  }

  onRender(callback) {
    this.renderCallbacks.push(callback);
  }
}

// Usage
const gameLoop = new GameLoop();

gameLoop.onFixedUpdate((dt) => {
  physics.step(dt);
});

gameLoop.onUpdate((dt, alpha) => {
  // Interpolate visual positions
  objects.forEach(obj => {
    obj.mesh.position.lerpVectors(obj.previousPos, obj.currentPos, alpha);
  });
});

gameLoop.onRender(() => {
  renderer.render(scene, camera);
});

gameLoop.start();
```

### Entity Component System (ECS)

```javascript
// Component definitions
class TransformComponent {
  constructor() {
    this.position = new THREE.Vector3();
    this.rotation = new THREE.Euler();
    this.scale = new THREE.Vector3(1, 1, 1);
  }
}

class MeshComponent {
  constructor(mesh) {
    this.mesh = mesh;
  }
}

class VelocityComponent {
  constructor() {
    this.velocity = new THREE.Vector3();
    this.angularVelocity = new THREE.Vector3();
  }
}

// Entity
class Entity {
  constructor() {
    this.id = THREE.MathUtils.generateUUID();
    this.components = new Map();
    this.tags = new Set();
  }

  addComponent(component) {
    this.components.set(component.constructor.name, component);
    return this;
  }

  getComponent(ComponentClass) {
    return this.components.get(ComponentClass.name);
  }

  hasComponent(ComponentClass) {
    return this.components.has(ComponentClass.name);
  }

  addTag(tag) {
    this.tags.add(tag);
    return this;
  }

  hasTag(tag) {
    return this.tags.has(tag);
  }
}

// System
class MovementSystem {
  update(entities, delta) {
    entities.forEach(entity => {
      if (entity.hasComponent(TransformComponent) && entity.hasComponent(VelocityComponent)) {
        const transform = entity.getComponent(TransformComponent);
        const velocity = entity.getComponent(VelocityComponent);

        transform.position.addScaledVector(velocity.velocity, delta);
      }
    });
  }
}

class RenderSystem {
  update(entities) {
    entities.forEach(entity => {
      if (entity.hasComponent(TransformComponent) && entity.hasComponent(MeshComponent)) {
        const transform = entity.getComponent(TransformComponent);
        const mesh = entity.getComponent(MeshComponent).mesh;

        mesh.position.copy(transform.position);
        mesh.rotation.copy(transform.rotation);
        mesh.scale.copy(transform.scale);
      }
    });
  }
}

// World
class World {
  constructor() {
    this.entities = new Map();
    this.systems = [];
  }

  addEntity(entity) {
    this.entities.set(entity.id, entity);
  }

  removeEntity(entity) {
    this.entities.delete(entity.id);
  }

  addSystem(system) {
    this.systems.push(system);
  }

  update(delta) {
    const entityArray = Array.from(this.entities.values());
    this.systems.forEach(system => system.update(entityArray, delta));
  }

  query(...ComponentClasses) {
    return Array.from(this.entities.values()).filter(entity =>
      ComponentClasses.every(C => entity.hasComponent(C))
    );
  }
}
```

## Asset Management

### Asset Loader

```javascript
class AssetLoader {
  constructor() {
    this.loadingManager = new THREE.LoadingManager();
    this.textureLoader = new THREE.TextureLoader(this.loadingManager);
    this.gltfLoader = new GLTFLoader(this.loadingManager);
    this.audioLoader = new THREE.AudioLoader(this.loadingManager);

    this.cache = new Map();
    this.loading = new Map();

    this.setupLoaders();
  }

  setupLoaders() {
    // Setup Draco for GLTF
    const dracoLoader = new DRACOLoader();
    dracoLoader.setDecoderPath('/draco/');
    this.gltfLoader.setDRACOLoader(dracoLoader);

    // Setup KTX2
    const ktx2Loader = new KTX2Loader();
    ktx2Loader.setTranscoderPath('/basis/');
    this.gltfLoader.setKTX2Loader(ktx2Loader);
  }

  async load(key, url, type = 'auto') {
    // Return cached
    if (this.cache.has(key)) {
      return this.cache.get(key);
    }

    // Return existing promise if loading
    if (this.loading.has(key)) {
      return this.loading.get(key);
    }

    // Determine type from extension
    if (type === 'auto') {
      const ext = url.split('.').pop().toLowerCase();
      const typeMap = {
        'gltf': 'gltf', 'glb': 'gltf',
        'png': 'texture', 'jpg': 'texture', 'jpeg': 'texture', 'webp': 'texture',
        'ktx2': 'texture',
        'mp3': 'audio', 'ogg': 'audio', 'wav': 'audio',
        'hdr': 'hdr', 'exr': 'exr'
      };
      type = typeMap[ext] || 'texture';
    }

    // Create loading promise
    const promise = this.loadAsset(url, type);
    this.loading.set(key, promise);

    try {
      const asset = await promise;
      this.cache.set(key, asset);
      this.loading.delete(key);
      return asset;
    } catch (error) {
      this.loading.delete(key);
      throw error;
    }
  }

  async loadAsset(url, type) {
    switch (type) {
      case 'texture':
        return new Promise((resolve, reject) => {
          this.textureLoader.load(url, resolve, undefined, reject);
        });

      case 'gltf':
        return new Promise((resolve, reject) => {
          this.gltfLoader.load(url, resolve, undefined, reject);
        });

      case 'audio':
        return new Promise((resolve, reject) => {
          this.audioLoader.load(url, resolve, undefined, reject);
        });

      case 'hdr':
        const rgbeLoader = new RGBELoader();
        return new Promise((resolve, reject) => {
          rgbeLoader.load(url, resolve, undefined, reject);
        });

      default:
        throw new Error(`Unknown asset type: ${type}`);
    }
  }

  get(key) {
    return this.cache.get(key);
  }

  dispose(key) {
    const asset = this.cache.get(key);
    if (asset) {
      if (asset.dispose) asset.dispose();
      if (asset.scene) disposeScene(asset.scene);
      this.cache.delete(key);
    }
  }

  disposeAll() {
    this.cache.forEach((asset, key) => this.dispose(key));
  }
}

// Usage
const assets = new AssetLoader();

async function loadLevel() {
  await Promise.all([
    assets.load('player', '/models/player.glb'),
    assets.load('diffuse', '/textures/diffuse.png'),
    assets.load('normal', '/textures/normal.png'),
    assets.load('bgm', '/audio/bgm.mp3')
  ]);

  const playerGltf = assets.get('player');
  const playerModel = playerGltf.scene.clone();
  scene.add(playerModel);
}
```

### Resource Preloading

```javascript
class PreloadManager {
  constructor(loadingManager) {
    this.loadingManager = loadingManager;
    this.manifests = new Map();
  }

  addManifest(name, urls) {
    this.manifests.set(name, urls);
  }

  async preload(manifestName, onProgress) {
    const urls = this.manifests.get(manifestName);
    if (!urls) throw new Error(`Unknown manifest: ${manifestName}`);

    let loaded = 0;
    const total = urls.length;

    const promises = urls.map(async ({ key, url, type }) => {
      await assets.load(key, url, type);
      loaded++;
      onProgress?.(loaded / total);
    });

    await Promise.all(promises);
  }
}

// Usage
const preloader = new PreloadManager();

preloader.addManifest('level1', [
  { key: 'terrain', url: '/models/terrain.glb' },
  { key: 'trees', url: '/models/trees.glb' },
  { key: 'grass', url: '/textures/grass.png' },
  { key: 'skybox', url: '/textures/skybox.hdr' }
]);

await preloader.preload('level1', (progress) => {
  loadingBar.style.width = `${progress * 100}%`;
});
```

## Memory Management

### Proper Disposal

```javascript
function disposeObject(object) {
  // Dispose geometry
  if (object.geometry) {
    object.geometry.dispose();
  }

  // Dispose material(s)
  if (object.material) {
    disposeMaterial(object.material);
  }

  // Dispose children
  if (object.children) {
    while (object.children.length > 0) {
      disposeObject(object.children[0]);
      object.remove(object.children[0]);
    }
  }
}

function disposeMaterial(material) {
  if (Array.isArray(material)) {
    material.forEach(disposeMaterial);
    return;
  }

  material.dispose();

  // Dispose all textures
  const textureProperties = [
    'map', 'lightMap', 'bumpMap', 'normalMap',
    'displacementMap', 'specularMap', 'envMap',
    'alphaMap', 'aoMap', 'emissiveMap',
    'gradientMap', 'metalnessMap', 'roughnessMap',
    'clearcoatMap', 'clearcoatNormalMap', 'clearcoatRoughnessMap',
    'transmissionMap', 'thicknessMap', 'sheenColorMap', 'sheenRoughnessMap'
  ];

  textureProperties.forEach(prop => {
    if (material[prop]) {
      material[prop].dispose();
    }
  });
}

function disposeScene(scene) {
  scene.traverse(disposeObject);
}

function disposeRenderer(renderer) {
  renderer.dispose();
  renderer.forceContextLoss();
  renderer.domElement = null;
}
```

### Memory Monitoring

```javascript
class MemoryMonitor {
  constructor(renderer) {
    this.renderer = renderer;
    this.history = [];
    this.maxHistory = 100;
  }

  sample() {
    const info = this.renderer.info;
    const sample = {
      timestamp: Date.now(),
      geometries: info.memory.geometries,
      textures: info.memory.textures,
      programs: info.programs?.length || 0,
      drawCalls: info.render.calls,
      triangles: info.render.triangles
    };

    this.history.push(sample);
    if (this.history.length > this.maxHistory) {
      this.history.shift();
    }

    return sample;
  }

  detectLeak() {
    if (this.history.length < 10) return false;

    const recent = this.history.slice(-10);
    const firstGeometries = recent[0].geometries;
    const lastGeometries = recent[recent.length - 1].geometries;

    // Simple leak detection: steady increase
    return lastGeometries > firstGeometries + 10;
  }

  report() {
    const current = this.sample();
    console.table({
      'Geometries': current.geometries,
      'Textures': current.textures,
      'Shader Programs': current.programs,
      'Draw Calls': current.drawCalls,
      'Triangles': current.triangles.toLocaleString()
    });
  }
}
```

## State Management

### Observable State

```javascript
class Observable {
  constructor(initialValue) {
    this._value = initialValue;
    this._listeners = new Set();
  }

  get value() {
    return this._value;
  }

  set value(newValue) {
    const oldValue = this._value;
    this._value = newValue;
    this._listeners.forEach(listener => listener(newValue, oldValue));
  }

  subscribe(listener) {
    this._listeners.add(listener);
    return () => this._listeners.delete(listener);
  }
}

// Usage
const playerHealth = new Observable(100);

playerHealth.subscribe((newHealth, oldHealth) => {
  healthBar.style.width = `${newHealth}%`;

  if (newHealth <= 0) {
    gameOver();
  }
});

// Update
playerHealth.value -= 10;
```

### State Machine

```javascript
class StateMachine {
  constructor(initialState) {
    this.currentState = initialState;
    this.states = new Map();
    this.transitions = new Map();
  }

  addState(name, { enter, update, exit }) {
    this.states.set(name, { enter, update, exit });
  }

  addTransition(from, to, condition) {
    const key = `${from}->${to}`;
    this.transitions.set(key, { from, to, condition });
  }

  setState(name) {
    const currentStateObj = this.states.get(this.currentState);
    const newStateObj = this.states.get(name);

    if (currentStateObj?.exit) {
      currentStateObj.exit();
    }

    this.currentState = name;

    if (newStateObj?.enter) {
      newStateObj.enter();
    }
  }

  update(delta) {
    // Check transitions
    this.transitions.forEach(({ from, to, condition }) => {
      if (this.currentState === from && condition()) {
        this.setState(to);
      }
    });

    // Update current state
    const stateObj = this.states.get(this.currentState);
    if (stateObj?.update) {
      stateObj.update(delta);
    }
  }
}

// Usage
const playerState = new StateMachine('idle');

playerState.addState('idle', {
  enter: () => mixer.clipAction(idleClip).play(),
  exit: () => mixer.clipAction(idleClip).stop()
});

playerState.addState('walking', {
  enter: () => mixer.clipAction(walkClip).play(),
  update: (delta) => movePlayer(delta),
  exit: () => mixer.clipAction(walkClip).stop()
});

playerState.addState('jumping', {
  enter: () => {
    mixer.clipAction(jumpClip).play();
    velocity.y = jumpForce;
  },
  update: (delta) => {
    velocity.y -= gravity * delta;
    player.position.y += velocity.y * delta;
  },
  exit: () => mixer.clipAction(jumpClip).stop()
});

playerState.addTransition('idle', 'walking', () => isMoving);
playerState.addTransition('walking', 'idle', () => !isMoving);
playerState.addTransition('idle', 'jumping', () => jumpPressed && isGrounded);
playerState.addTransition('walking', 'jumping', () => jumpPressed && isGrounded);
playerState.addTransition('jumping', 'idle', () => isGrounded && !isMoving);
playerState.addTransition('jumping', 'walking', () => isGrounded && isMoving);
```

## Event System

```javascript
class EventEmitter {
  constructor() {
    this.events = new Map();
  }

  on(event, callback) {
    if (!this.events.has(event)) {
      this.events.set(event, new Set());
    }
    this.events.get(event).add(callback);
    return () => this.off(event, callback);
  }

  once(event, callback) {
    const wrapper = (...args) => {
      this.off(event, wrapper);
      callback(...args);
    };
    this.on(event, wrapper);
  }

  off(event, callback) {
    if (this.events.has(event)) {
      this.events.get(event).delete(callback);
    }
  }

  emit(event, ...args) {
    if (this.events.has(event)) {
      this.events.get(event).forEach(callback => callback(...args));
    }
  }

  clear(event) {
    if (event) {
      this.events.delete(event);
    } else {
      this.events.clear();
    }
  }
}

// Global event bus
const events = new EventEmitter();

// Usage
events.on('enemy:killed', (enemy) => {
  score += enemy.points;
  spawnPickup(enemy.position);
});

events.on('player:damaged', (damage) => {
  playerHealth.value -= damage;
  shakeCamera();
  playSound('hit');
});

// Emit
events.emit('enemy:killed', enemy);
events.emit('player:damaged', 10);
```

## Debug Utilities

### Debug Panel

```javascript
class DebugPanel {
  constructor() {
    this.panel = document.createElement('div');
    this.panel.style.cssText = `
      position: fixed;
      top: 10px;
      left: 10px;
      background: rgba(0,0,0,0.7);
      color: white;
      padding: 10px;
      font-family: monospace;
      font-size: 12px;
      z-index: 9999;
    `;
    document.body.appendChild(this.panel);

    this.values = new Map();
  }

  set(key, value) {
    this.values.set(key, value);
    this.render();
  }

  render() {
    // Clear existing content safely
    while (this.panel.firstChild) {
      this.panel.removeChild(this.panel.firstChild);
    }

    // Build content using safe DOM methods
    this.values.forEach((value, key) => {
      const line = document.createElement('div');
      const displayValue = typeof value === 'number' ? value.toFixed(2) : String(value);
      line.textContent = `${key}: ${displayValue}`;
      this.panel.appendChild(line);
    });
  }

  dispose() {
    this.panel.remove();
  }
}

// Usage
const debug = new DebugPanel();

function animate() {
  debug.set('FPS', 1 / delta);
  debug.set('Objects', scene.children.length);
  debug.set('Draw Calls', renderer.info.render.calls);
  debug.set('Triangles', renderer.info.render.triangles);
}
```

### Scene Inspector

```javascript
function inspectScene(scene) {
  const hierarchy = [];

  function traverse(object, depth = 0) {
    const info = {
      name: object.name || object.type,
      type: object.type,
      visible: object.visible,
      position: object.position.toArray().map(n => n.toFixed(2)).join(', '),
      children: object.children.length
    };

    hierarchy.push({ depth, info });

    object.children.forEach(child => traverse(child, depth + 1));
  }

  traverse(scene);

  console.log('Scene Hierarchy:');
  hierarchy.forEach(({ depth, info }) => {
    const indent = '  '.repeat(depth);
    console.log(`${indent}${info.name} (${info.type}) [${info.visible ? 'visible' : 'hidden'}]`);
  });
}
```

## Best Practices

### 1. Use Groups for Organization

```javascript
const environment = new THREE.Group();
environment.name = 'environment';
scene.add(environment);

const characters = new THREE.Group();
characters.name = 'characters';
scene.add(characters);

const effects = new THREE.Group();
effects.name = 'effects';
scene.add(effects);

// Add objects to appropriate groups
environment.add(terrain, trees, buildings);
characters.add(player, enemies);
effects.add(particles, projectiles);
```

### 2. Clone vs Instance

```javascript
// Clone: separate geometry and material copies
const clone = original.clone();
clone.material = original.material.clone();  // If needed

// Instance: share geometry and material
const instance = new THREE.Mesh(
  original.geometry,  // Shared
  original.material   // Shared
);

// InstancedMesh: best for many identical objects
const instanced = new THREE.InstancedMesh(geometry, material, count);
```

### 3. Lazy Initialization

```javascript
class Enemy {
  constructor() {
    this._mesh = null;
  }

  get mesh() {
    if (!this._mesh) {
      this._mesh = this.createMesh();
    }
    return this._mesh;
  }

  createMesh() {
    // Expensive operation
    return new THREE.Mesh(geometry, material);
  }
}
```

### 4. Update Optimization

```javascript
// Bad: update everything every frame
function animate() {
  scene.traverse(obj => obj.update());
}

// Good: update only what needs updating
function animate() {
  activeObjects.forEach(obj => obj.update());
}

// Better: spatial partitioning for large scenes
function animate() {
  const nearbyObjects = spatialHash.query(player.position, updateRadius);
  nearbyObjects.forEach(obj => obj.update());
}
```

### 5. Consistent Coordinate System

```javascript
// Define scale convention
const UNIT = 1;  // 1 unit = 1 meter

// Use consistently
const playerHeight = 1.8 * UNIT;
const roomWidth = 10 * UNIT;
const bulletSpeed = 50 * UNIT;  // 50 m/s

// Import scale correction for external models
gltfLoader.load('model.glb', (gltf) => {
  gltf.scene.scale.multiplyScalar(UNIT / 100);  // If model is in cm
});
```

### 6. Error Handling

```javascript
async function loadModel(url) {
  try {
    const gltf = await new Promise((resolve, reject) => {
      gltfLoader.load(url, resolve, undefined, reject);
    });
    return gltf.scene;
  } catch (error) {
    console.error(`Failed to load model: ${url}`, error);
    // Return placeholder
    return new THREE.Mesh(
      new THREE.BoxGeometry(1, 1, 1),
      new THREE.MeshBasicMaterial({ color: 0xff0000 })
    );
  }
}
```

### 7. Frame Rate Independence

```javascript
// Bad: fixed step
object.position.x += 1;

// Good: delta time
object.position.x += speed * delta;

// Better: fixed timestep for physics
accumulator += delta;
while (accumulator >= fixedDelta) {
  physics.step(fixedDelta);
  accumulator -= fixedDelta;
}
```
