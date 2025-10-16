# Trilogy: Technical Plan & Architecture

## Vision & Scope
- Build a vertical-climbing platformer starring Milo, a nimble wizard, inspired by Donkey Kong but with dynamic construction cranes and beams.
- Deliver a modern Catppuccin palette blended with Ghibli-inspired shapes and animation.
- Start with polished single-player experience; architect code paths to support optional online/local multiplayer later without rewrites.

## Target Platforms & Technology
- Engine: Godot 4.5 (LTS) using GDScript for gameplay logic, with optional GDNative for future performance critical modules.
- Platforms: macOS, Windows, Linux desktop exports; Android and iOS mobile builds via Godot export presets.
- Source layout (proposed):
  ```
  trilogy-game/
    project.godot
    src/
      actors/
        Milo/
          Milo.tscn
          Milo.gd
          MiloStateMachine.gd
      props/
        Cranes/
          Crane.tscn
          Crane.gd
          Beam.tscn
          Beam.gd
        Hazards/
      systems/
        GameDirector.gd
        LevelLoader.gd
        InputService.gd
        SaveService.gd
      ui/
        Hud.tscn
        PauseMenu.tscn
      levels/
        Level01.tscn
        Level02.tscn
    autoload/
      GameDirector.tscn
      AudioBus.tscn
    data/
      level_configs/
      localization/
    art/
    audio/
    tests/
  ```

## Production Milestones & Timeline Constraints
- Alpha (12 weeks): vertical slice with Milo core moves, crane/beam system, 3 handcrafted levels, placeholder art/audio.
- Beta (additional 12 weeks): expanded hazards, polished VFX/SFX, Catppuccin palette finalized, usability QA on desktop + mobile.
- Launch (additional 8 weeks): platform certification, marketing beats, multiplayer prototype branching.
- Optional Agile execution: 2-week sprints, each targeting a feature (movement, cranes, hazards, boss encounter); sprint reviews drive backlog reprioritization.
- Gate reviews at Concept (week 0), Prototype (week 4), Alpha (week 12), Beta (week 24), Release Candidate (week 32) to assess scope vs. resources.

## Core Gameplay Loop & Systems
- Player (`Milo.gd`):
  - Uses `CharacterBody2D` with custom state machine (`Idle`, `Run`, `Jump`, `BeamHang`, `BeamRide`, `Fall`, `Stunned`).
  - Jump buffering and coyote time to ensure responsive controls; beam snapping logic aligns Milo to moving beams using raycasts and lerp.
  - Wizard flare: chargeable upward dash (optional) gated behind collectable power-ups.
- Crane & Beam System:
  - `Crane` node animated via Tween or AnimationPlayer controlling swing/translation; child `Beam` nodes inherit motion but support oscillation for dynamic challenge.
  - `ConstructionSection` scenes combine static tiles, ladders, and anchor points for cranes to plug into modularly.
  - Event signals (`BeamOccupied`, `BeamVacated`) inform difficulty scaling and hazard triggers.
- Hazards & Collectables:
  - Rolling debris, falling sparks, time-limited platforms.
  - `Pickups` grant score, temporary invulnerability, or dash charges.
- GameDirector (autoload):
  - Owns session state, score, difficulty curve, and cross-level progression.
  - Manages spawn tables for hazards based on player altitude and elapsed time.
  - Hooks for future multiplayer sync (network-ready signal bus, replication wrappers).
- LevelLoader:
  - Parses `LevelConfig` resources defining crane routes, hazard spawn points, ambient cues.
  - Supports streaming sub-scenes to keep memory low on mobile.
- UI:
  - `Hud` shows score, altitude, lives, upcoming hazard warnings.
  - `Menu` scenes share base `ScreenController.gd` with animation transitions.

## Content Pipeline & Tools
- Level authoring: compose modular `ConstructionSection` scenes in Godot editor; optional Tiled import pipeline if designers prefer tilemaps.
- Palette management: central `palette.gd` singleton storing Catppuccin color constants to keep art consistent.
- Animation workflow: Milo hand-drawn frames via Aseprite or Blender Grease Pencil, exported as spritesheets; use Godot's `AnimatedSprite2D` with frame tags.
- Audio direction: layered ambient crews, crane creaks, whimsical spell FX; store in `audio/` with `.ogg` for loops and `.wav` for SFX.
- Version control: Git with Git LFS for large binary assets; branch model using `main` plus feature branches; enforce PR templates referencing milestone goals.

## Build, Tooling & Automation
- Godot export presets configured for desktop and mobile; integrate with GitHub Actions to produce nightly builds for macOS (.dmg), Windows (.exe), Linux (.AppImage), Android (.aab), iOS (Xcode project).
- Automated linting via `godot --headless --check-only`.
- Unit and integration tests using GUT (Godot Unit Test) to cover Milo movement, crane timing, and GameDirector state transitions.
- Use continuous delivery pipeline to push alpha builds to TestFlight and Google Play Internal Testing.

## Multiplayer Roadmap
- Abstract player input through `InputService` allowing local, AI, or network drivers.
- Reserve deterministic hooks in GameDirector (clock sync, random seeds).
- Evaluate Godot Multiplayer API or custom rollback using ENet; start with cooperative spectator and score-race modes.
- Keep serialization contracts (`SaveService`, replay data) network-ready.

## Risks & Mitigations
- Mobile performance: profile early; enforce draw-call budgets, use 2D batching, limit shader complexity.
- Motion sickness from moving beams: add camera damping options and accessibility toggles for reduced motion.
- Scope creep: use milestone gates to re-evaluate stretch goals (boss fights, multiplayer).
- Art pipeline load: reuse modular props, invest in shader-driven lighting to reduce hand-painted frames.

## Immediate Next Steps
- Initialize Godot 4.3 project under `trilogy-game/` with agreed directory structure.
- Prototype Milo movement and beam interaction in a graybox level.
- Define `LevelConfig` Resource schema and implement loader.
- Set up GitHub Actions skeleton for automated exports and GUT test runs.
