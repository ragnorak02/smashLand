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
| `scripts/fighter_base.gd` | Movement, multi-jump, gravity, fast fall, respawn, visual build |
| `scripts/arena.gd` | Stage construction, fighter spawning, camera/HUD setup |
| `scripts/dynamic_camera.gd` | Tracks fighters, smooth zoom interpolation |
| `scripts/character_select.gd` | Two-player fighter selection UI |
| `scripts/input_debug_hud.gd` | Real-time input state overlay |
| `scripts/main.gd` | Entry point — immediately loads CharacterSelect |

### Fighter Types
| Type | ID | Color | Size | Speed | Jumps | Notes |
|------|----|-------|------|-------|-------|-------|
| Brawler | 0 | Blue (0.2, 0.4, 0.9) | 44x68 | 380 | 3 | Stronger jump force |
| Speedster | 1 | Red (0.9, 0.2, 0.2) | 36x60 | 500 | 4 | Faster, more air jumps |

### Conventions
- Input actions prefixed: `p1_`, `p2_` (move_left, move_right, move_up, move_down, jump, select)
- Kill zones: Y > 700, |X| > 1200
- Platform origin at (0,0), fighters spawn at (-200,-100) and (200,-100)
- Fighter collision bottom-aligned — feet at CharacterBody2D `position.y`
- P1: WASD + Space | P2: Arrows + Enter + Xbox controller (device 0)

## Current Repo State (Auto-Detected)

- Phase 1 (Foundation) is functionally complete: movement, camera, flow all wired up
- No TODO/FIXME/HACK markers found in any source file
- No test framework or test files present
- No art/audio assets — all visuals are ColorRect-based programmer art
- No fonts, themes, or .tres resource files
- Only 2 fighter types exist (Brawler, Speedster) — selected via integer toggle
- GameManager is minimal (stores two ints, one scene-change method)
- No attack/damage/knockback system yet
- No win condition, stock/percentage tracking, or match timer
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
