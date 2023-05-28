extends Button

const main_scene = preload("res://Scenes/GUI/Credits.tscn")


func _ready():
	var _c: int = connect("pressed", self, "_on_button_pressed")


func _on_button_pressed():
	var _c: int  = get_tree().change_scene_to(main_scene)
