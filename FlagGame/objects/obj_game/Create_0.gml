// Prevent duplicate persistent instances
if (instance_number(obj_game) > 1)
{
	instance_destroy();
	exit;
}

window_set_size(1280, 720);
deaths = 0;
