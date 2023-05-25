extends StateComponent
class_name RootMotionComponent

var velocity: Vector3 = Vector3()
var animation_tree : AnimationTree
var direction: Vector3 = Vector3.ZERO

func physics_process(delta):
	var transform = context.actor.transform
	var rmt: Transform = animation_tree.get_root_motion_transform()

	# For some reason the root motion.origin z and y are switched?
	# They are also reversed...
	# Here we set them straight by swapping y and z and inversing all values
	rmt.origin = Vector3(-rmt.origin.x, -rmt.origin.z, -rmt.origin.y)
	velocity = ((transform * rmt).origin - transform.origin) / delta * 1.3
	velocity = context.actor.move_and_slide(velocity, Vector3.UP)

func set_up(context: StateContext):
	.set_up(context)
	velocity = Vector3.ZERO
	animation_tree = context.actor.get_node("AnimationTree")
	direction = context.get("direction")
