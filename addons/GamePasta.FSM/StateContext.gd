extends Reference
class_name StateContext

var FSM
var actor: Spatial

var data: Dictionary = {}
var events: Array = []


func _init(actor: Spatial, fsm, initial_data: Dictionary):
	self.actor = actor
	self.FSM = fsm
	self.update(initial_data)

func get(key):
	if data.has(key):
		return data[key]
	return null

func has_key(key):
	return data.has(key)

func set(key, value):
	data[key] = value

func clear():
	data = {}

func delete_keys(keys: Array):
	for k in keys:
		if data.has(k):
			data.erase(k)

func update(new_data: Dictionary):
	for k in new_data.keys():
		data[k] = new_data[k]
