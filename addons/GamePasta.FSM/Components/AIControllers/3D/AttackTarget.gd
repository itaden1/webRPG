extends StateComponent
class_name AttackTarget

export(float) var initial_wait_time := 2.0
export(float) var cooldown_time := 0.5
export(float) var rand_cooldown_time := 0.0

var has_setup := false
var timer = Timer.new()

func _ready():
	# timer.wait_time = cooldown_time + rand_range(0, rand_cooldown_time)
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)

func _on_timer_timeout():
	if has_setup:
		attack()
		timer.wait_time = cooldown_time + rand_range(0, rand_cooldown_time)


func set_up(context: StateContext):
	.set_up(context)
	timer.wait_time = initial_wait_time
	has_setup = true
	timer.start()


func attack():
	context.FSM.signaler.emit_signal("state_sent_action", context.FSM, context.FSM.state.name, "Attack")


func exit():
	.exit()
	has_setup = false
