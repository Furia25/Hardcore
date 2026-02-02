
class_name Component extends Resource

enum Type
{
	STAT_COMPONENT
};

var uuid : String = UUID.v4();

func get_uuid() -> String:
	return self.uuid;

func get_type() -> Type:
	return self.get("TYPE_ID");
