extends Node

const utilities = preload("res://Scripts/Utilities.gd")
var Utilities

# TODO move to constants file?
const OCEAN_LEVEL = 0.18

var hill_noise := OpenSimplexNoise.new()
var precipitation_noise := OpenSimplexNoise.new()

var world_size: Vector2
var chunk_size: Vector2
var chunk_divisions: Vector2
var hill_multiplyer: int
var hill_exponent: int
var hill_exponent_fudge: int = 1

func _init():
	._init()
	Utilities = utilities.new()


func build_world(
	_world_size: Vector2,
	_chunk_size: Vector2,
	_chunk_divisions: Vector2,
	_hill_multiplyer: int,
	_hill_exponent: int,
	_hill_exponent_fudge: int = 1
):

	world_size = _world_size
	chunk_size = _chunk_size
	chunk_divisions = _chunk_divisions
	hill_multiplyer = _hill_multiplyer
	hill_exponent = _hill_exponent
	hill_exponent_fudge = _hill_exponent_fudge

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
	data.chunks = []
	for x in range(0, world_size.x, chunk_size.x):
		for y in range(0, world_size.y, chunk_size.y):
			var chunk_data = {}
			chunk_data.position = Vector2(x,y)
			chunk_data.mesh_data = []

			# create the mesh data, for now we just copy it to an array for easy re use
			# but maybe just saving the mesh as is might be more optimal?
			var plane_mesh := PlaneMesh.new()
			plane_mesh.subdivide_depth = chunk_divisions.y
			plane_mesh.subdivide_width = chunk_divisions.x
			plane_mesh.size = chunk_size

			var mesh_data_tool = Utilities.get_datatool_for_mesh(plane_mesh)
			for i in range(mesh_data_tool.get_vertex_count()):
				var vert = mesh_data_tool.get_vertex(i)
				var e = get_reshaped_elevation(vert.x+x, vert.z+y)
				vert.y = e
				chunk_data.mesh_data.append(vert)
			
			# determine whether this is an above see level chunk
			# for each corner of the chunk get its height above sea level
			# chunks with a score < 4 are candidates for a port town
			# terrain steepness score
			# This score can determine whether or not to place large towns on this chunk
			var point_heights = [
				get_reshaped_elevation(x, y),
				get_reshaped_elevation(x+chunk_size.x, y),
				get_reshaped_elevation(x, y+chunk_size.y),
				get_reshaped_elevation(x+chunk_size.x, y+chunk_size.y)
			]
			var above_sea_level_score = 0
			var height_diff = 0
			for e in point_heights:
				if e > modify_land_height(OCEAN_LEVEL) + 2:
					above_sea_level_score += 1

				var new_diff = abs(point_heights[0] - e)
				if new_diff > height_diff:
					height_diff = new_diff
			
			chunk_data.above_sea_level_score = above_sea_level_score
			chunk_data.terrain_steepnes_score = height_diff

			data.chunks.append(chunk_data)

	return data


func get_raw_land_height(x: float, y: float):
	var val = hill_noise.get_noise_3d(x, 0, y)
	return Utilities.normalize_to_zero_one_range(val)


func modify_land_height(h: float):
	return pow(h * hill_multiplyer * hill_exponent_fudge, hill_exponent)


func get_reshaped_elevation(x: float, y: float) -> float:
	var distance = Utilities.euclidean_squared_distance(x, y, world_size.x, world_size.y)
	var elevation = get_raw_land_height(x, y)
	elevation = elevation + (0-distance) / 2
	if elevation > OCEAN_LEVEL:
		#modify the exponent to have flatter lands above ocean level
		var e = elevation - OCEAN_LEVEL

		return modify_land_height(e) + modify_land_height(OCEAN_LEVEL) + 2
	return modify_land_height(elevation)
