extends StateExit
class_name FOVExit

export(float) var field_of_view = 0.5
export(String) var group_to_check

var nodes_of_interest: Array = []
var actor: KinematicBody
var last_known_location = null

func check_condition() -> bool:
	for i in nodes_of_interest:
		last_known_location = i.global_transform.origin
		var direction = actor.transform.origin.direction_to(i.global_transform.origin)
		if direction.dot(-actor.transform.basis.z) > field_of_view:
			return true
	return false


func set_context():
	if last_known_location != null:
		context.set(set_context_key, last_known_location)


func set_up(context: StateContext):
	.set_up(context)
	actor = context.actor
	nodes_of_interest = get_tree().get_nodes_in_group(group_to_check)

