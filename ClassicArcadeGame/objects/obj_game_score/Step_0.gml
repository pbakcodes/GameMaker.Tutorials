// Screen shake decay
if (shake_amount > 0)
{
	shake_amount -= shake_decay;
	if (shake_amount < 0)
		shake_amount = 0;

	var _cam = view_camera[0];
	var _cx = camera_get_view_x(_cam);
	var _cy = camera_get_view_y(_cam);
	camera_set_view_pos(_cam, _cx + random_range(-shake_amount, shake_amount), _cy + random_range(-shake_amount, shake_amount));
}
