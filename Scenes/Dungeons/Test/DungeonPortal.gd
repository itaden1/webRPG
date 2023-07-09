extends Spatial

onready var portal: StaticBody = get_node("Portal")

var exit: Position3D
var exit_environment: Environment

var root_dungeon_node: Node
var dungeon_generator_node: Node

var dungeon: Spatial
var interactor: Spatial

func interact(_interactor: Spatial):
	interactor = _interactor
	add_child(dungeon)
	var _a: int = dungeon.connect("generation_complete", self, "_on_dungeon_generated")
	dungeon.add_dungeon_to_world()

func _on_dungeon_generated(exit_node: Spatial):
	interactor.global_transform.origin = exit_node.global_transform.origin
	interactor.rotation.y = exit_node.rotation.y

	GameEvents.emit_signal("player_entered_dungeon", interactor, dungeon_generator_node)
