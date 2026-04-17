# MovementGame — Code Review & Improvement Plan

## Overview

A platformer movement demo: player moves left/right, jumps, has gravity, collides with ground tiles, and handles slope-like edge snapping. Only `obj_player` has code; `obj_ground` and `obj_ground_corner` are pure collision objects.

---

## Rating

| Category        | Score | Notes |
|-----------------|-------|-------|
| **Architecture**    | 5/10  | Clean single-object logic, but no game structure around it |
| **Learning Value**  | 7/10  | Demonstrates a more advanced movement pattern with edge-snapping |
| **Code Quality**    | 5/10  | Functional with a clever slope trick, but has issues |

---

## What Is Written Well

1. **Edge/slope snapping logic** — This is the most interesting code in all four projects:
   ```gml
   if (!place_meeting(x+move_x, y+2, obj_ground) && place_meeting(x+move_x, y+10, obj_ground))
   {
       move_y = abs(move_x);
       move_x = 0;
   }
   ```
   When the player is grounded but the next horizontal position has no ground directly below (but does have ground 10px below), it converts horizontal movement into downward movement. This makes the player "snap" down slopes and ledge edges instead of walking off and falling. This is a thoughtful gameplay detail.

2. **Sprite flipping for facing direction**:
   ```gml
   if move_x != 0
       image_xscale = sign(move_x)
   ```
   Simple, correct, and only updates when actually moving. Good pattern.

3. **Named variables for speed constants** — `move_speed` and `jump_speed` are defined in Create and used by name. Better than the magic numbers in the other projects.

4. **`move_and_collide()` with proper parameters** — Passing `move_speed` as the max horizontal slide and `-1` for unlimited vertical is appropriate for a platformer.

---

## What Is Poorly Designed

### 1. Gravity Is Hardcoded to `1` with a Cap of `10`

```gml
if move_y < 10
    move_y += 1;
```

The gravity value `1` and terminal velocity `10` are magic numbers buried in the Step event. These should be named constants.

### 2. Jump Speed of 16 Is Very High

```gml
jump_speed = 16;
```

With gravity of `1` per frame, a jump of `-16` means the player rises for 16 frames (about 0.27 seconds at 60fps) covering 136 pixels upward. This is a huge jump. Combined with `move_speed = 4`, the player jumps much higher than they can walk, which might feel floaty.

### 3. The Edge-Snap Logic Has a Gap

The slope-snapping checks `y+10` but only sets `move_y = abs(move_x)` which is `4`. So it tries to fall 4px but checked for ground within 10px. If the ledge drops more than 4px but less than 10px, the player will snap partway down and walk off the next frame. This might cause jitter on certain ledge heights. The check range and the snap amount should be consistent.

### 4. No Ceiling Collision Handling

When the player jumps into a ceiling, `move_and_collide` will stop them, but `move_y` stays negative until gravity overcomes it. The player will "stick" to the ceiling for several frames visually. Should zero `move_y` on ceiling hit:
```gml
if (place_meeting(x, y-1, obj_ground) && move_y < 0)
    move_y = 0;
```

### 5. Boilerplate Comments

Same as other projects — auto-generated comments not replaced.

### 6. Missing Semicolons

```gml
move_x = 0   // no semicolon
move_y = 0   // no semicolon
image_xscale = sign(move_x)  // no semicolon
```

### 7. No Gameplay Beyond Movement

Like CollisionsGame, this is a movement sandbox with no goal, no hazards, no level progression.

### 8. Only Collides Against `obj_ground`

`obj_ground_corner` exists as a separate object. Unless it's a child of `obj_ground`, the player won't collide with corners. Should use a parent object for all solids.

---

## Improvement Plan

### Priority 1 — Bug Fixes & Correctness

- [x] **Add ceiling collision zeroing**:
  ```gml
  if (place_meeting(x, y-1, obj_ground) && move_y < 0)
      move_y = 0;
  ```
- [x] **Fix edge-snap consistency**: Either increase `move_y = abs(move_x)` to match the 10px check range, or reduce the check range to match the snap amount. A better approach:
  ```gml
  move_y = min(abs(move_x), 10); // snap down by horizontal speed, capped at check range
  ```
- [x] **Verify `obj_ground_corner` is a child of `obj_ground`** for collision purposes. If not, set up the parent-child relationship.
- [x] **Balance jump vs gravity**: Either reduce `jump_speed` to ~10 or increase `move_speed` to ~6 to make the movement proportional.

### Priority 2 — Architecture

- [x] **Extract physics constants**:
  ```gml
  // Create event
  move_speed = 4;
  jump_speed = 10;
  gravity_strength = 0.6;
  terminal_velocity = 10;
  slope_snap_range = 8;
  ```
- [x] **Use a parent `obj_solid`** for `obj_ground` and `obj_ground_corner`. Collide against `obj_solid`.
  > Created `obj_solid`, set as parent of `obj_ground`. All collision checks now use `obj_solid`.
- [x] **Add a game controller object** if expanding this into a real project.
  > Created `obj_game` with coin/death counters and DrawGUI HUD. Placed in Room1.

### Priority 3 — Gameplay

- [x] **Add collectibles or a goal**: Even a simple "reach the flag" objective makes this a game.
  > Created `obj_coin` (bobbing yellow circle), placed 5 coins across the level. Player collects via `instance_place()`, tracked by `obj_game`.
- [x] **Add hazards**: Spikes, pits, moving platforms.
  > Created `obj_spike` (red triangle), placed 2 spikes on ground. Player respawns to start position on contact, death tracked by `obj_game`.
- [x] **Add coyote time**: Allow jumping for ~5 frames after walking off a ledge.
- [x] **Add variable jump height**: Halve `move_y` when jump key is released mid-air.
- [x] **Add dust particles on land/jump**: Small visual feedback that makes movement feel responsive.
  > Added `effect_create_below(ef_smoke...)` dust trail when player moves on ground.
- [x] **Design a proper level**: The room should have a designed path with jumps of varying difficulty to test the movement system.
  > Placed coins at progressively harder-to-reach platforms and spikes on the main ground to encourage platforming.

### Priority 4 — Code Quality

- [x] **Remove boilerplate comments** or write meaningful descriptions.
- [x] **Add semicolons consistently**.
- [x] **Comment the edge-snapping logic** — it's the most complex part and not immediately obvious what it does.
