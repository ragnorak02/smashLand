# SmashLand — Game Direction

## Vision
A local-multiplayer 2D platform fighter inspired by Super Smash Bros., built in Godot 4.x with GDScript. Designed for fast, accessible couch gameplay with tight controls and expressive movement.

## Development Phases

### Phase 1 — Foundation
**Status: Complete**
- [x] Project structure and autoloads
- [x] Input system (keyboard P1/P2 + controller P2)
- [x] Character select screen (2 fighters)
- [x] Fighter movement (ground/air accel, friction)
- [x] Multi-jump system (per-fighter jump counts)
- [x] Fast fall mechanic
- [x] Kill zone respawn
- [x] Dynamic camera (tracking + zoom)
- [x] Debug input HUD
- [x] Arena with main platform + 2 floating platforms

### Phase 2 — Combat
**Status: Complete**
- [x] Basic attack system (7 attacks per fighter: ground neutral/forward, air neutral/forward/back/up/down)
- [x] Damage/percentage tracking (color-coded HUD)
- [x] Knockback physics (scaling formula with weight)
- [x] Hitstun/hitlag (freeze frames + hitstun duration)
- [x] Shield/block mechanic (drain, regen, shield break with 3s dizzy stun)
- [x] Grab system (grab, pummel, 4 directional throws, mash-out escape)

### Phase 3 — Game Flow (CURRENT)
**Status: Partially complete**
- [x] Stock/lives system (3 stocks per fighter)
- [x] Win/lose conditions (winner overlay → return to character select)
- [x] Combat HUD (damage % + stock icons)
- [x] Invulnerability on respawn (2s with blink)
- [ ] Match timer
- [ ] Results screen
- [ ] Main menu
- [ ] Pause menu

### Phase 4 — Content
- [ ] Additional fighters (3+)
- [ ] Additional stages
- [ ] Special moves per fighter
- [ ] Art assets (sprites replacing ColorRects)
- [ ] Sound effects and music
- [ ] Particle effects

### Phase 5 — Polish
- [ ] Settings menu (controls, audio, display)
- [ ] Screen shake and juice effects
- [ ] UI animations and transitions
- [ ] Performance optimization
- [ ] Accessibility options

## Design Pillars
1. **Feel-first** — movement and controls must feel responsive and satisfying above all else
2. **Local multiplayer** — designed for 2 players on one machine
3. **Readable** — even with programmer art, player states and actions should be visually clear
4. **Iterative** — build simple, test often, add complexity only when the foundation is solid

## Technical Constraints
- Godot 4.x with GL Compatibility renderer
- GDScript only (no C#/GDExtension)
- All UI/visuals built programmatically
- 1280x720 base resolution, canvas_items stretch
- Target: 60 FPS on modest hardware
