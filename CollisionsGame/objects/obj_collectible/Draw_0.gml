// Bobbing animation
bob_offset += 0.1;
var _yoff = sin(bob_offset) * 4;

// Draw a yellow circle as the collectible
draw_set_color(c_yellow);
draw_circle(x, y + _yoff, collect_radius, false);
draw_set_color(c_white);
draw_circle(x, y + _yoff, collect_radius, true);
