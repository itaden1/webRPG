extends Spatial

var exit: Position3D

func interact(interactor: Spatial):
	interactor.global_transform.origin = exit.global_transform.origin
	interactor.rotation.y = exit.rotation.y
