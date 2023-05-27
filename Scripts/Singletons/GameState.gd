extends Node

var player_fame: int = 0


func _ready():
	GameEvents.connect("enemy_slain", self, "set_player_fame")

func set_player_fame():
	player_fame += 1
