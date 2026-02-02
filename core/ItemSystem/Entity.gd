class_name Entity extends Node

@export var components : Array[Component] = [];

func add_component(component: Component):
	components.append(component);

func remove_component(type: Component.Type):
	for index in range(components.size() - 1, -1, -1):
		if components[index].TYPE_ID() == type:
			components.remove_at(index);
			return

func remove_component_uuid(uuid : String):
	for index in range(components.size() - 1, -1, -1):
		if components[index].get_uuid() == uuid:
			components.remove_at(index);
			return

func clear_components():
	components = [];
