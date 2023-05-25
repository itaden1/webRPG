extends ProximityExitBase
class_name ProximityToLocationExit

export(String) var location_key

var vectors_of_interest: Array = []

func get_locations():
	return vectors_of_interest

func set_up(context: StateContext) -> void:
	.set_up(context)
	var locations = context.get(location_key)
	if typeof(locations) == TYPE_ARRAY:
		vectors_of_interest = locations
	else:
		vectors_of_interest = [locations]
