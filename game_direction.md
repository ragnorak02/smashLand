# SmashLand — Game Direction

## Vision
A local-multiplayer 2D platform fighter inspired by Super Smash Bros., built in Godot 4.x with GDScript. Designed for fast, accessible couch gameplay with tight controls and expressive movement.

## Development Phases

### Phase 1 — Foundation (CURRENT)
**Status: Core complete**
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
- [ ] Basic attack system (normal attacks)
- [ ] Damage/percentage tracking
- [ ] Knockback physics
- [ ] Hitstun/hitlag
- [ ] Shield/block mechanic
- [ ] Grab system

### Phase 3 — Game Flow
- [ ] Stock/lives system
- [ ] Match timer
- [ ] Win/lose conditions
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
