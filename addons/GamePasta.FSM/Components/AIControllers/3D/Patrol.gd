# extends StateComponent
extends PathFindingBase
class_name Patrol

export(String) var patrol_points_key

var targets: Array
var target_index := 0

func get_next_target_position():
	target_index += 1
	if target_index >= targets.size():
		target_index = 0

	navigation_agent.set_target_location(targets[target_index])
	if !navigation_agent.is_target_reachable():
		find_backup_position()
	
func set_up(context: StateContext) -> void:
	.set_up(context)
	targets = context.get(patrol_points_key)
	get_next_target_position()
