extends KinematicBody


var health := 100

func _ready():
	var fsm = get_node("FiniteStateMachine")
	fsm.set_context({
		"player": get_tree().get_nodes_in_group("Player")[0],
		"navigation": get_parent().navigation_node})
	fsm.start()


func do_damage(damage: int):
	health -= damage
	if health <= 0:
		GameEvents.emit_signal("enemy_slain")
		queue_free()
