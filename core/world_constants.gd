extends Node

@export_category("Day night cycle")
var time_of_day : float = 0.0;
@export var time_of_day_speed : float = 0.08;
@export var time_full_night : float = 2.0;
@export var time_full_day : float = 2.0;

signal day_started;
signal night_started;

@onready var day_night_cycle_timer : Timer = $DayNightCycleTimer;
var time_of_day_direction : float = 1.0;

func force_day() -> void:
	day_started.emit();

func force_night() -> void:
	night_started.emit();

func day_night_cycle(delta: float) -> void:
	if !day_night_cycle_timer.is_stopped():
		return ;
	time_of_day += delta * time_of_day_speed * time_of_day_direction;
	if time_of_day > 1.0:
		night_started.emit();
	elif time_of_day < 0.0:
		day_started.emit();

func _process(delta: float) -> void:
	day_night_cycle(delta);

func _on_day_started() -> void:
	time_of_day = 0.0;
	time_of_day_direction = 1.0;
	day_night_cycle_timer.start(time_full_day);

func _on_night_started() -> void:
	time_of_day = 1.0;
	time_of_day_direction = -1.0;
	day_night_cycle_timer.start(time_full_night);
