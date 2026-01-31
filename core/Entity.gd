class_name Entity extends Node

var components : Array[Component] = [];

func emit_event(event : String, ...args) -> void:
	for component in components:
		if component.has_method(event):
			component.callv(event, args);

func add_component()
