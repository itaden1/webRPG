extends StateComponent
class_name TakeAction

enum press_states {
	HOLD, PRESS, RELEASE
}

export(String) var action_key
export(String) var action_name

export(press_states) var pressed_state = press_states.PRESS


func physics_process(delta: float):
	handle_input()

func handle_input():
	if pressed_state == press_states.HOLD and Input.is_action_pressed(action_key):
		take_action()
	if pressed_state == press_states.RELEASE and Input.is_action_just_released(action_key):
		take_action()
	if pressed_state == press_states.PRESS and Input.is_action_just_pressed(action_key):
		take_action()
	
func take_action():
	context.FSM.signaler.emit_signal(
		"state_sent_action", context.FSM, context.FSM.state.name, "Attack")
