extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("pressed", self, "_on_button_pressed")


func _on_button_pressed():
	get_tree().change_scene("res://Scenes/GUI/TitleScreen.tscn")
