class_name Player extends CharacterBody3D

enum SPEED_TYPE {WALK, RUN, AIR};

const MAX_CAMERA_PITCH = 80;
const SENSITIVITY = 0.004;

@export_group("Movement")
@export var max_speed : float = 6.;
@export var walk_speed_ratio : float = 1.0;
@export var run_speed_ratio : float = 1.25;
@export var walk_accel : float = 10;
@export var walk_deccel : float = 15;
@export var air_accel : float = 6;
@export var air_deccel : float = 2;
@export var jump_velocity : float = 3.5;

@export_group("Headbob")
@export var headbob_frequency := 2.0;
@export var headbob_amplitude := 0.04;

var deccel : float = walk_deccel;
var accel : float = walk_accel;
var speed : float = 0;
var actual_max_speed : float = 0;

var headbob_time := 0.0;

@onready var head = $Head;
@onready var camera = $Head/Camera;

const gravity : float = 9.8;

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_game_end"):
		get_tree().quit();
	if event.is_action_pressed("debug_game_restart"):
		get_tree().reload_current_scene();

static func get_movement_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backward");

func get_direction() -> Vector3:
	var input_vector = Player.get_movement_vector();
	return (head.transform.basis * transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized();

# Handle Mouse Movement
func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseMotion:
		return ;
	head.rotate_y(-event.relative.x * SENSITIVITY);
	camera.rotate_x(-event.relative.y * SENSITIVITY);
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-MAX_CAMERA_PITCH), deg_to_rad(MAX_CAMERA_PITCH));

func set_speed(type : SPEED_TYPE) -> void:
	actual_max_speed = max_speed * walk_speed_ratio;
	match type:
		SPEED_TYPE.RUN:
			accel = walk_accel * run_speed_ratio;
			deccel = walk_deccel * walk_speed_ratio;
			actual_max_speed = max_speed * run_speed_ratio;
		SPEED_TYPE.AIR:
			accel = air_accel;
			deccel = air_deccel;
		_:
			accel = walk_accel * walk_speed_ratio;
			deccel = walk_deccel * walk_speed_ratio;

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta;

func _physics_process(delta: float) -> void:
	print("Speed : %f" % velocity.length())

func apply_movement(delta: float, acceleration: bool = true) -> void:
	var direction = get_direction();
	if direction and acceleration:
		speed = lerp(speed, actual_max_speed, accel * delta);
		velocity.x = direction.x * speed;
		velocity.z = direction.z * speed;
	else:
		speed = lerp(speed, 0., deccel * delta);
		velocity.x = lerp(velocity.x, 0., deccel * delta);
		velocity.z = lerp(velocity.z, 0., deccel * delta);
	headbob_time += delta * velocity.length() * float(is_on_floor());
	camera.transform.origin = headbob(headbob_time);

func headbob(headbob_time) -> Vector3:
	var headbob_position = Vector3.ZERO;
	headbob_position.y = sin(headbob_time * headbob_frequency) * headbob_amplitude;
	headbob_position.x = cos(headbob_time * headbob_frequency / 2) * headbob_amplitude;
	return headbob_position;
