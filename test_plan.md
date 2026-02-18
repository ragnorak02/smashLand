# SmashLand — Test Plan

## Overview
Testing protocol for SmashLand. An automated headless test suite exists at `tests/run-tests.gd` (32 tests, 9 suites) covering script loading, attack data, knockback math, config validation, and performance. The manual tests below cover gameplay behavior that requires human verification.

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

## 10. Attacks

| # | Test | Expected Result | Pass? |
|---|------|-----------------|-------|
| 10.1 | P1 press Q on ground (no direction) | Ground neutral attack — yellow hitbox appears briefly | |
| 10.2 | P1 press Q while holding A or D | Ground forward attack — larger hitbox in movement direction | |
| 10.3 | P1 press Q in air (no direction) | Air neutral — hitbox surrounds fighter | |
| 10.4 | P1 press Q in air + hold D (facing right) | Air forward attack | |
| 10.5 | P1 press Q in air + hold A (facing right) | Air back attack (hitbox behind) | |
| 10.6 | P1 press Q in air + hold W | Air up attack — hitbox above fighter | |
| 10.7 | P1 press Q in air + hold S | Air down attack — hitbox below (spike) | |
| 10.8 | Attack hits opponent | Opponent flashes white, enters hitstun, takes knockback | |
| 10.9 | Hitbox visible during active frames | Yellow overlay rectangle appears during attack active window | |
| 10.10 | Attack startup/recovery | Fighter cannot act during startup or recovery frames | |

## 11. Damage & Knockback

| # | Test | Expected Result | Pass? |
|---|------|-----------------|-------|
| 11.1 | Hit opponent at 0% | Small knockback, short hitstun | |
| 11.2 | Hit opponent at 100%+ | Large knockback, longer hitstun, likely KO at edges | |
| 11.3 | Brawler vs Speedster knockback | Speedster (weight 80) flies farther than Brawler (weight 100) from same hit | |
| 11.4 | Hitlag freeze | Both fighters freeze briefly on hit (more frames for stronger attacks) | |
| 11.5 | Damage HUD updates | Percentage display updates after each hit, color shifts at higher % | |
| 11.6 | Knockback trail | Orange trail line appears on the hit fighter | |

## 12. Shield

| # | Test | Expected Result | Pass? |
|---|------|-----------------|-------|
| 12.1 | P1 hold E on ground | Blue shield bubble appears around fighter | |
| 12.2 | Shield shrinks over time | Bubble radius decreases as shield health drains | |
| 12.3 | Release E | Shield drops, fighter returns to idle | |
| 12.4 | Attack hits shield | Shield stun, pushback, shield health reduced (1.5x damage) | |
| 12.5 | Shield health reaches 0 | Shield break — stars orbit above head, 3s dizzy stun | |
| 12.6 | After shield break ends | Shield partially recovers (30% health), fighter returns to idle | |
| 12.7 | Shield health regenerates | After 1s delay, shield slowly refills when not shielding | |
| 12.8 | Jump out of shield | Press Space while shielding — cancels shield into jump | |
| 12.9 | Grab out of shield | Press R while shielding — cancels shield into grab | |
| 12.10 | Shield in air | Shield only activates on ground, not in air | |

## 13. Grab System

| # | Test | Expected Result | Pass? |
|---|------|-----------------|-------|
| 13.1 | P1 press R on ground | Grab startup → green hitbox appears in front | |
| 13.2 | Grab connects on opponent | Opponent locked in place in front of grabber | |
| 13.3 | Grab beats shield | Grabbing a shielding opponent still connects | |
| 13.4 | Grab whiff | If grab misses, long recovery (punishable) | |
| 13.5 | Pummel during grab hold | Press Q while holding — victim takes small damage, flashes white | |
| 13.6 | Forward throw | Hold direction toward opponent + release — victim launched forward | |
| 13.7 | Back throw | Hold direction away from opponent — victim launched backward | |
| 13.8 | Up throw | Hold W during grab — victim launched upward | |
| 13.9 | Down throw | Hold S during grab — victim launched downward | |
| 13.10 | Mash out of grab | Grabbed player presses attack/jump/shield/grab rapidly to escape early | |
| 13.11 | Grab hold time expires | Victim automatically released after hold timer runs out | |
| 13.12 | Grab hold scales with damage | Higher-% victims are held longer (0.4s–2.0s range) | |

## 14. Stocks & Match Flow

| # | Test | Expected Result | Pass? |
|---|------|-----------------|-------|
| 14.1 | Fighter KO'd by knockback | Stock icon removed from HUD, stock count decrements | |
| 14.2 | Respawn after KO | Fighter reappears at spawn, 0% damage, 2s invulnerability blink | |
| 14.3 | Invulnerability on respawn | Attacks pass through respawning fighter for 2 seconds | |
| 14.4 | Last stock lost | Fighter disappears, match ends | |
| 14.5 | Winner overlay | "PLAYER X WINS!" displayed, auto-returns to character select | |
| 14.6 | Stock icons accurate | HUD shows correct number of remaining stock icons per player | |

## 15. Visual Effects

| # | Test | Expected Result | Pass? |
|---|------|-----------------|-------|
| 15.1 | Hit flash | Struck fighter body turns white briefly | |
| 15.2 | Shield color gradient | Shield transitions blue→red as health drops | |
| 15.3 | Shield break stars | Three yellow stars orbit above head during break stun | |
| 15.4 | Knockback trail | Orange line in opposite direction of knockback velocity | |
| 15.5 | Invulnerability blink | Fighter opacity pulses during invuln period | |
| 15.6 | Hitlag shake | Both fighters visually shake during hitlag freeze | |

---

## Automated Test Suite
The automated test runner at `tests/run-tests.gd` (run via `tests/run-tests.bat` or `tests/run-tests.sh`) covers:
1. Scene file existence and loading (Main, CharacterSelect, Arena, FighterBase)
2. Script file loading (all 10 core scripts + autoloads)
3. Attack data validation (all 7 attack types for both fighters have required fields)
4. Knockback formula correctness (math verification at various damage/weight values)
5. Game config JSON structure and required fields
6. Performance benchmarks (script load times)

To run: `godot --headless --script tests/run-tests.gd` (outputs JSON to stdout)
