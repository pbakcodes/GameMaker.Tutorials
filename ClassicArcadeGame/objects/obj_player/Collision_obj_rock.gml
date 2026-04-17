// Skip collision while invulnerable
if (invulnerable > 0)
	exit;

effect_create_above(ef_firework, x, y, 1, c_white);
instance_destroy();

global.lives--;
obj_game_score.shake_amount = 8; // strong shake on death
obj_game_score.alarm[0] = obj_game_score.restart_delay;

