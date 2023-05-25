extends StateExit
class_name RayCollisionExit

export (String) var ray_group: String
export (String) var collision_group: String
export (bool) var exit_on_no_collisions = false

onready var rays: Array = get_tree().get_nodes_in_group(ray_group)

func check_condition() -> bool:
	var collision_count := 0
	for ray in rays:
		var obj_colliding_with = ray.get_collider()
		if obj_colliding_with != null:
			if obj_colliding_with.is_in_group(collision_group):
				collision_count += 1
	
	if exit_on_no_collisions:
		return collision_count == 0
	return collision_count >= 1

func set_up(context: StateContext) -> void:
	.set_up(context)
