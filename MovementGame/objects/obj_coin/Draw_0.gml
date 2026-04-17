bob_offset += 0.1;
var _yoff = sin(bob_offset) * 3;

draw_set_color(c_yellow);
draw_circle(x, y + _yoff, coin_radius, false);
draw_set_color(c_orange);
draw_circle(x, y + _yoff, coin_radius, true);
