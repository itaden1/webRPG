extends Node


var hill_noise := OpenSimplexNoise.new()
var precipitation_noise := OpenSimplexNoise.new()

func build_world(
	world_size: Vector2,
	chunk_size: Vector2,
	chunk_divisions: Vector2,
	hill_multiplyer: int,
	hill_exponent: int,
	hill_exponent_fudge: int = 1
):
	# object to hold all world data
	var data = {}

	# noise data for the heightmap
	data.hill_noise = {
		seed = Rng.get_random_int(),
		octaves = 6,
		period = 3100.0,
		persistence = 0.5
	}

	# noise data for precipitation map
	data.precipitation_noise = {
		seed = Rng.get_random_int(),
		octaves = 4,
		period = 3500.0,
		persistence = 0.8
	}

	# create the noise
	hill_noise.seed = data.hill_noise.seed
	hill_noise.octaves = data.hill_noise.octaves
	hill_noise.period = data.hill_noise.period
	hill_noise.persistence = data.hill_noise.persistence

	precipitation_noise.seed = data.precipitation_noise.seed
	precipitation_noise.octaves = data.precipitation_noise.octaves
	precipitation_noise.period = data.precipitation_noise.period
	precipitation_noise.persistence = data.precipitation_noise.persistence

	# loop through each chunk of the world and create data
	for x in range(0, world_size.x, chunk_size.x):
		for y in range(0, world_size.y, chunk_size.y):
			print(x, " -- ", y)


	return data