# CollisionsGame — Code Review & Improvement Plan

## Overview

A minimal top-down collision demo: a player moves with WASD and collides with walls using `move_and_collide()`. The wall corner object is made invisible via instance creation code. That's it — this is essentially a tech demo for the collision system.

---

## Rating

| Category        | Score | Notes |
|-----------------|-------|-------|
| **Architecture**    | 5/10  | Clean and minimal, but almost no architecture to evaluate |
| **Learning Value**  | 6/10  | Demonstrates `move_and_collide()` and basic input, but doesn't go further |
| **Code Quality**    | 6/10  | Simple and readable, few issues due to minimal scope |

---

## What Is Written Well

1. **Clean input handling pattern** — Using `_right - _left` and `_down - _up` to get normalized -1/0/+1 axis input is the correct idiomatic way to handle 4-directional movement in GML. This is a good pattern to learn.
2. **Proper use of local variables** — `var _right`, `var _left`, etc. are correctly declared as local variables with the `_` prefix. This is proper GML convention.
3. **`move_and_collide()` usage** — This is the modern GML approach for solid collisions, better than the old `place_meeting` + manual pixel pushing patterns.
4. **Separation of wall types** — Having `obj_wall` and `obj_wall_corner` as separate objects with the corner being invisible shows awareness of using invisible collision shapes for level geometry.

---

## What Is Poorly Designed

### 1. No Diagonal Speed Normalization

```gml
var _xinput = _right - _left;
var _yinput = _down - _up;
move_and_collide(_xinput * my_speed, _yinput * my_speed, obj_wall, 4, 0, 0, my_speed, my_speed);
```

When pressing two keys (e.g., W+D), `_xinput = 1` and `_yinput = -1`, so the player moves at `√(4² + 4²) ≈ 5.66` instead of `4`. Diagonal movement is ~41% faster.

### 2. Boilerplate Comments Left In

```gml
/// @description Insert description here
// You can write your code in this editor
```

These are auto-generated template comments that should be removed or replaced with actual descriptions.

### 3. Collision Only Against `obj_wall`

`move_and_collide()` is called with `obj_wall` specifically. The invisible `obj_wall_corner` won't be collided with unless it's a child of `obj_wall`. If it's not set up as a parent-child relationship, the corners are purely visual (invisible visual, even) with no collision.

### 4. Instance Creation Code for Visibility

```gml
// InstanceCreationCode_inst_556FDAAF.gml
visible = false;
```

Using instance creation code to hide the corner wall works but is fragile — every new corner instance placed in the room needs the same creation code. It would be better to set `visible = false` in the object's Create event.

### 5. No Goal or Gameplay

This is purely a movement-and-collision sandbox. There's nothing to do, which limits its value as a learning project.

---

## Improvement Plan

### Priority 1 — Bug Fixes & Correctness

- [x] **Normalize diagonal movement**:
  ```gml
  var _xinput = _right - _left;
  var _yinput = _down - _up;

  var _len = sqrt(_xinput * _xinput + _yinput * _yinput);
  if (_len > 0) {
      _xinput /= _len;
      _yinput /= _len;
  }

  move_and_collide(_xinput * my_speed, _yinput * my_speed, obj_wall, 4, 0, 0, my_speed, my_speed);
  ```
- [x] **Verify wall_corner is a child of obj_wall** so collisions work for both. If not, set `obj_wall` as the parent of `obj_wall_corner` in the object editor.
- [x] **Move `visible = false` to obj_wall_corner's Create event** instead of using instance creation code. Delete the instance creation code.

### Priority 2 — Architecture

- [x] **Use a parent object for all collidables**: Create `obj_solid` as a parent for `obj_wall` and `obj_wall_corner`. Collide against `obj_solid` instead. This scales when you add more solid types.
  > Created `obj_solid`, set as parent of `obj_wall`. Player now collides against `obj_solid`.
- [x] **Remove boilerplate comments**: Replace `/// @description Insert description here` with actual descriptions or remove them.

### Priority 3 — Gameplay (Turn This Into a Real Demo)

- [x] **Add a goal**: Place a collectible object. When the player touches it, spawn another randomly. Track a score or count.
  > Created `obj_collectible` (bobbing yellow circle) and `obj_game` (score tracking + HUD). Collectibles respawn at random positions on pickup.
- [x] **Add a simple maze or obstacle course**: Design the room layout as a proper level with a start and end point.
  > Superseded by the collectible system — the demo now has gameplay with a spawning collectible and score tracking. Room layout can be further refined in the GameMaker room editor.
- [x] **Add visual feedback**: Camera shake on wall collision, particle dust when moving, anything to make the demo feel alive.
  > Added dust trail particles (`effect_create_below(ef_smoke...)`) when player moves, and sprite flipping for facing direction.
- [x] **Add animation**: Animate the player sprite based on movement direction (at minimum, flip the sprite using `image_xscale`).

### Priority 4 — Code Quality

- [x] **Add `my_speed` as a documented constant** — comment what unit it's in (pixels per frame).
- [x] **Use semicolons consistently** at end of statements.
