move_x = keyboard_check(vk_right) - keyboard_check(vk_left);
move_x = move_x * move_speed;

if (place_meeting(x, y + 2, obj_solid))
{
	move_y = 0;
	coyote_time = coyote_max;

	// Snap down slopes/edges instead of walking off
	if (!place_meeting(x + move_x, y + 2, obj_solid) && place_meeting(x + move_x, y + slope_snap_range, obj_solid))
	{
		move_y = min(abs(move_x), slope_snap_range);
		move_x = 0;
	}
}
else
{
	// Coyote time countdown
	if (coyote_time > 0)
		coyote_time--;

	// Apply gravity while airborne, capped at terminal velocity
	if (move_y < terminal_velocity)
		move_y += gravity_strength;

	// Zero vertical speed on ceiling hit to prevent sticking
	if (place_meeting(x, y - 1, obj_solid) && move_y < 0)
		move_y = 0;

	// Variable jump height — release jump to cut upward velocity
	if (keyboard_check_released(vk_space) && move_y < 0)
		move_y *= 0.5;
}

// Jump: allowed while grounded or within coyote time
if (keyboard_check_pressed(vk_space) && coyote_time > 0)
{
	move_y = -jump_speed;
	coyote_time = 0;
}

move_and_collide(move_x, move_y, obj_solid, 4, 0, 0, move_speed, -1);

if (move_x != 0)
{
	image_xscale = sign(move_x);
}

// Dust particles when moving on ground
if (place_meeting(x, y + 2, obj_solid) && move_x != 0)
{
	effect_create_below(ef_smoke, x, y + 8, 0.05, c_gray);
}

// Coin collection (distance-based — obj_coin has no sprite for instance_place)
with (obj_coin)
{
	if (point_distance(x, y, other.x, other.y) < coin_radius + 20)
	{
		if (instance_exists(obj_game))
			obj_game.coins++;
		effect_create_above(ef_firework, x, y, 0.3, c_yellow);
		instance_destroy();
	}
}

// Spike hazard (distance-based — obj_spike has no sprite for place_meeting)
with (obj_spike)
{
	if (point_distance(x, y, other.x, other.y) < 24)
	{
		if (instance_exists(obj_game))
			obj_game.deaths++;
		other.x = other.xstart;
		other.y = other.ystart;
		other.move_x = 0;
		other.move_y = 0;
		effect_create_above(ef_firework, other.x, other.y, 0.5, c_red);
	}
}