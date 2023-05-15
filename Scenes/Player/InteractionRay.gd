extends RayCast


func _ready():
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed("Interact"):
		var collider = get_collider()
		if collider and collider.has_method("interact"):
			collider.interact(get_parent())
