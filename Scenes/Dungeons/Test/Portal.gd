extends StaticBody


onready var parent = get_parent()

func interact(interactor: Spatial):
	"""
	delegate interaction logic to parent node
	
	"""
	parent.interact(interactor)
