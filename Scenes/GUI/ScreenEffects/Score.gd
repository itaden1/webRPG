extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	GameEvents.connect("player_died", self, "_set_score")
	
func _set_score():
	text = str(GameState.player_fame)
