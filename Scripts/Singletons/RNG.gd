extends Node

var random_number_generator = RandomNumberGenerator.new()
var _seed: String = 'Its nice to try something new'
var intialised: bool = false

func _ready():
	pass # Replace with function body.

func get_random_int() -> int:
	if not intialised:
		if _seed == '0':
			random_number_generator.randomize()
			print(random_number_generator.seed, "<<<<")
		else:
			random_number_generator.seed = hash(_seed)
		intialised = true
	return random_number_generator.randi()
		
func get_random_range(x, y) -> int:
	if not intialised:
		if _seed == '0':
			random_number_generator.randomize()
			print(random_number_generator.seed, "<<<<")
		else:
			random_number_generator.seed = hash(_seed)
		intialised = true
	return random_number_generator.randi_range(x, y)
	
func set_seed(value: String):
	_seed = value
