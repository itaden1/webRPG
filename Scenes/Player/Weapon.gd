extends Spatial


var drawn: bool = false
var attacking: bool = false
var collided: bool = false
onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
onready var weapon_area: Area = get_node("Sword")
onready var weapon_sound: AudioStreamPlayer3D = get_node("SwordAudioStreamPlayer3D")
onready var impact_sound: AudioStreamPlayer3D = get_node("ImpactAudioStreamPlayer3D")

func _ready():
	visible = drawn
	var _a: int = animation_player.connect("animation_finished", self, "_on_animation_finished")
	var _w: int = weapon_area.connect("body_entered", self, "_on_weapon_hit_body")


func _input(event):
	if event.is_action_pressed("DrawSheathWeapon"):
		if !animation_player.is_playing():
			drawn = ! drawn
			weapon_sound.play()
			visible = drawn

	if drawn:
		if event.is_action_pressed("Attack"):
			if !animation_player.is_playing():
				attacking = true
				animation_player.play("SwingSword")

func _on_animation_finished(animation_name: String):
	match animation_name:
		"SwingSword": 
			attacking = false
			collided = false
		_: return

func _on_weapon_hit_body(body: KinematicBody):
	if body and body.has_method("do_damage") and attacking == true and !collided:
		body.do_damage(20)
		impact_sound.play()
		collided = true
