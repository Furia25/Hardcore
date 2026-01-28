extends PlayerState

func physics_update(delta: float) -> void:
	player.velocity = Vector3.ZERO;
	player.apply_gravity(delta);
	player.move_and_slide();

	if not player.is_on_floor():
		finished.emit(FALLING);
	elif Player.get_movement_vector():
		finished.emit(RUNNING);
	elif Input.is_action_just_pressed("jump"):
		finished.emit(JUMPING);
