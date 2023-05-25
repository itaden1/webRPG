extends StateComponent
class_name PathFindingBase

export(String) var navigation_key := "navigation"
export(String) var backup_locations_group_key := "BackupLocations"
export(float) var nav_update_time = 2
export(float) var speed := 10
export(String) var signal_name = "entity_entered_door"

var navigation_agent: NavigationAgent
var velocity: Vector3
onready var backup_locations: Array = [] 
var timer = Timer.new()

var history_pop_timer := Timer.new()

var path_history := [] # keep track of portals the agent has been through so they can retrace steps

func _ready():
	timer.wait_time = nav_update_time
	timer.connect("timeout", self, "get_next_target_position")
	add_child(timer)

	history_pop_timer.wait_time = 4.0
	history_pop_timer.connect("timeout", self, "clear_history")
	add_child(history_pop_timer)
	history_pop_timer.start()
	# connect to any node that wants to signal to this state
	for node in get_tree().get_nodes_in_group("FsmSignaler"):
		if node.has_signal(signal_name):
			node.connect(signal_name, self, "_add_backup_location")

func get_next_target_position():
	navigation_agent.set_target_location(context.actor.global_transform.origin)

func find_backup_position():
	var emergency = 10
	if backup_locations.size() <= 0:
		# what to do when we have no backup locations to search
		var last_waypoint = path_history.pop_front()
		if last_waypoint == null:
			return
		navigation_agent.set_target_location(last_waypoint)
	else:
		while backup_locations.size() > 0:
			var l = backup_locations.pop_front()
			navigation_agent.set_target_location(l)
			if navigation_agent.is_target_reachable():
				path_history.push_front(l)
				print(path_history)
				break
			emergency -= 1
			if emergency <= 0:
				print("!!!!!!!!!!")
				break


func get_next_location():
	if navigation_agent.is_navigation_finished():
		get_next_target_position()
	return navigation_agent.get_next_location()


func physics_process(delta: float):
	var location: Vector3 = context.actor.transform.origin
	var next_location = get_next_location()
	var direction = location.direction_to(next_location)
	navigation_agent.set_velocity(direction * speed)
	context.update({direction=direction})

func _on_velocity_computed(safe_velocity: Vector3):
	var normalized_velocity: Vector3 = safe_velocity.normalized()
	velocity = context.actor.move_and_slide(safe_velocity, Vector3.UP)


func set_up(context: StateContext):
	.set_up(context)
	
	navigation_agent = context.actor.get_node("NavigationAgent")
	navigation_agent.set_navigation(context.get("navigation"))
	if !navigation_agent.is_connected("velocity_computed", self, "_on_velocity_computed"):
		navigation_agent.connect("velocity_computed", self, "_on_velocity_computed")


func exit():
	# make sure to reset the timer otherwise updates will keep happening despite this state being inactive
	timer.stop()
	timer.wait_time = nav_update_time
	if navigation_agent != null:
		if navigation_agent.is_connected("velocity_computed", self, "_on_velocity_computed"):
			# avoid recieving the safe velocity signal twice as this will result in entities moving too fast
			navigation_agent.disconnect("velocity_computed", self, "_on_velocity_computed")


func _add_backup_location(entity: KinematicBody, location: Vector3):
	if not active:
		return
	if entity is Player:
		backup_locations.push_back(location)
	elif entity == context.actor:
		path_history.push_front(location)

func clear_history():
	backup_locations = []
