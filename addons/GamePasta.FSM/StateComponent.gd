extends Node
class_name StateComponent, "Icons/puzzle_icon.png"


#var actor: KinematicBody
var context: StateContext

# determines whether the state is active or not
var active = false 

func set_context():
	pass

func exit():
	set_context()
	active = false

func set_up(context: StateContext):
	self.context = context
	active = true
