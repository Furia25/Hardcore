extends CharacterBody3D

var speed;

@export_category("Movement")
@export var walk_speed = 5.0;
@export var run_speed = 5.0; 
@export var accel = 0.5;
@export var jump_velocity = 4.5;

const SENSITIVITY = 0.004;

@onready var head = $Head;
@onready var camera = $Head/Camera;

var gravity = 9.8;

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseMotion:
		return ;
	head.rotate_y(-event.relative.x * SENSITIVITY);
	camera.rotate_x(-event.relative.y * SENSITIVITY);
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60));

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta;
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity;
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
	var direction = ($Head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized();

	speed = walk_speed;

	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed;
			velocity.z = direction.z * speed;
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	move_and_slide();
