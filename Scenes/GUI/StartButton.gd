extends Button

const main_scene = preload("res://Scenes/World.tscn")


func _ready():
	var _c: int = connect("pressed", self, "_on_StartButton_pressed")


func _on_StartButton_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var _c: int  = get_tree().change_scene_to(main_scene)
	GameState.player_fame = 0
	visible = false

