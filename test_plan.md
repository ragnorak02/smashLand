# SmashLand — Test Plan

## Overview
Manual testing protocol for SmashLand. No automated test framework is currently integrated. Tests are organized by system and should be run after each significant change.

---

## 1. Launch & Scene Flow

| # | Test | Expected Result | Pass? |
|---|------|-----------------|-------|
| 1.1 | Launch project from Godot editor | Main.tscn loads, immediately transitions to CharacterSelect | |
| 1.2 | Both players select fighters and confirm | "GET READY!" appears, Arena loads after ~0.8s | |
| 1.3 | Verify no errors in Output panel during full flow | Clean output, no script errors or warnings | |

## 2. Character Select

| # | Test | Expected Result | Pass? |
|---|------|-----------------|-------|
| 2.1 | P1 press W/S | Selection toggles between Brawler and Speedster | |
| 2.2 | P2 press Up/Down arrows | Selection toggles between Brawler and Speedster | |
| 2.3 | P1 press Space | "READY!" appears for P1 | |
| 2.4 | P2 press Enter | "READY!" appears for P2 | |
| 2.5 | Ready player presses W/S or Up/Down | Un-readies and switches selection | |
| 2.6 | Both players select same fighter | Both can pick the same type; arena spawns two of that type | |
| 2.7 | Controller D-pad/stick for P2 | Selection changes with controller input | |
| 2.8 | Controller A button for P2 | Confirms P2 selection | |

## 3. Fighter Movement

| # | Test | Expected Result | Pass? |
|---|------|-----------------|-------|
| 3.1 | P1 hold A/D | Fighter moves left/right with acceleration | |
| 3.2 | P2 hold Left/Right arrows | Fighter moves left/right with acceleration | |
| 3.3 | Release movement key on ground | Fighter decelerates to stop (ground friction) | |
| 3.4 | Release movement key in air | Fighter decelerates slower (air friction) | |
| 3.5 | Move left then right | Eyes switch sides to indicate facing direction | |
| 3.6 | Brawler vs Speedster speed | Speedster visibly faster than Brawler | |

## 4. Jumping

| # | Test | Expected Result | Pass? |
|---|------|-----------------|-------|
| 4.1 | Press jump on ground | Fighter jumps upward | |
| 4.2 | Press jump in air (Brawler) | Can air jump up to 2 more times (3 total) | |
| 4.3 | Press jump in air (Speedster) | Can air jump up to 3 more times (4 total) | |
| 4.4 | Jump counter display | "x{N}" shows remaining jumps above fighter head while airborne | |
| 4.5 | Land on platform | Jump counter resets, label disappears | |
| 4.6 | Exhaust all jumps | No more upward movement on further jump presses | |

## 5. Fast Fall

| # | Test | Expected Result | Pass? |
|---|------|-----------------|-------|
| 5.1 | Press down while falling | Fighter accelerates downward (fast fall) | |
| 5.2 | Press down while rising | No fast fall (only activates when velocity.y >= 0) | |
| 5.3 | Fast fall then land | Fast fall state resets | |
| 5.4 | Fast fall then jump | Fast fall cancels, normal jump occurs | |

## 6. Kill Zones & Respawn

| # | Test | Expected Result | Pass? |
|---|------|-----------------|-------|
| 6.1 | Fall below Y=700 | Fighter respawns at spawn position | |
| 6.2 | Move past X=1200 (right) | Fighter respawns at spawn position | |
| 6.3 | Move past X=-1200 (left) | Fighter respawns at spawn position | |
| 6.4 | Respawn state | Velocity zeroed, jumps reset, fast fall off | |

## 7. Camera

| # | Test | Expected Result | Pass? |
|---|------|-----------------|-------|
| 7.1 | Fighters close together | Camera zooms in (up to MAX_ZOOM 1.4) | |
| 7.2 | Fighters far apart | Camera zooms out (down to MIN_ZOOM 0.4) | |
| 7.3 | Camera follows center | Camera position tracks midpoint of both fighters | |
| 7.4 | Camera movement is smooth | No jerky snapping — uses lerp interpolation | |

## 8. Debug HUD

| # | Test | Expected Result | Pass? |
|---|------|-----------------|-------|
| 8.1 | HUD visible in arena | Input debug panel shows in top-left corner | |
| 8.2 | Movement values update | H/V axes reflect real-time input | |
| 8.3 | Jump held indicator | Shows "HELD" while jump button pressed | |
| 8.4 | Floor/velocity state | Shows Y/N for floor contact, velocity values | |
| 8.5 | Input method display | P1 shows "Keyboard", P2 shows "Controller" or "Keyboard" | |

## 9. Platforms

| # | Test | Expected Result | Pass? |
|---|------|-----------------|-------|
| 9.1 | Stand on main platform | Fighter rests on main platform at Y=0 | |
| 9.2 | Stand on left floating platform | Fighter can land on platform at (-480, -130) | |
| 9.3 | Stand on right floating platform | Fighter can land on platform at (480, -130) | |
| 9.4 | Walk off platform edge | Fighter falls with gravity | |

---

## Future: Automated Testing
When a test framework is added (e.g., GdUnit4 or GUT), prioritize automating:
1. Fighter stat initialization per type
2. Jump counter decrement/reset logic
3. Kill zone boundary detection
4. Scene transition flow
5. Input action registration
