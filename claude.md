# SmashLand — Project Intelligence

## Project Overview
- **Engine**: Godot 4.6 (GL Compatibility renderer)
- **Type**: 2D platform fighter (Super Smash Bros.-inspired)
- **Resolution**: 1280x720, `canvas_items` stretch mode, `expand` aspect
- **Language**: GDScript only — all UI/visuals built programmatically (no complex .tscn trees)

## Architecture

### Scene Flow
```
Main.tscn → CharacterSelect.tscn → Arena.tscn
```

### Autoloads (load order)
1. `InputSetup` — `scripts/autoload/input_setup.gd` — registers all input actions at startup
2. `GameManager` — `scripts/autoload/game_manager.gd` — stores selections, handles scene changes

### Core Scripts (11 GDScript + 2 test scripts)
| File | Purpose |
|------|---------|
| `scripts/fighter_base.gd` | 11-state machine, movement, combat, shield, grab, visuals, signals |
| `scripts/arena.gd` | Stage construction, fighter spawning, camera/HUD setup, match flow |
| `scripts/dynamic_camera.gd` | Tracks fighters, smooth zoom interpolation |
| `scripts/character_select.gd` | Two-player fighter selection UI |
| `scripts/combat/attack_data.gd` | Static attack dictionaries for Brawler/Speedster (`class_name AttackData`) |
| `scripts/combat/hitbox.gd` | Dynamically spawned hitbox Area2D with attack metadata |
| `scripts/combat_hud.gd` | Damage percentage + stock icons display (CanvasLayer) |
| `scripts/input_debug_hud.gd` | Real-time input/combat state overlay |
| `scripts/main.gd` | Entry point — immediately loads CharacterSelect |
| `tests/run-tests.gd` | Headless test runner (32 tests, 9 suites) |

### Fighter Types
| Type | ID | Color | Size | Speed | Jumps | Notes |
|------|----|-------|------|-------|-------|-------|
| Brawler | 0 | Blue (0.2, 0.4, 0.9) | 44x68 | 380 | 3 | Stronger jump force |
| Speedster | 1 | Red (0.9, 0.2, 0.2) | 36x60 | 500 | 4 | Faster, more air jumps |

### Conventions
- Input actions prefixed: `p1_`, `p2_` (move_left, move_right, move_up, move_down, jump, select, attack, shield, grab)
- Kill zones: Y > 700, |X| > 1200
- Platform origin at (0,0), fighters spawn at (-200,-100) and (200,-100)
- Fighter collision bottom-aligned — feet at CharacterBody2D `position.y`
- P1: WASD + Space + Q/E/R (attack/shield/grab) | P2: Arrows + Enter + RShift/RCtrl/KP0 + Xbox controller
- Collision layers: 1=World, 2=P1 Hurtbox, 3=P2 Hurtbox, 4=P1 Hitbox, 5=P2 Hitbox
- Fighter states: IDLE, RUN, AIR, ATTACK, HITSTUN, SHIELD, SHIELD_STUN, SHIELD_BREAK, GRAB, GRAB_HOLD, GRABBED
- Knockback formula: `(base_kb + (percent * kb_scaling / 10)) * (200 / (weight + 100))`
- Stocks: 3 per fighter, match ends when one reaches 0

## Current Repo State

- **Phase 1 (Foundation)** — complete: movement, camera, character select, arena flow
- **Phase 2 (Combat)** — complete: 7 attacks per fighter, damage/knockback, hitstun/hitlag, shield (drain/regen/break), grab (pummel + 4 throws + mash-out), combat HUD
- **Phase 3 (Game Flow)** — partially complete: stocks (3 per fighter), win condition with winner overlay → return to character select, invulnerability on respawn. **Not started:** match timer, results screen, main menu, pause menu
- **Test suite**: 32 headless tests across 9 suites (`tests/run-tests.gd`), CI wrappers (`run-tests.bat`, `run-tests.sh`)
- **Studio OS integration**: `game.config.json` with launcher metadata, test command, build v0.2.1
- No art/audio assets — all visuals are ColorRect-based programmer art + `_draw()` overlays
- No fonts, themes, or .tres resource files
- Only 2 fighter types exist (Brawler, Speedster) — selected via integer toggle
- GameManager stores selections, stock count, and last winner
- Full attack/shield/grab triangle implemented (attack beats grab, shield beats attack, grab beats shield)
- 4 scenes: Main.tscn, CharacterSelect.tscn, Arena.tscn, FighterBase.tscn

## Git Workflow
See [git_workflow.md](git_workflow.md) for checkpoint commit process and safety rules.

## Key Rules for AI Assistants
1. **Read before editing** — always read files before proposing changes
2. **Programmatic UI** — never add complex node trees in .tscn files; build UI in GDScript
3. **No feature creep** — only implement what is explicitly requested
4. **Preserve conventions** — use `p1_`/`p2_` prefix pattern, bottom-aligned collisions, ColorRect visuals
5. **Secret safety** — never commit .env, keys, or credentials; see git_workflow.md
