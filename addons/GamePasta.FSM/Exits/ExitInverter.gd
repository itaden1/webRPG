extends StateExit
class_name ExitInverter

var children = []

func set_up(context: StateContext):
	.set_up(context)
	children = get_children()
	for c in children:
		c.set_up(context)

func check_condition() -> bool:
	for e in children:
		if e.has_method("check_condition"):
			return not e.check_condition()
	return false
