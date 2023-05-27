extends BoneAttachment

var attacking: bool = false
var collided: bool = false
export(NodePath) onready var animation_player = get_node(animation_player)

onready var owner_entity = get_parent().get_parent()
onready var weapon_area: Area = get_node("Weapon")


func _ready():
	var _w: int = weapon_area.connect("body_entered", self, "_on_weapon_hit_body")
	var _a: int = animation_player.connect("animation_finished", self, "_on_animation_finished")
	var _b: int = animation_player.connect("animation_started", self, "_on_animation_started")

func _on_animation_started(animation_name: String):
	match animation_name:
		"Attack":
			attacking = true
			collided = false
		_: return

func _on_animation_finished(animation_name: String):
	match animation_name:
		"Attack": 
			attacking = false
		_: return

func _on_weapon_hit_body(body: KinematicBody):
	if body == owner_entity:
		return
	if body and body.has_method("do_damage") and attacking:# == true and !collided:
		body.do_damage(20)
		collided = true


func toggle_weapon_collisions(state: bool):
	get_children()[0].monitoring = state
