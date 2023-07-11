extends Spatial

onready var portal: StaticBody = get_node("Portal")

onready var exit: Position3D = get_node("Portal/Position3D")
var exit_environment: Environment

var interactor: Spatial
onready var dungeon = get_node_or_null("Dungeon")

# The portal this door is connected to
var other_portal: Spatial

var is_overworld_portal := false

func interact(_interactor: Spatial):
	interactor = _interactor
	if dungeon != null:
		if !dungeon.is_connected("generation_complete", self, "_on_dungeon_generated"):
			var _a: int = dungeon.connect("generation_complete", self, "_on_dungeon_generated")
		dungeon.add_dungeon_to_world()

	elif other_portal.is_overworld_portal == true:
		interactor.global_transform.origin = other_portal.exit.global_transform.origin
		interactor.rotation.y = other_portal.exit.rotation.y



func _on_dungeon_generated(exit_node: Spatial):
	exit_node.other_portal = self
	other_portal = exit_node

	interactor.global_transform.origin = other_portal.exit.global_transform.origin
	interactor.rotation.y = other_portal.exit.rotation.y
	GameEvents.emit_signal("player_entered_dungeon", interactor, dungeon)
