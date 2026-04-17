// Invulnerability countdown with flash effect
if (invulnerable > 0)
{
	invulnerable--;
	visible = (invulnerable mod 6) < 3;
}
else
{
	visible = true;
}

if (keyboard_check(ord("W")))
	motion_add(image_angle, thrust_power);

if (keyboard_check(ord("A")))
	image_angle += rotation_speed;

if (keyboard_check(ord("D")))
	image_angle -= rotation_speed;

// Fire rate cooldown
if (fire_cooldown > 0)
	fire_cooldown--;

if (keyboard_check_pressed(vk_space) && fire_cooldown <= 0)
{
	var _b = instance_create_layer(x, y, "Instances", obj_bullet);
	_b.direction = image_angle;
	fire_cooldown = fire_rate;
}

move_wrap(true, true, 0);

