extends LineEdit


func _ready():
	var _c: int = connect("text_changed", self, "_on_seed_changed")


func _on_seed_changed(text: String):
	Rng.set_seed(text)
