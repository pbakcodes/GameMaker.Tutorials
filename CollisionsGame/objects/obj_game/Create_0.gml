collected = 0;

// Spawn the first collectible at a spot not inside any wall
var _cx, _cy;
do {
	_cx = irandom_range(240, room_width - 64);
	_cy = irandom_range(64, room_height - 64);
} until (!position_meeting(_cx, _cy, obj_solid));

instance_create_layer(_cx, _cy, "Instances", obj_collectible);
