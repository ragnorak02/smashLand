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

### Core Scripts
| File | Purpose |
|------|---------|
| `scripts/fighter_base.gd` | State machine, movement, combat, shield, grab, visuals, signals |
| `scripts/arena.gd` | Stage construction, fighter spawning, camera/HUD setup, match flow |
| `scripts/dynamic_camera.gd` | Tracks fighters, smooth zoom interpolation |
| `scripts/character_select.gd` | Two-player fighter selection UI |
| `scripts/combat/attack_data.gd` | Static attack dictionaries for Brawler/Speedster (`class_name AttackData`) |
| `scripts/combat/hitbox.gd` | Dynamically spawned hitbox Area2D with attack metadata |
| `scripts/combat_hud.gd` | Damage percentage + stock icons display (CanvasLayer) |
| `scripts/input_debug_hud.gd` | Real-time input/combat state overlay |
| `scripts/main.gd` | Entry point — immediately loads CharacterSelect |

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

## Current Repo State (Auto-Detected)

- Phase 1 (Foundation) complete: movement, camera, character select, arena flow
- Phase 2 (Combat) complete: attacks, damage/knockback, hitstun/hitlag, shield, grab, stocks, combat HUD, match flow
- No test framework or test files present
- No art/audio assets — all visuals are ColorRect-based programmer art + `_draw()` overlays
- No fonts, themes, or .tres resource files
- Only 2 fighter types exist (Brawler, Speedster) — selected via integer toggle
- GameManager stores selections, stock count, and last winner
- Full attack/shield/grab triangle implemented (attack beats grab, shield beats attack, grab beats shield)
- Stock-based win condition with winner overlay → return to character select
- No main menu — Main.tscn immediately redirects to CharacterSelect
- No settings, pause menu, or audio

## Git Workflow
See [git_workflow.md](git_workflow.md) for checkpoint commit process and safety rules.

## Key Rules for AI Assistants
1. **Read before editing** — always read files before proposing changes
2. **Programmatic UI** — never add complex node trees in .tscn files; build UI in GDScript
3. **No feature creep** — only implement what is explicitly requested
4. **Preserve conventions** — use `p1_`/`p2_` prefix pattern, bottom-aligned collisions, ColorRect visuals
5. **Secret safety** — never commit .env, keys, or credentials; see git_workflow.md
