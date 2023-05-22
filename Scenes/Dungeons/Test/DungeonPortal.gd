extends Spatial

var exit: Position3D
var exit_environment: Environment

func interact(interactor: Spatial):
	interactor.global_transform.origin = exit.global_transform.origin
	interactor.rotation.y = exit.rotation.y
	get_tree().root.get_node("World/WorldEnvironment").environment = exit_environment
