extends StateExit
class_name EventBasedExit

export (String) var event_name = "entered_state"

func check_condition() -> bool:
	if event_name in context.events:
		return true
	return false

func exit():
	context.events = []
