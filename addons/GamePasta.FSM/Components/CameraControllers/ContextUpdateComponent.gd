extends BaseCameraComponent
class_name ContextUpdateComponent

enum conditions {
	RAY_INTERSECTION
}

export (Dictionary) var new_data : Dictionary = {}
export (conditions) var condition = conditions.RAY_INTERSECTION
export (String) var context_target_key: String = "target_actor"
export (String) var context_lock_check_key: String = "lock_camera_pos_updates"


var target: Spatial
var old: bool

func handle_ray_intersection() -> bool:
	var space_state = context.actor.get_world().direct_space_state
	var target_vector = Vector3(
			target.transform.origin.x + offset_vector.x, 
			target.transform.origin.y + offset_vector.y,
			target.transform.origin.z + offset_vector.z 
	)
	
	var result = space_state.intersect_ray(
		target.transform.origin,
		target_vector,
		[target]
	)

	if result.has("collider"):
		var collider = result.collider
		if collider.is_in_group("CameraColliders"):
			return true
		else:
			return false
	return false

func should_update(new: bool) -> bool:
	if context.get(context_lock_check_key) == null or context.get(context_lock_check_key) == false:
		if new != old:
			old = new
			return true
	return false

func physics_process(delta):
	var result: bool = false
	match condition:
		conditions.RAY_INTERSECTION: 
			result = handle_ray_intersection()

	if result and should_update(result):
		context.update(new_data)
	elif !result and should_update(result):
		context.delete_keys(new_data.keys())

func set_up(context: StateContext):
	.set_up(context)
	target = context.get(context_target_key)
