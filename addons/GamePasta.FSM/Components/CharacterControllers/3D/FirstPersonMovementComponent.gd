extends StateComponent
class_name FirstPersonMovementComponent

export(float) var mouse_sensitivity: float = 0.03
export(float) var analogue_sensitivity: float = 7
export (float) var speed: float = 7
export (float) var acceleration: float = 10

var velocity = Vector3.ZERO


func input(event):
	
	if event is InputEventMouseMotion:
		context.actor.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity)) 


func physics_process(delta):
		
	var direction = Vector3()
		
	if Input.is_action_pressed("DirectionUp"):
	
		direction -= context.actor.transform.basis.z
	
	elif Input.is_action_pressed("DirectionDown"):
		
		direction += context.actor.transform.basis.z
		
	if Input.is_action_pressed("DirectionLeft"):
		
		direction -= context.actor.transform.basis.x			
		
	elif Input.is_action_pressed("DirectionRight"):
		
		direction += context.actor.transform.basis.x
			
	var look_vec: Vector2 = Input.get_vector("LookLeft", "LookRight", "LookUp", "LookDown")
	context.actor.rotate_y(deg2rad(-look_vec.x * analogue_sensitivity)) 



	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta) 
	velocity = context.actor.move_and_slide(velocity, Vector3.UP)
