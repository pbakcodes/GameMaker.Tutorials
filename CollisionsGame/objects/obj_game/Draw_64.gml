// Gem icon + count
draw_set_color(c_yellow);
draw_circle(16, 16, 6, false);
draw_set_color(c_white);
draw_circle(16, 16, 6, true);
draw_text(28, 10, "x " + string(collected) + " collected");
