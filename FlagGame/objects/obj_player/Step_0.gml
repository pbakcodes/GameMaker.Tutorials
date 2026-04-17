// Don't process input when dead
if (state == PLAYER_STATE.DEAD) exit;

// Apply gravity: accelerate downward every frame
ysp += gravity_strength;
xsp = 0;

if (keyboard_check(vk_left))
{
	xsp = -move_speed;
	image_xscale = -1; // face left
}

if (keyboard_check(vk_right))
{
	xsp = move_speed;
	image_xscale = 1; // face right
}

// Ground check: if standing on a solid, zero vertical speed
// and allow jumping. Coyote time gives a small grace window
// for jumping after walking off a ledge.
var _grounded = place_meeting(x, y + 1, obj_solid);
if (_grounded)
{
	ysp = 0;
	coyote_time = coyote_max;
}
else
{
	if (coyote_time > 0)
		coyote_time--;
}

// Jump: only allowed while grounded or within coyote time
if (keyboard_check_pressed(vk_up) && coyote_time > 0)
{
	ysp = jump_strength;
	coyote_time = 0;
}

// Variable jump height: release jump key early to cut upward velocity
if (keyboard_check_released(vk_up) && ysp < 0)
{
	ysp *= 0.5;
}

move_and_collide(xsp, ysp, obj_solid);

// Update state for readability
if (xsp != 0 && _grounded)
	state = PLAYER_STATE.RUNNING;
else if (!_grounded)
	state = PLAYER_STATE.JUMPING;
else
	state = PLAYER_STATE.IDLE;

// Flag collision — advance to next level
if (place_meeting(x, y, obj_flag))
{
	if (room == Room3)
		room_goto(RoomWin);
	else
		room_goto_next();
}

// Spike collision — death with brief delay before restart
if (place_meeting(x, y, obj_spike))
{
	state = PLAYER_STATE.DEAD;
	xsp = 0;
	ysp = 0;
	visible = false;
	if (instance_exists(obj_game))
		obj_game.deaths++;
	alarm[0] = 30; // half-second delay before room_restart
}

