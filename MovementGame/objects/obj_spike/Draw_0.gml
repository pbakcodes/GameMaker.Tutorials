// Draw a red triangle as a spike
draw_set_color(c_red);
draw_triangle(x - 8, y + 8, x + 8, y + 8, x, y - 8, false);
draw_set_color(c_maroon);
draw_triangle(x - 8, y + 8, x + 8, y + 8, x, y - 8, true);
