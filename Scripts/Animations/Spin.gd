extends Node

onready var object = get_parent()
enum rotation_axis {
	x, y, z
}

export(float) var rotation_speed := 1.0
export(rotation_axis) var axis = rotation_axis.y

func _physics_process(delta):
	if axis == rotation_axis.y:
		object.rotation.y = object.rotation.y + rotation_speed * delta
	elif axis == rotation_axis.x:
		object.rotation.x = object.rotation.x + rotation_speed * delta
	elif axis == rotation_axis.z:
		object.rotation.z = object.rotation.z + rotation_speed * delta
