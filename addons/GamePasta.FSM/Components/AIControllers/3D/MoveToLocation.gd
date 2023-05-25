extends PathFindingBase
class_name MoveToLocation

export(String) var position_key

var position_to_move_to: Vector3

func get_next_target_position():
	navigation_agent.set_target_location(position_to_move_to)
	if !navigation_agent.is_target_reachable():
		find_backup_position()

func set_up(context: StateContext):
	.set_up(context)
	position_to_move_to = context.get(position_key)
	get_next_target_position()

	timer.start()
