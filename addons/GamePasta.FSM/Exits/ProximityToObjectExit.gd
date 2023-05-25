extends ProximityExitBase
class_name ProximityToObjectExit

var nodes_of_interest: Array = []
var node_locations_map: Dictionary = {}

func get_locations():
	var locations = []
	for n in nodes_of_interest:
		locations.append(n.global_transform.origin)
		node_locations_map[n.global_transform.origin] = n
	return locations

func set_up(context: StateContext) -> void:
	.set_up(context)
	nodes_of_interest = get_tree().get_nodes_in_group(group_to_check)
