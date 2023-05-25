extends Node
class_name FiniteStateMachine

export(bool) var DEBUG = false
export(Resource) var signaler = preload("Signalers/DefaultSignaler.tres")

export(Array, NodePath) var state_node_paths = []

var state_nodes: Array = []

var state = null # State cannot type this correctly due to circular dependency :( 
var state_history = []

var state_context: StateContext
var started = false

func get_state_nodes() -> Array:
	var state_instances = []
	if state_node_paths.size() > 0:
		for s in state_node_paths:
			state_instances.append(get_node(s))
	else:
		for i in get_children():
			if i is State:
				state_instances.append(i)
	return state_instances


func _ready():
	state_nodes = get_state_nodes()
	state_context = StateContext.new(
		get_parent(),
		self,
		{}
	)
	if state_nodes.size() > 0:
		state = state_nodes[0]

	else:
		push_error("No states configured")
		get_tree().quit()
	if DEBUG == true:
		print(state_nodes.size(), " states configured")

func start() -> void:
	started = true
	enter_state()
	
func set_context(data: Dictionary) -> void:
	state_context.update(data)


func enter_state():
	if DEBUG == true:
		print(get_parent(), " entering state: ", state.name)
	state.FSM = self
	state.enter(state_context)
	signaler.emit_signal("entered_state", self, state.name)


func change_state_by_name(name: String, additional_data: Dictionary):
	if state.name == name:
		return

	state_context.update(additional_data)

	for s in state_nodes:
		if s.name == name:
			change_to_state_node(s)

func change_to_state_node(s):
	if s.can_enter:
		state_history.push_back(state)
		state.exit()
		signaler.emit_signal("exited_state", self, state.name)
		state = s
		enter_state()
	else:
		pass

func _process(delta):
	if state and started:
		state.process(delta)

func _physics_process(delta):
	if state and started:
		state.check_exits()
		
		state.physics_process(delta)


func _input(event):
	if state and started:
		state.input(event)


func _unhandled_input(event):
	if state and started:
		state.unhandled_input(event)


func _unhandled_key_input(event):
	if state and started:
		state.unhandled_key_input(event)
		

#func _notification(what):
#	if state && state.has_method("notification"):
#		state.notification(what)
