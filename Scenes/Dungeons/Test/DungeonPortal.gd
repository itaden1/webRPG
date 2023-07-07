extends Spatial

var exit: Position3D
var exit_environment: Environment

var root_dungeon_node: Node
var dungeon_generator_node: Node

func interact(interactor: Spatial):
	if root_dungeon_node.has_method("bake_navigation_mesh"):
		dungeon_generator_node.add_dungeon_to_world()
		root_dungeon_node.navmesh = NavigationMesh.new()
		root_dungeon_node.bake_navigation_mesh(false)

	else:
		dungeon_generator_node.remove_dungeon()

	interactor.global_transform.origin = exit.global_transform.origin
	interactor.rotation.y = exit.rotation.y
	#get_tree().root.get_node("World/WorldEnvironment").environment = exit_environment
	GameEvents.emit_signal("player_entered_dungeon", interactor, dungeon_generator_node)
