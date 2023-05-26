extends StateComponent
class_name PlayAnimationComponent


export(NodePath) onready var animation_player = get_node(animation_player)
export(String) var animation_name = "idle"

func set_up(context: StateContext):
	.set_up(context)
	animation_player.play(animation_name)

