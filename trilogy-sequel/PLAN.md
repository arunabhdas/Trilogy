# Trilogy Sequel (Kotlin) – Technical Plan & Architecture

## Vision & Scope
- Reimagine Trilogy using Kotlin atop the LibGDX engine (with KTX extensions) to target desktop, mobile, and web (via LibGDX's HTML backend).
- Preserve the original gameplay pillars: Milo’s vertical ascent through construction towers with moving cranes/beams, hazards, wizard abilities (double jump, dash, time slow), collectibles, and Catppuccin-inspired visuals.
- Establish a modular architecture that cleanly separates engine-specific layers from game logic, enabling future ports or engine changes with minimal churn.

## Technology Stack
- **Engine:** LibGDX 1.12 (latest stable) with Kotlin + KTX utilities for idiomatic coroutines, dependency injection, and scene2d builders.
- **Rendering:** LibGDX 2D with SpriteBatch + custom shaders for lighting; use Box2D for physics-lite collision or custom AABB depending on prototyping results.
- **Build System:** Gradle Kotlin DSL multi-project (core, desktop, android, ios, html).
- **Dependency Injection & Config:** Koin for runtime services (Audio, Input, Savedata).
- **UI:** VisUI (LibGDX) skinned to match Catppuccin palette.

## Repository Layout
```
trilogy-sequel-kotlin/
  build.gradle.kts
  settings.gradle.kts
  core/
    src/main/kotlin/
      trilogy/
        App.kt
        GameConfig.kt
        assets/
        di/
          ServiceLocator.kt
        ecs/
          components/
          systems/
          events/
        gameplay/
          MiloController.kt
          Abilities.kt
          HazardManager.kt
          LevelDirector.kt
          CheckpointSystem.kt
        rendering/
          SpriteSystem.kt
          ParticleSystem.kt
        ui/
          HudScreen.kt
          MenuScreen.kt
        util/
          Extensions.kt
    src/main/resources/
      atlases/
      shaders/
      audio/
      localization/
  desktop/
    src/main/kotlin/DesktopLauncher.kt
  android/
    src/
  ios/
    src/
  html/
    src/
  tools/
    level-editor/
      ... (Kotlin CLI for level data validation)
  docs/
    art-bible.md
    gameplay-metrics.md
```

## Core Systems Design
### 1. Game Bootstrapping
- `App.kt` initializes LibGDX application and Koin modules, loads persistent config (`GameConfig`), and routes to `MainMenuScreen`.
- Service modules: `AssetService`, `AudioService`, `InputService`, `SaveService`, `LevelRepository`.

### 2. ECS & Scene Graph Hybrid
- Use Ashley ECS (LibGDX) + Kotlin wrappers for gameplay objects.
- Components: `Transform`, `Velocity`, `Collision`, `PlayerTag`, `Hazard`, `Collectible`, `AbilityCooldown`, `BeamFollower`, `Checkpoint`.
- Systems: `MovementSystem`, `BeamSyncSystem`, `CollisionSystem`, `AbilitySystem`, `TimeSlowSystem`, `AnimationSystem`, `HudSyncSystem`.

### 3. Player & Abilities
- Milo implemented as an entity with:
  - State machine (`Idle`, `Run`, `Jump`, `DoubleJump`, `Dash`, `WallSlide`, `TimeSlow`).
  - Ability services track cooldowns, UI integration, audio cues.
  - Input mapping via `InputService` for gamepad/keyboard/touch with action rebinding.

### 4. Environment & Levels
- Level data defined via Kotlin data classes or JSON, parsed into `LevelDefinition` with segments, crane paths, hazard spawn curves.
- Use spline-based interpolation for crane movement; beam `BeamFollower` component handles snapping logic.
- Checkpoints instantiate `Checkpoint` entities wired to `CheckpointSystem` to update respawn positions + HUD messaging.

### 5. Hazards & Enemies
- Each hazard type is a prefab component bundle (e.g., `PendulumHazardFactory`, `FallingDebrisFactory`).
- Systems handle behaviour: `PendulumSystem` uses sine wave, `FallingPlatformSystem` listens for player contact events, `ProjectileSystem` for ranged enemies.
- Shared `DamageSystem` resolves collisions vs. Milo, applying invulnerability windows.

### 6. UI & HUD
- Screens: `MainMenuScreen`, `TowerSelectScreen`, `GameplayScreen`, `PauseScreen`, `ResultsScreen`.
- HUD: ability cooldown bars, hearts (with Catppuccin palette), altitude gauge, timer, instructions overlay.
- Localization pipeline using LibGDX I18N bundles.

### 7. Audio & Feedback
- Audio bus mixing via `AudioService` (LibGDX Music/Sound API) with channel grouping.
- Implement dynamic music layers per tower state (quiet vs. hazard intensity).
- Screen shake and particle feedback triggered through `FeedbackEvents` processed by `EffectsSystem`.

### 8. Save/Progression
- `SaveService` serializes JSON to platform storage; tracks tower progress, ability upgrades, cosmetics, settings.
- Achievement system built atop event bus (`GameplayEventDispatcher`).

## Tooling & Pipeline
- **Asset pipeline:** Use Gradle tasks to pack textures via TexturePacker, convert audio to OGG/MP3, compile shaders.
- **Level authoring:** Tiled (.tmx) or LDtk exported to JSON -> converted by `LevelConverter.kt` to game-ready format.
- **Continuous Integration:** GitHub Actions to run `./gradlew check test`, package desktop jar, and produce Android APK + HTML distribution using TeaVM backend.
- **Testing:**
  - Unit tests with JUnit5 + MockK for services.
  - Gameplay tests using gdx-ai FSM simulations (headless).
  - Snapshot tests for layout/hud using Screenshotter library.

## Implementation Roadmap
1. **Foundation (Weeks 1-3)**
   - Configure Gradle multi-platform project, integrate KTX, Koin, Ashley.
   - Implement `App.kt`, service locator, asset loading scaffolding.
   - Build stub `GameplayScreen` rendering graybox tiles.

2. **Core Mechanics MVP (Weeks 4-8)**
   - Milo movement state machine, double jump, dash, wall slide with Box2D collisions.
   - Beam/crane system prototype; pendulum hazard and collapsing scaffold.
   - HUD overlay with health, timer, instructions.
   - Checkpoint + respawn flow.

3. **Content & Systems Expansion (Weeks 9-14)**
   - Implement all hazard types + enemies per tower spec.
   - Ability upgrades + ability cooldown UI.
   - Level streaming for tower segments; integrate LevelRepository and Tiled importer.
   - Audio layering, camera polish, particle effects.

4. **Polish & Platform Support (Weeks 15-20)**
   - Add localization, settings, save system.
   - Performance tuning for mobile & HTML (sprite atlases, pooling, shader optimization).
   - Automated builds for desktop/Android/iOS/HTML.
   - QA pass, input remapping, accessibility (reduced motion toggle).

## Risk Mitigation
- **Physics Consistency:** Decide early between Box2D vs custom to avoid integration churn; prototype both in Foundation phase.
- **Performance:** Establish profiling on mobile early; leverage pooling, sprite batching, and limit dynamic lights.
- **Complexity of ECS:** Document entity lifecycle and provide helper builders to avoid misuse.
- **HTML Backend Limitations:** Keep shader usage fallback-ready; run HTML build in CI to catch issues.

## Deliverables Checklist
- Gradle project with working LibGDX/Kotlin bootstrap.
- Implemented towers with all mechanics mirrored from Godot version.
- Production-ready HUD, menus, and save progression.
- Automated export pipeline (desktop/mobile/web).
- Documentation: setup guide, control schemes, asset guidelines, code architecture overview.
