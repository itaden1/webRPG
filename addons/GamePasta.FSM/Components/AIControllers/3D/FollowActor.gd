extends PathFindingBase
class_name FollowActor

export(String) var target_key
export(String) var last_known_location_key = "last_known_position"

var actor_to_follow: PhysicsBody

func get_next_target_position():
	if actor_to_follow != null:
		navigation_agent.set_target_location(actor_to_follow.transform.origin)
		print(actor_to_follow.global_transform.origin)
		yield(get_tree(), "idle_frame")
		if !navigation_agent.is_target_reachable():
			find_backup_position()

func set_up(context: StateContext):
	.set_up(context)
	actor_to_follow = context.get(target_key)
	get_next_target_position()

	timer.start()

func set_context():
	context.set(last_known_location_key, actor_to_follow.global_transform.origin)
