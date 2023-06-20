extends Node

const bpt_generator = preload("res://Scripts/Generators/BinaryPartitionTree.gd")
const utilities = preload("res://Scripts/Utilities.gd")
var Utilities

# TODO move to constants file?
const OCEAN_LEVEL = 0.21

var hill_noise := OpenSimplexNoise.new()
var precipitation_noise := OpenSimplexNoise.new()

var world_size: Vector2
var chunk_size: Vector2
var chunk_divisions: Vector2
var hill_multiplyer: int
var hill_exponent: int
var hill_exponent_fudge: int = 1
var max_locations_per_chunk = 3


# TODO use resources to describe locations
const city_template = {
	width=25, height=25, partitions=10, padding=[3,2,1], number_of_npcs=7, block_offset=10,
	plot_types=[Constants.HOUSE_TYPES.BUILDING, Constants.HOUSE_TYPES.FIELD, Constants.HOUSE_TYPES.THREE_STORY_BUILDING, Constants.HOUSE_TYPES.TWO_STORY_BUILDING]
}

const town_template = {
	width=10, height=10, partitions=10, padding=[3,2,1], number_of_npcs=7, block_offset=10,
	plot_types=[Constants.HOUSE_TYPES.BUILDING, Constants.HOUSE_TYPES.TWO_STORY_BUILDING, Constants.HOUSE_TYPES.FIELD]
}

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


	# save chunks that are good for placing large cities on
	var valid_city_chunks := []
	var valid_town_chunks := []

	# loop through each chunk of the world and create data
	data.chunks = {}
	for x in range(0, world_size.x, chunk_size.x):
		for y in range(0, world_size.y, chunk_size.y):
			var chunk_data = {}
			chunk_data.position = Vector2(x,y)
			chunk_data.mesh_data = []
			chunk_data.mesh_data_dict = {}
			chunk_data.locations = []

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
				chunk_data.mesh_data_dict[Utilities.vec_as_key(Vector2(vert.x, vert.z))] = vert
			
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
			var terrain_steepnes_score = 0
			for e in point_heights:
				if e > modify_land_height(OCEAN_LEVEL) + 2:
					above_sea_level_score += 1

				var new_steepnes_score = abs(point_heights[0] - e)
				if new_steepnes_score > terrain_steepnes_score:
					terrain_steepnes_score = new_steepnes_score
			
			chunk_data.above_sea_level_score = above_sea_level_score
			chunk_data.terrain_steepnes_score = terrain_steepnes_score	

			# check if its okay to place a large location here and add it to the list
			if above_sea_level_score >= 2 and above_sea_level_score < 4 and terrain_steepnes_score < 100:
				valid_city_chunks.append(chunk_data.position)
			
			# check if its valid to place a town here and add it to the list
			if above_sea_level_score >= 3 and terrain_steepnes_score < 150:
				valid_town_chunks.append(chunk_data.position)

			data.chunks[Utilities.vec_as_key(chunk_data.position)] = chunk_data

	# select chunks for capital cities
	# Only one city per chunk
	var kingdom_choices = Constants.KINGDOM_TYPES.values()

	var max_cities := 3
	var city_dist_from_other_city = chunk_size.x * 6
	var cities := []
	for v in valid_city_chunks:
		var c = data.chunks[Utilities.vec_as_key(v)]
		if cities.size() >= max_cities:
			break
		elif valid_city_chunks.has(c.position):
			var dist_from_other_city = city_dist_from_other_city
			for city in cities:
				var distance = city.distance_to(c.position)
				if distance < city_dist_from_other_city:
					dist_from_other_city = distance
					break
			if dist_from_other_city >= city_dist_from_other_city:
				c.locations = [{
					type=Constants.LOCATION_TYPES.CITY,
					layout=build_city(city_template)
				}]
				cities.append(c.position)
				var k = Rng.get_random_range(0, kingdom_choices.size()-1)
				c.kingdom_type = kingdom_choices[k]
				kingdom_choices.pop_at(k)

	# assign kindom to chunk, indicates which capital is clossest 
	# as well as textures / trees locations found there
	for ck in data.chunks.keys():
		var c = data.chunks[ck]
		var closest_city = null
		for k in cities:
			if closest_city == null:
				closest_city = data.chunks[Utilities.vec_as_key(k)]
			var distance = k.distance_to(c.position)
			if distance < closest_city.position.distance_to(c.position):
				closest_city = data.chunks[Utilities.vec_as_key(k)]
		c.kingdom_type = closest_city.kingdom_type


	# Determine chunks that will contain towns
	var town_dist_from_other_city = chunk_size.x * 3
	var max_towns := 10
	for v in valid_town_chunks:
		var c = data.chunks[Utilities.vec_as_key(v)]
		if cities.size() >= max_towns + max_cities:
			break
		elif valid_town_chunks.has(c.position):
			var dist_from_other_town = town_dist_from_other_city
			for city in cities:
				var distance = city.distance_to(c.position)
				if distance < town_dist_from_other_city:
					dist_from_other_town = distance
					break
			if dist_from_other_town >= town_dist_from_other_city:
				# TODO generate the town and other locations
				# TODO: sample the terrain to get valid building location
				var valid_positions:  Array = get_valid_building_positions(c.mesh_data)
				if valid_positions.size() > 0:
					var pos = valid_positions[Rng.get_random_range(0, valid_positions.size()-1)]

					#TODO chose random template
					var template = town_template
					var town = build_town(template)
					# TODO make better stamp
					var stamp := []
					for x in range(template.width):
						for y in range(template.height):
							stamp.append(Vector2(x, y))
					c.mesh_data = flatten_terrain(c.mesh_data, pos, stamp)
					c.locations = [{
						position = pos,
						type=Constants.LOCATION_TYPES.TOWN,
						name="Foo Town", # TODO: random gen town name
						layout=town
					}]
					cities.append(c.position)


	# Determine chunks that are inhabitable by small communities
	# This includes farms / villages / monastaries / mines and other man made locations
	var min_habitation_distance = chunk_size.x
	for ck in data.chunks.keys():
		var c = data.chunks[ck]
		for city in cities:
			var distance = city.distance_to(c.position)
			if distance <= min_habitation_distance and distance > 0 and c.above_sea_level_score >= 4 and c.terrain_steepnes_score < 250:
				# TODO more location types
				c.locations = [{type=Constants.LOCATION_TYPES.VILLAGE}]


	# generate wilderness areas
	for ck in data.chunks.keys():
		var c = data.chunks[ck]
		if c.locations.size() == 0:
			# TODO place wilderness locations
			pass

	# transform mesh_data_dict into array
	# for ck in data.chunks.keys():
	# 	var c = data.chunks[ck]
	# 	var arr := []
	# 	for k in c.mesh_data_dict.keys():
	# 		var val = c.mesh_data_dict[k]
	# 		arr.append(val)
	# 	c.mesh_data = arr

	return data

