extends Spatial

var exit: Position3D
var exit_environment: Environment

onready var root_dungeon_node = get_parent().get_parent()

func interact(interactor: Spatial):
	interactor.global_transform.origin = exit.global_transform.origin
	interactor.rotation.y = exit.rotation.y
	get_tree().root.get_node("World/WorldEnvironment").environment = exit_environment
	
	if root_dungeon_node.has_method("bake_navigation_mesh"):
		root_dungeon_node.navmesh = NavigationMesh.new()
		root_dungeon_node.bake_navigation_mesh(false)
		GameEvents.emit_signal("player_entered_dungeon", interactor)
