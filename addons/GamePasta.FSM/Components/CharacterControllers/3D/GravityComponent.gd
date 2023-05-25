extends StateComponent
class_name GravityComponent


export(float) var gravity = 100
export(String) var ray_node_name = "GroundRay"

var velocity = Vector3.ZERO
var ground_ray: RayCast

func physics_process(delta: float):

	if ground_ray == null:
		return
	if !ground_ray.is_colliding():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
	context.actor.move_and_slide(velocity, Vector3.UP)
	context.set("velocity", velocity)

func set_up(context: StateContext):
	.set_up(context)
	ground_ray = context.actor.get_node_or_null(ray_node_name)
	if ground_ray == null:
		print("!! No ray found for actor! Cannot apply gravity")
