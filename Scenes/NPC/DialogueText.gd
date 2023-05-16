extends Label3D

var text_display_timer: Timer = Timer.new()
var timeout_time = 10


func _ready():
	text_display_timer.wait_time = timeout_time
	text_display_timer.one_shot = true
	add_child(text_display_timer)
	var _t: int = text_display_timer.connect("timeout", self, "_on_dialogue_timeout")
	var _d: int = GameEvents.connect("npc_emitted_dialogue", self, "_display_dialogue")

func _display_dialogue(npc: Node, dialogue_text: String):
	if npc != get_parent():
		return
	text_display_timer.wait_time = timeout_time
	text_display_timer.start()
	text = dialogue_text

func _on_dialogue_timeout():
	text = ""
