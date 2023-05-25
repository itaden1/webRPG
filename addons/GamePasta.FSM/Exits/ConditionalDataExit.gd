extends StateExit
class_name ConditionalDataExit

enum condition {
	LESS_THAN, GREATER_THAN, EQUAL_TO, LESS_OR_EQUAL, GREATER_OR_EQUAL
}

export(String) var data_key 
export(condition) var cond = condition.EQUAL_TO
export(float) var value = 0


func check_condition() -> bool:
	var val = context.get(data_key)
	if val != null:
		match (cond):
			0: return val < value
			1: return val > value
			2: return val == value
			3: return val <= value
			4: return val >= value
			_: return false
	return false
