extends StateComponent
class_name FirstPersonHeadComponent

export(float) var mouse_sensitivity: float = 0.03
export(float) var analogue_sensitivity: float = 7

export(float) var speed: float = 15

var target: Spatial
var target_eyes: Spatial

var parented: bool = false
var original_parent: Node

func input(event):
	if event is InputEventMouseMotion:
		context.actor.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity)) 
		context.actor.rotation.x = clamp(context.actor.rotation.x, deg2rad(-70), deg2rad(70))

func physics_process(delta: float):
	var new_trans = context.actor.global_transform.interpolate_with(target_eyes.global_transform, speed * delta)

	if !parented:
		context.actor.global_transform = new_trans
		if context.actor.global_transform.origin.distance_to(target_eyes.global_transform.origin) < 0.5:
			context.actor.get_parent().remove_child(context.actor)
			target_eyes.add_child(context.actor)
			context.actor.global_transform = target_eyes.global_transform
			parented = true
	else:
		context.actor.global_transform.origin = new_trans.origin
		var look_vec: Vector2 = Input.get_vector("LookLeft", "LookRight", "LookUp", "LookDown")
		context.actor.rotate_x(deg2rad(-look_vec.y * analogue_sensitivity))
		context.actor.rotation.x = clamp(context.actor.rotation.x, deg2rad(-70), deg2rad(70))

func exit():
	if parented:
		var current_transform = context.actor.global_transform
		context.actor.get_parent().remove_child(context.actor)
		original_parent.add_child(context.actor)
		parented = false
		context.actor.global_transform = current_transform

func set_up(context: StateContext):
	.set_up(context)
	target = context.get("target_actor")
	target_eyes = target.get_node("Eyes")
	original_parent = context.actor.get_parent()
