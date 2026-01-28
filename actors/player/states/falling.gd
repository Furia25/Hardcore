extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.set_speed(Player.SPEED_TYPE.AIR);

func physics_update(delta: float) -> void:
	player.apply_gravity(delta);
	player.apply_movement(delta);
	player.move_and_slide();

	if player.is_on_floor():
		if Player.get_movement_vector():
			finished.emit(RUNNING);
		else:
			finished.emit(IDLE);
