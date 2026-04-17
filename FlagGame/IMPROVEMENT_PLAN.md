# FlagGame — Code Review & Improvement Plan

## Overview

A simple platformer: player has gravity, horizontal movement, jumps off solid tiles, dies on spikes (room restarts), and advances to the next room on touching a flag. Three rooms serve as levels.

---

## Rating

| Category        | Score | Notes |
|-----------------|-------|-------|
| **Architecture**    | 5/10  | Functional but everything is in one Step event with no state management |
| **Learning Value**  | 8/10  | Best learning project of the four — covers gravity, platforming, collisions, level progression, hazards |
| **Code Quality**    | 5/10  | Readable and mostly correct, but has issues with hardcoded values and window sizing |

---

## What Is Written Well

1. **Solid platformer physics pattern** — The gravity/jump structure is textbook GameMaker platformer:
   ```gml
   ysp += 0.1;  // gravity
   if place_meeting(x, y+1, obj_solid)  // grounded check
       ysp = 0;
       if keyboard_check(vk_up)
           ysp = -2;  // jump
   ```
   This is the correct approach: apply gravity every frame, zero it on ground, apply negative velocity for jump.

2. **`move_and_collide()` for solid collision** — Using the modern collision function instead of manual pixel-by-pixel movement is good practice.

3. **`place_meeting()` for trigger collisions** — Flag and spike detection uses `place_meeting()` (overlap check without movement), which is the right tool for trigger zones that don't need physical resolution.

4. **Multi-room level progression** — `room_goto_next()` on flag touch and `room_restart()` on spike death is a clean, simple level system. Three rooms provide actual level progression.

5. **Clean separation of object roles** — `obj_solid` has no code (pure collision), `obj_flag` and `obj_spike` have no code (checked by player), and all logic lives in the player. For a small project, this centralization is acceptable.

---

## What Is Poorly Designed

### 1. `window_set_size(1280, 720)` in Create Event

```gml
window_set_size(1280, 720)
```

Setting window size in the player's Create event is wrong for multiple reasons:
- It runs every time the player is created (every room transition, every death restart)
- Window configuration should be in a persistent game controller, not a gameplay object
- It doesn't set the view/camera — just the OS window. The game resolution and the window size may mismatch

### 2. No Delta-Time or Frame-Rate Independence

```gml
ysp += 0.1;   // gravity per frame
xsp = -1;     // pixels per frame
ysp = -2;     // jump velocity
```

All movement is frame-rate dependent. At 30fps the game runs at half speed, at 120fps it runs at double speed. For a tutorial this is acceptable, but it's a bad habit to build.

### 3. Very Small Movement Values

- Gravity: `0.1` per frame
- Horizontal speed: `1` pixel per frame (60 pixels/sec at 60fps)
- Jump velocity: `-2`

These are unusually small for a GameMaker game. The player likely feels sluggish. Typical values would be gravity ~0.5, hspeed ~3-4, jump ~-8.

### 4. Boilerplate Comments

```gml
/// @description Insert description here
// You can write your code in this editor
```

Left over from auto-generation, should be removed or replaced.

### 5. Missing Semicolons (Inconsistent Style)

```gml
window_set_size(1280, 720)  // no semicolon
xsp = 0                      // no semicolon
move_and_collide(xsp, ysp, obj_solid)  // no semicolon
```

GML allows omitting semicolons but mixing styles is messy.

### 6. No Visual Feedback on Death

Player touches a spike and the room just restarts instantly. No death animation, no sound, no screen effect. The player has no time to understand what happened.

### 7. No Safety on `room_goto_next()`

If the player touches the flag in the last room (Room3), `room_goto_next()` will either error or wrap to Room1. There's no win condition or end screen.

---

## Improvement Plan

### Priority 1 — Bug Fixes & Correctness

- [x] **Move `window_set_size()` out of the player**: Put it in a persistent `obj_game` controller's Create event, or set the resolution in the room/project settings instead.
- [x] **Guard `room_goto_next()`**: Check if the current room is the last one:
  ```gml
  if (room == room_last)
      // show win screen or return to menu
  else
      room_goto_next();
  ```
- [x] **Increase movement values** to feel better: gravity ~0.4, hspeed ~3, jump ~-7. Playtest and adjust.

### Priority 2 — Architecture

- [x] **Create `obj_game` controller** (persistent): Handle window setup, game state (playing, dead, won), and level tracking.
  > Created persistent `obj_game` with duplicate check, `window_set_size()`, death counter, and DrawGUI HUD showing deaths and room name.
- [x] **Consider using a state machine for the player**: Even a simple `enum { IDLE, RUNNING, JUMPING, DEAD }` makes the code more extensible and readable.
  > Implemented `enum PLAYER_STATE { IDLE, RUNNING, JUMPING, DEAD }` in Create, state transitions in Step, DEAD state blocks input and triggers alarm-based restart.
- [x] **Extract constants**:
  ```gml
  gravity_strength = 0.4;
  move_speed = 3;
  jump_strength = -7;
  ```

### Priority 3 — Gameplay Polish

- [x] **Add death feedback**: Flash screen, play a sound, brief pause before restart. Use an alarm:
  ```gml
  if place_meeting(x, y, obj_spike) {
      // freeze player, play effect
      alarm[0] = 30; // then room_restart in alarm
  }
  ```
- [x] **Add a win screen for the final level**: When touching the flag in Room3, go to a "You Win" room instead of crashing.
  > Created `RoomWin` with `obj_win_screen` (shows "YOU WIN!" text, Enter to replay). Flag check in Room3 goes to `RoomWin` instead of `room_goto_next()`.
- [x] **Add coyote time**: Allow jumping for a few frames after walking off a ledge — standard platformer feel improvement.
- [x] **Add variable jump height**: Check `keyboard_check_released(vk_up)` and cut `ysp` in half when the player releases jump early.
- [x] **Add simple animation**: Flip sprite with `image_xscale = sign(xsp)` for facing direction. Use different sprite indices for idle/run/jump if sprites exist.
- [x] **Add a background** to the rooms (there's `sBackground` sprite in sprites — use it).
  > Verified: all 3 rooms already have `sBackground` set as their background layer sprite.

### Priority 4 — Code Quality

- [x] **Remove boilerplate comments** or replace with real descriptions.
- [x] **Add semicolons consistently** to all statements.
- [x] **Comment the physics section** explaining the gravity/ground-check/jump pattern for learning purposes.
