extends Node
class_name State, "Icons/single_gear_icon.png"

export(Array, NodePath) var exit_paths = []
export(Array, NodePath) var state_component_paths = []

var components: Array = []
var exits: Array = []

onready var FSM = get_parent() # FiniteStateMachine cyclic reference :(

onready var cooldown_timer: Timer = get_node_or_null("Timer") 
var can_enter := true


var entity: KinematicBody

#var data = {}
var context: StateContext

func _ready():
	# gather configured components
	components = get_node_path_instances(state_component_paths)
	exits = get_node_path_instances(exit_paths)
	setup_timer()
	
	# If no configured components assign children
	if components.size() <= 0:
		for n in get_children():
			n = n as StateComponent
			if n:
				components.append(n)

	# if no configured exits assign children
	if exits.size() <= 0:
		for n in get_children():
			n = n as StateExit
			if n:
				exits.append(n)


func setup_timer():
	if cooldown_timer == null:
		return
	cooldown_timer.connect("timeout", self, "_on_cooldown_timer_timeout")


func _on_cooldown_timer_timeout():
	can_enter = true
	FSM.signaler.emit_signal("state_cooldown_ended", FSM, name)


func get_node_path_instances(node_paths: Array) -> Array:
	var instances: Array = []
	for p in node_paths:
		instances.append(get_node(p))
	return instances


func input(event: InputEvent) -> void:
	for c in components:
		#c.entity = entity
		if c.has_method("input"):
			c.input(event)


func physics_process(delta: float) -> void:
	for c in components:
		#c.entity = entity
		if c.has_method("physics_process"):
			c.physics_process(delta)
	context.events = []

func unhandled_input(event):
	pass


func unhandled_key_input(event):
	pass


func process(delta: float) -> void:
	pass


func enter(context: StateContext):
	self.context = context
	for e in exits:
		e.set_up(context)
	for c in components:
		c.set_up(context)

	if cooldown_timer != null:
		cooldown_timer.start()
		FSM.signaler.emit_signal("state_cooldown_started", FSM, name)
		can_enter = false

func check_exits() -> void:
	for e in exits:
		var should_change: bool = e.check_condition()
		if should_change:
			FSM.change_to_state_node(e.change_to)

func exit():
	for e in exits:
		e.exit()
	for c in components:
		c.exit()
