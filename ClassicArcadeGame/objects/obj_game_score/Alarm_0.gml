if (global.lives > 0)
{
	// Respawn the player at center of room
	var _p = instance_create_layer(room_width / 2, room_height / 2, "Instances", obj_player);
	_p.speed = 0;
	_p.direction = 0;
	_p.image_angle = 90;
}
else
{
	// Save high score
	if (global.points > global.high_score)
	{
		global.high_score = global.points;
		ini_open("save.ini");
		ini_write_real("score", "high", global.high_score);
		ini_close();
	}
	// Game over — reset everything and restart room
	global.points = 0;
	global.lives = 3;
	room_restart();
}