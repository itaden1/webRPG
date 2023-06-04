extends KinematicBody
class_name Player
#Variables
var global = "root/global"

onready var vocal_sound_player = get_node("AudioStreamPlayer3D")
var weapon_drawn: bool setget , _get_is_weapon_drawn 

const GRAVITY =-32.8
var vel = Vector3()
const MAX_SPEED = 520
const JUMP_SPEED = 28
const ACCEL = 8.5

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.09

const MAX_SPRINT_SPEED = 20
const SPRINT_ACCEL = 18
var is_sprinting = false

var flashlight
var dead = false

var health := 100

func _ready():
	camera = $rotation_helper/Camera
	rotation_helper = $rotation_helper
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)

func process_input(delta):

	# ----------------------------------
	# Walking
	dir = Vector3()
	#var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_key_pressed(KEY_W):
		input_movement_vector.y -= 1
	if Input.is_key_pressed(KEY_S):
		input_movement_vector.y += 1
	if Input.is_key_pressed(KEY_A):
		input_movement_vector.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	#dir += cam_xform.basis.z.normalized() * input_movement_vector.y
	#dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	dir += global_transform.basis.z.normalized() * input_movement_vector.y
	dir += global_transform.basis.x.normalized() * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
#	if is_on_floor():
	if Input.is_key_pressed(KEY_SPACE):
		vel.y = JUMP_SPEED
	# ----------------------------------



func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3.UP, true, 4, deg2rad(MAX_SLOPE_ANGLE))

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(-event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -80, 80)
		rotation_helper.rotation_degrees = camera_rot
	# ----------------------------------
	# Capturing/Freeing the cursor
	if event.is_action_pressed("ToggleMouse"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------

func _get_is_weapon_drawn():
	return get_node("%Weapon").drawn

func do_damage(damage: int):
	health -= damage
	GameEvents.emit_signal("player_took_damage", 1)
	vocal_sound_player.play()
	if health <= 0:
		if !dead:
			GameEvents.emit_signal("player_died")
			dead = true
