extends StateExit
class_name TimerBasedExit

export (float) var timeout_time = 1.0
export (float) var random_timeout_time = 0.0

# if true remaining time will be paused when exiting the state and resumed upon re entering
export (bool) var save_time = false

var timer: Timer
var should_exit = false

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "on_timer_timeout")

func set_timer():
	timer.wait_time = timeout_time + rand_range(0, random_timeout_time)
	timer.one_shot = true
	timer.start()

func set_up(context: StateContext) -> void:
	.set_up(context)
	should_exit = false
	if save_time:
		if timer.time_left == 0:
			set_timer()
		else:
			timer.paused = false
	else:
		set_timer()
	
func on_timer_timeout():
	should_exit = true
	if save_time:
		set_timer()

func check_condition() -> bool:

	return should_exit

func exit():
	.exit()
	if save_time:
		timer.paused = true