func flatten_terrain(terrain_mesh_data: Array, pos: Vector3, shape: Array = [
	Vector2(0,0),
	Vector2(1,0),
	Vector2(0,1),
	Vector2(1,1),
	Vector2(1,2),
	Vector2(2,2),
	Vector2(2,3),
	Vector2(3,2),
	Vector2(3,3),
	Vector2(4,4),
	Vector2(5,5),
	Vector2(6,6),
]) -> Array:
	"""
	Taking a mesh as input apply the shape to the position on the mesh. Flattenning / smoothing the
	terrain to the height of pos
	"""
	var dist = Vector2(terrain_mesh_data[0].x, terrain_mesh_data[0].z).distance_to(
		Vector2(terrain_mesh_data[1].x, terrain_mesh_data[1].z))
	var flattened = []
	for d in terrain_mesh_data:
		for v in shape:
			var vec_3 = Vector3(pos.x + v.x * dist, d.y, pos.z + v.y * dist)
			if d.distance_to(vec_3) < dist:
				d.y = pos.y
		flattened.append(d)

	return flattened


func build_city(template: Dictionary):
	pass

func build_town(template: Dictionary) -> Array:
	var width = template.width
	var height = template.height
	var plot_types = template.plot_types
	var town_rect: Rect2 = Rect2(Vector2(0, 0), Vector2(width, height))
	var bpt = bpt_generator.new()
	var tree = bpt.partition_rect(
		town_rect,
		template.partitions,
		6,
		2,
		template.padding
	)

	var data := []

	var houses: Array = []

	for b in tree.keys():
		if tree[b].size() <= 0:
			var plot_type = plot_types[Rng.get_random_range(0, plot_types.size()-1)]
			var orientations = [0, 1]
			var orientation = orientations[Rng.get_random_range(0, orientations.size()-1)]
			var floor_count = 1
			match plot_type:
				Constants.HOUSE_TYPES.BUILDING: floor_count = 1
				Constants.HOUSE_TYPES.TWO_STORY_BUILDING: floor_count = 2
				Constants.HOUSE_TYPES.THREE_STORY_BUILDING: floor_count = 3

				
			build_building(b, orientation, floor_count)

			houses.append(b)
			data.append({
				rect=b, 
				type=plot_type, 
				culture=Constants.CULTURES.TUDOR, # TODO select culture based on region of world
				grid=build_building(b, orientation, floor_count)
			})
	return data

func build_building(rect: Rect2, orientation: int, floor_count: int) -> Array:
	var layout := []
	for f in floor_count + 1:
		var floor_layout := {}
		for x in range(0, rect.size.x):
			for y in range(0, rect.size.y):
				var mask = Utilities.get_four_bit_bitmask_from_rect(rect, Vector2(rect.position.x+x, rect.position.y+y))
				floor_layout[Utilities.vec_as_key(Vector2(rect.position.x+x, rect.position.y+y))] = mask
				if f > floor_count:
					pass
					# TODO rotate roof randomly
		layout.append(floor_layout)
	return layout

func get_raw_land_height(x: float, y: float):
	var val = hill_noise.get_noise_3d(x, 0, y)
	return Utilities.normalize_to_zero_one_range(val)

func get_valid_building_positions(mesh_data: Array) -> Array:
	var arr := []
	for vert in mesh_data:
		if vert.y > modify_land_height(OCEAN_LEVEL):
			arr.append(vert)
	return arr


func modify_land_height(h: float):
	return pow(h * hill_multiplyer * hill_exponent_fudge, hill_exponent)


func get_reshaped_elevation(x: float, y: float) -> float:
	var distance = Utilities.euclidean_squared_distance(x, y, world_size.x, world_size.y)
	var elevation = get_raw_land_height(x, y)
	elevation = elevation + (0-distance) / 2
	if elevation > OCEAN_LEVEL:
		#modify the exponent to have flatter lands above ocean level
		var e = elevation - OCEAN_LEVEL + 0.06

		return modify_land_height(e) + modify_land_height(OCEAN_LEVEL) + 25
	return modify_land_height(elevation)
