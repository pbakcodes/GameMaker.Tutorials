// Player states
enum PLAYER_STATE { IDLE, RUNNING, JUMPING, DEAD }
state = PLAYER_STATE.IDLE;

// Movement constants
gravity_strength = 0.4;
move_speed = 3;
jump_strength = -7;

// Jump feel
coyote_time = 0;
coyote_max = 5; // frames of grace period after leaving a ledge

xsp = 0;
ysp = 0;

