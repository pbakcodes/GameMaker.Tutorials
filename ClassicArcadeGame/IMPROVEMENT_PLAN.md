# ClassicArcadeGame — Code Review & Improvement Plan

## Overview

An Asteroids-style arcade game: player ship rotates, thrusts, wraps around the screen, shoots bullets at rocks that split into smaller rocks, with scoring.

---

## Rating

| Category        | Score | Notes |
|-----------------|-------|-------|
| **Architecture**    | 4/10  | Tight coupling between objects, no game state management |
| **Learning Value**  | 7/10  | Covers core GML concepts: motion, collisions, spawning, scoring, room wrap |
| **Code Quality**    | 4/10  | Works but has bugs, magic numbers, and cross-object variable access |

---

## What Is Written Well

1. **Good use of built-in GML motion system** — `motion_add()`, `speed`, `direction`, `move_wrap()` are idiomatic GameMaker for this type of game.
2. **Rock splitting mechanic** — `Collision_obj_bullet.gml` has a clever rock lifecycle: big rocks split into two small ones via `instance_copy()`, small rocks eventually recycle back to big when population is low. This is a solid game design pattern.
3. **Separation of scoring into its own object** — `obj_game_score` handles draw and game-over restart independently, which is a step toward separating concerns.
4. **Bullet inherits direction from player** — `direction = obj_player.image_angle` is simple and effective for aiming.

---

## What Is Poorly Designed

### 1. Direct Cross-Object Variable Access (Tight Coupling)

```gml
// obj_bullet/Create_0.gml
direction = obj_player.image_angle;

// obj_rock/Collision_obj_bullet.gml
obj_game_score._points += 50;

// obj_player/Collision_obj_rock.gml
obj_game_score.alarm[0] = 120;
```

Every object directly reaches into other objects' internals. If you rename a variable or remove an object, multiple files break silently.

### 2. Underscore-Prefixed Instance Variable `_points`

In GML, the `_` prefix convention is used for **local** (temporary) variables. Using it on an instance variable (`_points`) is misleading and will confuse anyone reading the code.

### 3. Magic Numbers Everywhere

- `speed = 10` — What is 10? Pixel speed?
- `0.1` gravity constant in `motion_add(image_angle, 0.1)`
- `image_angle += 4` — rotation speed
- `alarm[0] = 120` — 2 seconds at 60fps, but why 120?
- `instance_number(obj_rock) < 12` — why 12?

### 4. No Fire Rate Limiting

Player can spam `vk_space` every frame and flood the screen with bullets. There's no cooldown or ammo system.

### 5. Bullet Cleanup Only on Room Exit

`Other_0.gml` (Outside Room event) calls `instance_destroy()`, which is correct, but bullets are never destroyed on a timer. If the room is large or wrapping is applied to bullets too, they could persist forever. Currently wrapping is only on the player — bullets leaving the room are destroyed. This works but is fragile.

### 6. Player Death Logic Is Scattered

- `Collision_obj_rock.gml` creates a firework effect and destroys the player
- Then sets `obj_game_score.alarm[0] = 120` to restart 2 seconds later
- The alarm event does `room_restart()` — but there's no lives system, no game-over screen, no invulnerability frames

### 7. No Game State Machine

There's no concept of "playing", "game over", "paused". The game just runs and restarts.

### 8. Room Size Doesn't Match Viewport

Room is 1000x1000 but views are 1366x768 and disabled. The game likely runs at default window size with the room not filling/fitting the window properly.

---

## Improvement Plan

### Priority 1 — Bug Fixes & Correctness

- [x] **Fix room/viewport setup**: Enable views, set the view to match the room size, or set the room size to match the desired resolution.
- [x] **Add fire rate cooldown**: Use an alarm or cooldown variable so bullets can only fire every N frames.
- [x] **Fix `_points` naming**: Rename to `points` (no underscore) since it's an instance variable, not a local.

### Priority 2 — Architecture

- [x] **Create a game controller object** (`obj_game`): Manage game states (playing, game_over, paused) with an enum/state variable. Move score tracking and restart logic here.
  > Expanded `obj_game_score` instead: made it persistent, added lives, high score persistence, and game-over/restart logic.
- [x] **Eliminate direct cross-object variable access**: Pass data through functions or use `with` blocks more carefully. For the bullet, pass direction as a variable set after creation:
  ```gml
  var _b = instance_create_layer(x, y, "Instances", obj_bullet);
  _b.direction = image_angle;
  ```
- [x] **Extract magic numbers into named variables** in Create events:
  ```gml
  bullet_speed = 10;
  thrust_power = 0.1;
  rotation_speed = 4;
  restart_delay = 120;
  max_rocks = 12;
  ```

### Priority 3 — Gameplay Polish

- [x] **Add lives system**: 3 lives, show on HUD, game over screen when lives run out.
- [x] **Add invulnerability frames after respawn**: Flash the player sprite for 1-2 seconds after restart.
- [x] **Add difficulty scaling**: Increase rock count or speed as score goes up.
- [x] **Add high score persistence**: Use `ini_open`/`ini_write_real` to save the best score.
- [x] **Improve HUD**: Show score with proper font, add lives display, maybe a wave counter.
- [x] **Add screen shake on death/rock destruction**: Use `camera_set_view_pos` with small random offsets for juice.
  > Implemented in `obj_game_score/Step_0.gml` — `shake_amount` decays each frame, applied as random camera offset.

### Priority 4 — Code Quality

- [x] **Add comments** explaining the rock lifecycle (split → recycle → respawn logic).
- [x] **Use semicolons consistently** — some lines have them, some don't (GML allows both but consistency matters).
- [x] **Consider using `sprite_index` check as an enum** — instead of checking `sprite_index == spr_rock_big`, use a `size` variable on the rock to make intent clearer.
