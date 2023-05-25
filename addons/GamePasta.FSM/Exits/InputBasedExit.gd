extends StateExit
class_name InputBasedExit

enum press_states {
	HOLD, PRESS, RELEASE, PRESS_AND_RELEASE
}

export(String) var input_name = "ToggleCombat"
export(press_states) var pressed_state = press_states.PRESS

# The time a button must be held for for press_state.HOLD to be true
# for press and release to be true it must be released in under the wait time
export(float) var hold_time: float = 0.0

var hold_timer : Timer = Timer.new()
var hold_exit: bool = false

func _ready():
	add_child(hold_timer)
	hold_timer.connect("timeout", self, "_on_hold_timer_timeout")

func check_condition() -> bool:

	if pressed_state == press_states.HOLD:
		if Input.is_action_pressed(input_name):
			if hold_time <= 0.0:
				return true

			elif hold_timer.is_stopped():
				if hold_time > 0.0:
					hold_timer.wait_time = hold_time

				hold_timer.start()

			return hold_exit

		if Input.is_action_just_released(input_name):
			hold_timer.stop()
			hold_exit = false
			


	if pressed_state == press_states.RELEASE and Input.is_action_just_released(input_name):
		return true

	if pressed_state == press_states.PRESS and Input.is_action_just_pressed(input_name):
		return true

	if pressed_state == press_states.PRESS_AND_RELEASE:
		if Input.is_action_just_pressed(input_name):
			if hold_timer.is_stopped():
				if hold_time > 0:
					hold_timer.wait_time = hold_time
					hold_timer.start()

			hold_exit = true

		if Input.is_action_just_released(input_name):
			return hold_exit


	return false

func _on_hold_timer_timeout():

	if pressed_state == press_states.PRESS_AND_RELEASE:
		hold_exit = false

	else:
		hold_exit = true
	hold_timer.stop()

func set_up(state_context: StateContext):
	.set_up(state_context)
	hold_exit = false

