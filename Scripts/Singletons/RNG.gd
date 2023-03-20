extends Node

var random_number_generator = RandomNumberGenerator.new()
var _seed: String = 'super_duper'
var intialised: bool = false

func _ready():
	pass # Replace with function body.

func get_random_int() -> int:
	if not intialised:
		if _seed == '0':
			random_number_generator.randomize()
		else:
			random_number_generator.seed = hash(_seed)
		intialised = true
	return random_number_generator.randi()
		

func set_seed(value: String):
	_seed = value
