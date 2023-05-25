extends StateComponent
class_name FaceDirectionOfTravel

export(float) var turn_speed = 5.0

var direction: Vector3
var angle_of_travel: float = 0

var actors_last_position: Vector3

func physics_process(delta: float):
	var d = context.get("direction")
	if d != null:
		direction = d
	direction = actors_last_position.direction_to(context.actor.global_transform.origin)
	actors_last_position = context.actor.global_transform.origin
	apply_rotation(delta)


func apply_rotation(delta: float):
	var rotation_y = context.actor.rotation.y
	angle_of_travel = get_angle_of_travel(direction)
	var lerped_rotation = lerp_angle(rotation_y, angle_of_travel, turn_speed * delta)
	context.actor.rotation = Vector3(0, lerped_rotation, 0)

func get_angle_of_travel(direction: Vector3) -> float:
	var angle = Vector3.FORWARD.angle_to(direction)
	if direction == Vector3.ZERO:
		return angle_of_travel
	
	elif direction.x > 0:
		angle = -angle
	return angle
