extends StateComponent
class_name LookAtActor

var actor_to_follow: Spatial
export(String) var target_key
export(float) var turn_speed

# if true the rotation to face target will ignore the y axis
export(bool) var limit_y := false

# Randomized offset: entity will not always directly face the target 
# but add a randomoffset between 0 and this setting to the lookat vector
export(float) var randomized_offset: float = 0.0

# Randomize offset time: timer to update the aim offset
export(float) var randomize_offset_time: float = 0.6
# if true accuracy increases over time
export(bool) var zero_in := true

# if zero in is true this will be the minimum to allow some randomnes to the aim
export(float) var minimum_offset := 0.5

var rand_offset := 0.0
var angle_to_target := 0.0
var target_offset = Vector3.ZERO

var offset_update_timer: Timer = Timer.new()

func _ready():
	offset_update_timer.connect("timeout", self, "_update_offset")
	offset_update_timer.wait_time = randomize_offset_time
	add_child(offset_update_timer)


func physics_process(delta: float):
	apply_rotation(delta)

func apply_rotation(delta: float):
	var rotation_y = context.actor.rotation.y
	var angle_to_target = get_angle_to_target(actor_to_follow.transform.origin)
	var lerped_rotation = lerp_angle(rotation_y, angle_to_target, turn_speed * delta)
	context.actor.rotation = Vector3(0, lerped_rotation, 0)

func get_angle_to_target(target: Vector3) -> float:

	target = target + target_offset
	var direction = context.actor.global_transform.origin.direction_to(target)
	if limit_y == true:
		direction.y = 0
	var angle = Vector3.FORWARD.angle_to(direction)
	if target > context.actor.transform.origin:
		angle = - angle
	return angle

func _update_offset():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	if zero_in == true:
		if randomized_offset > minimum_offset:
			randomized_offset -= 0.1

	target_offset = Vector3(
		rng.randf_range(-randomized_offset, randomized_offset),
		rng.randf_range(-randomized_offset, randomized_offset),
		rng.randf_range(-randomized_offset, randomized_offset)
	)

func set_up(context: StateContext):
	.set_up(context)
	rand_offset = randomized_offset
	_update_offset()
	offset_update_timer.start()
	actor_to_follow = context.get(target_key)

