extends StateExit
class_name SignalBasedExit

export(String) var node_to_listen_to = ""
export(String) var signal_name = ""
export(String) var data_key = ""
export(String) var threshold_data_key = ""
export(float) var threshold = 5.0

var should_exit = false

var actor : KinematicBody
var node: Node
var data: Dictionary = {}


func _ready():
	pass # Replace with function body.


func set_up(context: StateContext):
	.set_up(context)
	actor = context.actor
	node = actor.get_node_or_null(node_to_listen_to)
	if node == null:
		print("WARNING could not set up exit")

	var _a = node.connect(signal_name, self, "_on_signal_recieved")

func check_condition() -> bool:
	return should_exit

func exit():
	.exit()
	should_exit = false
	if node != null:
		if node.is_connected(signal_name, self, "_on_signal_recieved"):
			node.disconnect(signal_name, self, "_on_signal_recieved")

func _on_signal_recieved(incoming_data: Dictionary):
	if incoming_data.has(threshold_data_key):
		if incoming_data.get(threshold_data_key) > threshold:
			should_exit = true
	data = incoming_data

func set_context():
	if data.has(data_key):
		context.set(set_context_key, data.get(data_key))