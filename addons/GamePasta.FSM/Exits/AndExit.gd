extends StateExit
class_name AndExit

export(int) var threshold = 0
var children = []

func set_up(context: StateContext):
	.set_up(context)
	children = get_children()
	for c in children:
		c.set_up(context)

func check_condition() -> bool:
	var accumulated = 0
	for e in children:
		if e.has_method("check_condition"):
			if e.check_condition() == true:
				accumulated += 1
			elif threshold == 0:
					return false
	if accumulated >= threshold:
		return true
	return false

func set_context():
	for c in children:
		if c.has_method("set_context"):
			c.set_context()
