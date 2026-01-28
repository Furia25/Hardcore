class_name PlayerState extends State

const IDLE = "Idle";
const RUNNING = "Running";
const JUMPING = "Jumping";
const FALLING = "Falling";

var player: Player;
var head: Node3D;

func _ready() -> void:
	await owner.ready;
	player = owner as Player;
	head = owner.head;
