// Use globals so state survives room_restart()
if (!variable_global_exists("lives"))
	global.lives = 3;

if (!variable_global_exists("points"))
	global.points = 0;

if (!variable_global_exists("high_score"))
{
	global.high_score = 0;
	if (file_exists("save.ini"))
	{
		ini_open("save.ini");
		global.high_score = ini_read_real("score", "high", 0);
		ini_close();
	}
}

restart_delay = 120; // 2 seconds at 60fps
max_rocks = 12;

// Screen shake
shake_amount = 0;
shake_decay = 0.3;