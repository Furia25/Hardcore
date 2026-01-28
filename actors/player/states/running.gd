extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.accel = player.walk_accel;
	player.deccel = player.walk_deccel;
	player.actual_max_speed = player.max_speed * player.walk_speed_ratio;

func physics_update(delta: float) -> void:
	player.apply_movement(delta);
	player.move_and_slide();
	if not player.is_on_floor():
		finished.emit(FALLING);
	elif Input.is_action_pressed("jump"):
		finished.emit(JUMPING);
	elif abs(player.velocity.x) < 0.4 && abs(player.velocity.z) < 0.4:
		finished.emit(IDLE);
