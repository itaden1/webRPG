extends StateExit
class_name LOSExit

enum conditions {CAN_SEE, CANT_SEE}

export(String) var group_to_check
export(String) var spatial_of_interest
export(int) var size_threshold = 1
export(conditions) var condition = conditions.CAN_SEE
var last_known_location = null

var nodes_of_interest: Array = []
var actor: KinematicBody

func check_condition() -> bool:
	var space_state = context.actor.get_world().direct_space_state
	var nodes_seen: Array = []
	for i in nodes_of_interest:
		last_known_location = i.global_transform.origin
		var cast_to = i.global_transform.origin
		var cast_from = get_cast_point()
		var result = space_state.intersect_ray(
			cast_from,
			cast_to,
			[actor]
		)
		var collider = result.get("collider") as PhysicsBody
		if collider != null:
			if nodes_of_interest.has(collider):

				nodes_seen.append(i)

	var result: bool
	match(condition):
		0: result = nodes_seen.size() >= size_threshold
		1: result = nodes_seen.size() < size_threshold
	return result

func set_context():
	if last_known_location != null:
		context.set(set_context_key, last_known_location)

func get_cast_point() -> Vector3:
	var cast_point = context.get("cast_point_node_name")
	if cast_point == null:
		return actor.global_transform.origin
	return actor.get_node(cast_point).global_transform.origin

func set_up(context: StateContext) -> void:
	.set_up(context)
	nodes_of_interest = get_tree().get_nodes_in_group(group_to_check)
	actor = context.actor
