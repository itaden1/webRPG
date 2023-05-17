extends StaticBody


var exit: Position3D

func _ready():
	pass # Replace with function body.


func interact(interactor: Spatial):
	interactor.global_transform.origin = exit.global_transform.origin
