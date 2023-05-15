extends KinematicBody


func _ready():
	pass # Replace with function body.


func interact(player: KinematicBody):
	look_at(
		Vector3(player.global_transform.origin.x, 0, player.global_transform.origin.z), Vector3.UP)
	rotation.x = 0
	rotation.z = 0
	print("Hello there")
