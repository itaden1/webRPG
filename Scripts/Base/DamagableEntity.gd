extends KinematicBody
var health := 10

func _ready():
	pass # Replace with function body.
	
func do_damage(damage: int):
	GameEvents.emit_signal("npc_emitted_dialogue", self, "Ouch!!")
	health -= damage
	if health <= 0:
		queue_free()
