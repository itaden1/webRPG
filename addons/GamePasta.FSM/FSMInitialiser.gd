extends Node
class_name FSMInitialiser

func _ready():
	var _a = GameEvents.connect("player_spawned", self, "set_up_fsm")


func set_up_fsm(player: Player):
	var fsm = get_parent()
	fsm.set_context({
		target_actor=player,
	})

	fsm.start()