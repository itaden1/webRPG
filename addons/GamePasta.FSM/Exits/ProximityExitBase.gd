extends StateExit
class_name ProximityExitBase

enum conditions {LESS_OR_EQUAL, GREATER_OR_EQUAL}

export(String) var group_to_check
export(String) var spatial_of_interest
export(float) var distance
export(conditions) var condition = conditions.LESS_OR_EQUAL

var last_known_location = null

var actor: Spatial

func get_locations():
	return []

func check_condition() -> bool:
	for l in get_locations():
		last_known_location = l
		var dist: float = actor.global_transform.origin.distance_to(l)
		match(condition):
			0: if dist <= distance:
				return true
			1: if dist >= distance:
				return true

	return false

func set_context():
	if last_known_location != null:
		context.set(set_context_key, last_known_location)


func set_up(context: StateContext) -> void:
	.set_up(context)
	# nodes_of_interest = get_tree().get_nodes_in_group(group_to_check)
	actor = context.actor
