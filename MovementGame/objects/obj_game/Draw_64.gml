// Coin icon + count
draw_set_color(c_yellow);
draw_circle(16, 16, 6, false);
draw_set_color(c_orange);
draw_circle(16, 16, 6, true);
draw_set_color(c_white);
draw_text(28, 10, "x " + string(coins));

// Deaths
draw_set_color(c_red);
draw_triangle(16, 40, 8, 52, 24, 52, false);
draw_set_color(c_white);
draw_text(28, 38, "x " + string(deaths));
