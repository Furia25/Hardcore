extends RefCounted

enum EventType
{
	INVENTORY_CHANGED
}

var queue := [];

func emit(event_type: EventType, ...argv):
	queue.append([event_type, argv]);

func pop_all() -> Array:
	var events = queue;
	queue = [];
	return events;
