extends AnimationPlayer


var death_timer: Timer = Timer.new()

func _ready():
	var _a: int = GameEvents.connect("player_took_damage", self, "_on_player_took_damage")
	var _b: int = GameEvents.connect("player_died", self, "_on_player_died")

	death_timer.wait_time = 4
	death_timer.one_shot = true
	death_timer.connect("timeout", self, "load_title_screen")
	add_child(death_timer)

func _on_player_took_damage(damage_type: int):
	play("TakeDamageClaw")


func _on_player_died():
	play("Death")
	death_timer.start()


func load_title_screen():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var _success: int = get_tree().change_scene("res://Scenes/GUI/TitleScreen.tscn")
