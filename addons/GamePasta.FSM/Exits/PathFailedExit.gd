extends StateExit
class_name PathFailedExit

# a simple exit that checks if the navigation agent can reach its target and if not
# change to another state


var navigation_agent: NavigationAgent
var actor : KinematicBody

func check_condition() -> bool:
	if !navigation_agent.is_target_reachable():
		return true

	return false

func set_up(context: StateContext) -> void:
	.set_up(context)
	actor = context.actor
	navigation_agent = context.actor.get_node("NavigationAgent")
