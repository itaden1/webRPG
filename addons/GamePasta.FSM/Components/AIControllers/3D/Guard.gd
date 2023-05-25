extends StateComponent
class_name Guard

export(Array) var targets: Array
export(float)var change_time = 3
export(float) var turn_speed = 5
export(String) var lookat_points_key

var _targets := []
var timer = Timer.new()
var target_index := 0
var current_target: Vector3

func _ready():
	timer.wait_time = change_time
	timer.connect("timeout", self, "change_target")
	add_child(timer)


func change_target() -> void:
	target_index += 1
	if target_index >= _targets.size():
		target_index = 0

	current_target = _targets[target_index]

func physics_process(delta: float):
	apply_rotation(delta)


func apply_rotation(delta: float):
	var rotation_y = context.actor.rotation.y
	var angle_to_target: float = get_angle_to_target(current_target)
	var lerped_rotation = lerp_angle(rotation_y, angle_to_target, turn_speed * delta)
	context.actor.rotation = Vector3(0, lerped_rotation, 0)
			

func get_angle_to_target(target: Vector3) -> float:
	var direction = context.actor.global_transform.origin.direction_to(target)
	direction.y = 0
	var angle = Vector3.FORWARD.angle_to(direction)
	if target > context.actor.transform.origin:
		angle = - angle
	return angle
				

func set_up(context: StateContext) -> void:
	.set_up(context)
	if targets.size() <= 0:
		_targets = context.get(lookat_points_key)
	else:
		_targets = []
		for t in targets:
			_targets.append(context.actor.global_transform.origin + t)
	change_target()
	timer.wait_time = change_time
	timer.start()
	
