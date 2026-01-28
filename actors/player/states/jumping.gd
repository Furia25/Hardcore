extends PlayerState

func physics_update(delta: float) -> void:
	player.velocity.y = player.jump_velocity;
	player.move_and_slide();
	finished.emit(FALLING);
