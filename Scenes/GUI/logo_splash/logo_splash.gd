extends CanvasLayer

export var next_scene : PackedScene
export var can_skip : bool = true

func _ready():
	if not next_scene:
		push_error("Please make sure to configure a scene to run ater the splash screen")
		get_tree().quit(3)

func _input(event: InputEvent):
	if not can_skip:
		 return
	if event.is_action_pressed("ui_accept"):
		switch_scene()

func switch_scene() -> void:
	var _n = get_tree().change_scene_to(next_scene)
