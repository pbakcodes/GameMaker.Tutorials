global.points += 50;

instance_destroy(other);
effect_create_above(ef_explosion, x, y, 1, c_white);
obj_game_score.shake_amount = 3; // light shake on rock hit

direction = random(360);

// Rock lifecycle: big rocks split into two small rocks on hit.
// Small rocks respawn as big rocks offscreen if population is low,
// otherwise they are destroyed.
if (size == 1)
{
	sprite_index = spr_rock_small;
	size = 0;
	var _copy = instance_copy(true);
	_copy.direction = random(360);
}
else if (instance_number(obj_rock) < obj_game_score.max_rocks)
{
	sprite_index = spr_rock_big;
	size = 1;
	x = -100;
	// Difficulty: rocks get faster as score increases
	speed = 1 + min(global.points / 500, 3);
}
else
{
	instance_destroy();
}