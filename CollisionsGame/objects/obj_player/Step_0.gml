var _right = keyboard_check(ord("D"));
var _left = keyboard_check(ord("A"));
var _up = keyboard_check(ord("W"));
var _down = keyboard_check(ord("S"));

var _xinput = _right - _left;
var _yinput = _down - _up;

// Normalize diagonal movement to prevent faster diagonal speed
var _len = sqrt(_xinput * _xinput + _yinput * _yinput);
if (_len > 0)
{
	_xinput /= _len;
	_yinput /= _len;
}

move_and_collide(_xinput * my_speed, _yinput * my_speed, obj_solid, 4, 0, 0, my_speed, my_speed);

// Subtle dust trail when moving
if (_xinput != 0 || _yinput != 0)
{
	effect_create_below(ef_smoke, x, y, 0.1, c_gray);
}

// Flip sprite to face movement direction
if (_xinput != 0)
{
	image_xscale = sign(_xinput);
}

// Collectible pickup (distance-based — obj_collectible has no sprite for instance_place)
var _game = instance_find(obj_game, 0);
with (obj_collectible)
{
	if (point_distance(x, y, other.x, other.y) < collect_radius + 24)
	{
		if (_game != noone)
			_game.collected = _game.collected + 1;
		// Respawn at a new position not inside any wall
		var _nx, _ny;
		do {
			_nx = irandom_range(240, room_width - 64);
			_ny = irandom_range(64, room_height - 64);
		} until (!position_meeting(_nx, _ny, obj_solid));
		x = _nx;
		y = _ny;
		effect_create_above(ef_firework, other.x, other.y, 0.5, c_yellow);
	}
}