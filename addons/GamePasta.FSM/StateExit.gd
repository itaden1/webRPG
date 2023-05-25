extends Node
class_name StateExit, "Icons/exit_icon.png"

onready var _is_ready := true
export(bool) var return_to_previous_state = false
export(NodePath) onready var change_to_path setget set_next_state
export(String) var set_context_key

var change_to setget , get_next_state

var context: StateContext

func check_condition() -> bool:
	return false

func set_next_state(value):
	# set get fires before ready
	# https://github.com/godotengine/godot-proposals/issues/325
	if not _is_ready:
		yield(self, "ready")

	if value != null or value != '':
		if value is NodePath:
			change_to = get_node(value)
	else:
		change_to = get_parent()

func get_next_state():
	if return_to_previous_state == true:
		var state_history = get_parent().FSM.state_history
		if state_history.size() > 0:
			return state_history.pop_back()
	return change_to

func set_up(context: StateContext):
	self.context = context

func set_context():
	pass

func exit():
	set_context()
	pass
