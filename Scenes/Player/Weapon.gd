extends Spatial


var drawn: bool = false
var attacking: bool = false
onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
onready var weapon_area: Area = get_node("Sword")


func _ready():
	visible = drawn
	var _a: int = animation_player.connect("animation_finished", self, "_on_animation_finished")
	var _w: int = weapon_area.connect("body_entered", self, "_on_weapon_hit_body")


func _input(event):
	if event.is_action_pressed("DrawSheathWeapon"):
		if !animation_player.is_playing():
			drawn = ! drawn
			visible = drawn

	if drawn:
		if event.is_action_pressed("Attack"):
			if !animation_player.is_playing():
				attacking = true
				animation_player.play("SwingSword")

func _on_animation_finished(animation_name: String):
	match animation_name:
		"SwingSword": attacking = false
		_: return

func _on_weapon_hit_body(body: KinematicBody):
	if body and body.has_method("do_damage") and attacking == true:
		body.do_damage(20)
