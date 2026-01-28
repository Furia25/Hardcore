extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.set_speed(Player.SPEED_TYPE.WALK);

func physics_update(delta: float) -> void:
	if Input.is_action_pressed("run"):
		player.set_speed(Player.SPEED_TYPE.RUN);
	else:
		player.set_speed(Player.SPEED_TYPE.WALK);
	player.apply_movement(delta);
	player.move_and_slide();
	if not player.is_on_floor():
		finished.emit(FALLING);
	elif Input.is_action_pressed("jump"):
		finished.emit(JUMPING);
	elif abs(player.velocity.x) < 0.4 && abs(player.velocity.z) < 0.4:
		finished.emit(IDLE);
