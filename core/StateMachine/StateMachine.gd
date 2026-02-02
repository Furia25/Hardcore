@icon ("res://assets/icons/state_machine.svg")

class_name StateMachine extends Node;

@export var initial_state: State = null;

@onready var state: State = (func get_initial_state() -> State:
	if initial_state:
		return initial_state;
	for child in get_children():
		if child is State:
			return child;
	push_error("No State Found");
	return (null);
).call();

func _ready() -> void:
	for state_node: State in find_children("*", "State", false):
		state_node.finished.connect(_transition_to_next_state);
	await owner.ready;
	state.enter("");

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event);

func _process(delta: float) -> void:
	state.update(delta);

func _physics_process(delta: float) -> void:
	state.physics_update(delta);

func _transition_to_next_state(target_state_path: String, data:= {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.");
		return ;
	var previous_state_path := state.name;
	state.exit();
	state = get_node(target_state_path);
	state.enter(previous_state_path, data);
