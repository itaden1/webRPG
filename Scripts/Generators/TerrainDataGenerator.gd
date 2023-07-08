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

var splatmap_brush_size := 8
var splatmap_image_size := 256

var vertex_seperation_distance: float

var town_zones := []

# TODO use resources to describe locations
const crypt_template = {
	width=25, height=25, partitions=10, padding=[3], max_room_size=6, min_room_size=3
}

const city_template = {
	width=25, height=25, partitions=10, padding=[3,3,2,2,1], number_of_npcs=17, block_offset=10,
	required_plots=[
		Constants.HOUSE_TYPES.TRAINING_GROUND, 
		Constants.HOUSE_TYPES.TWO_STORY_BUILDING,
		Constants.HOUSE_TYPES.TWO_STORY_BUILDING, 
		Constants.HOUSE_TYPES.TWO_STORY_BUILDING, 
		Constants.HOUSE_TYPES.THREE_STORY_BUILDING
	],
	plot_types=[Constants.HOUSE_TYPES.BUILDING, Constants.HOUSE_TYPES.FIELD, Constants.HOUSE_TYPES.TWO_STORY_BUILDING, Constants.HOUSE_TYPES.THREE_STORY_BUILDING],
	dungeons=[Constants.DUNGEON_TYPES.CRYPT]
}

const town_template = {
	width=10, height=10, partitions=10, padding=[3,2,1], number_of_npcs=7, block_offset=10,
	minimum_buildings=4,
	required_plots=[
		Constants.HOUSE_TYPES.BUILDING, 
		Constants.HOUSE_TYPES.BUILDING, 
		Constants.HOUSE_TYPES.BUILDING, 
		Constants.HOUSE_TYPES.TWO_STORY_BUILDING, 
		Constants.HOUSE_TYPES.FIELD
	],
	plot_types=[Constants.HOUSE_TYPES.BUILDING, Constants.HOUSE_TYPES.TWO_STORY_BUILDING, Constants.HOUSE_TYPES.FIELD],
	dungeons=[]
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
	_hill_exponent_fudge: int = 1,
	_splatmap_image_size: int = 256,
	_splatmap_brush_size: int = 8
):

	world_size = _world_size
	chunk_size = _chunk_size
	chunk_divisions = _chunk_divisions
	hill_multiplyer = _hill_multiplyer
	hill_exponent = _hill_exponent
	hill_exponent_fudge = _hill_exponent_fudge
	splatmap_brush_size = _splatmap_brush_size
	splatmap_image_size = _splatmap_image_size

	# object to hold all world data
	var data = {}
	data.world_size = world_size
	data.chunk_size = chunk_size
	data.chunk_divisions = chunk_divisions

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
			


			# check base distance between verts
			vertex_seperation_distance = Vector2(chunk_data.mesh_data[0].x, chunk_data.mesh_data[0].z).distance_to(
				Vector2(chunk_data.mesh_data[1].x, chunk_data.mesh_data[1].z))

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
			chunk_data.building_zone = []

			# check if its okay to place a large location here and add it to the list
			if above_sea_level_score >= 3 and above_sea_level_score <= 4 and terrain_steepnes_score < 100:
				valid_city_chunks.append(chunk_data.position)
			
			# check if its valid to place a town here and add it to the list
			if above_sea_level_score >= 3 and terrain_steepnes_score < 150:
				valid_town_chunks.append(chunk_data.position)

			data.chunks[Utilities.vec_as_key(chunk_data.position)] = chunk_data

	# select chunks for capital cities
	# Only one city per chunk
	var kingdom_choices = Constants.REGION_TYPES.values()

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
				# TODO: random template
				var template = city_template
				
				var city = build_city(template)
				city.spawn_points = place_npcs(city.grid, template.number_of_npcs)
				var dungeon = generate_dungeon(city.grid, template.dungeons)

				# adjust template size to match world size
				var adjusted_width = template.width * (vertex_seperation_distance/template.block_offset)
				var adjusted_height = template.height * (vertex_seperation_distance/template.block_offset)
				
				# TODO make better stamp
				var stamp := []
				for x in range(-2, adjusted_width*2, vertex_seperation_distance):
					for y in range(-2, adjusted_height*2, vertex_seperation_distance):
						stamp.append(Vector2(x, y))

				var y = get_reshaped_elevation(c.position.x, c.position.y)
				if y < modify_land_height(OCEAN_LEVEL):
					y = modify_land_height(OCEAN_LEVEL) + 25
				var vec_3_pos = Vector3(0, y, 0)

				vec_3_pos.x = vec_3_pos.x - adjusted_width
				vec_3_pos.z = vec_3_pos.z - adjusted_height
				c.mesh_data = flatten_terrain(
					c.mesh_data, 
					vec_3_pos,
					stamp
				)
				c.locations = [{
					position = vec_3_pos,
					width = adjusted_width,
					height = adjusted_height,
					name="Argon", # TODO: random gen city name
					type=Constants.LOCATION_TYPES.CITY,
					layout=city,
					culture=Constants.CULTURES.TUDOR, # TODO select culture based on region of world
					dungeon=dungeon
				}]
				cities.append(c.position)
				var k = Rng.get_random_range(0, kingdom_choices.size()-1)
				c.region_type = kingdom_choices[k]
				kingdom_choices.pop_at(k)

	# assign kindom /region to chunk, indicates which capital is clossest 
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
		c.region_type = closest_city.region_type


	# create splat map data fr each chunk
	for ck in data.chunks.keys():
		var c = data.chunks[ck]
		c.texture_data = generate_texture_data(c)


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
				#TODO chose random template
				var template = town_template
				var valid_positions:  Array = get_valid_building_positions(c.mesh_data, template.width, template.height)
				if valid_positions.size() > 0:
					# adjust template size to match world size
					var adjusted_width = template.width * (vertex_seperation_distance/template.block_offset)
					var adjusted_height = template.height * (vertex_seperation_distance/template.block_offset)

					var pos = valid_positions[Rng.get_random_range(0, valid_positions.size()-1)]
					# offset slightly so origin is more aligned with center
					pos.x = pos.x - adjusted_width
					pos.z = pos.z - adjusted_height

					var town = build_town(template)
					var spawn_points: Array = place_npcs(town.grid, template.number_of_npcs)
					var dungeon = generate_dungeon(town.grid, template.dungeons)

					# TODO make better stamp
					var stamp := []
					for x in range(-2, adjusted_width*2, vertex_seperation_distance):
						for y in range(-2, adjusted_height*2, vertex_seperation_distance):
							stamp.append(Vector2(x, y))

					c.mesh_data = flatten_terrain(c.mesh_data, pos, stamp)
					c.locations = [{
						position = pos,
						width = adjusted_width,
						height = adjusted_height,
						type=Constants.LOCATION_TYPES.TOWN,
						name="Foo Town", # TODO: random gen town name
						layout=town,
						culture=Constants.CULTURES.TUDOR, # TODO select culture based on region of world
						npc_spawn_points=spawn_points,
						dungeon=dungeon
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
				# TODO add the location types
				c.locations = [{
					position = Vector3(c.position.x, 0, c.position.y),
					width=0,
					height=0,
					type=Constants.LOCATION_TYPES.VILLAGE,
					name="Farm", # TODO: random gen town name
					layout={},
					dungeon=null
				}]



	# generate wilderness areas
	for ck in data.chunks.keys():
		var c = data.chunks[ck]
		if c.locations.size() == 0:
			# TODO place wilderness locations
			pass


	# Tree placement
	for ck in data.chunks.keys():
		var c = data.chunks[ck]
		place_trees(c)


	return data

func place_trees(chunk):
	chunk.objects = []
	var dist = vertex_seperation_distance
	for v in range(0, chunk.mesh_data.size(), 5):
		# TODO check vert position and skip to achieve more even placememt
		# TODO check no placement zones (towns etc.)
		var vert = chunk.mesh_data[v]
		if vert.y < modify_land_height(OCEAN_LEVEL):
			continue



		# Placement is off by about 1/2 of chunk size
		var biome = get_biome(
			(vert.x + chunk.position.x),# - chunk_size.x / 4, 
			(vert.z + chunk.position.y) #- chunk_size.y / 4
		)
		var obj_type = get_object(chunk.region_type, biome)

		#stagger location
		var ob_x = vert.x + Rng.get_random_range(-dist*5, dist*5)
		var ob_z = vert.z 
		var ob_y = get_reshaped_elevation(ob_x+chunk.position.x, ob_z+chunk.position.y)

		var ob_vec = Vector3(ob_x, ob_y, ob_z)

		# avoid placing trees in town zones
		var skip := false
		for bz in chunk.locations:
			if Vector2(ob_vec.x, ob_vec.z).distance_to(Vector2(bz.position.x, bz.position.z)) < bz.width*3: # TODO remove magic number
				skip = true
				break
		if skip:
			continue

		chunk.objects.append(
			{biome=biome, object_index=obj_type, location=ob_vec, rotation=0}
		)


func get_object(region, biome):
	#TODO factor in regions as well
	var biome_objects = Constants.BIOME_OBJECTS[biome]
	var acc = 0
	var roll = Rng.get_random_range(1, 100)
	var item_index = null
	for i in range(biome_objects.size()):
		var o = biome_objects[i]
		if not item_index:
			if roll > 100 - o.chance - acc:
				item_index = i
				break

		acc += o.chance
	return item_index

func get_biome(x: float, y: float):
	var altitude = get_reshaped_elevation(x, y)
	var moisture = Utilities.normalize_to_zero_one_range(precipitation_noise.get_noise_3d(x, 0, y))

	if altitude > 750:
		return Constants.BIOMES.HIGH_ALTITUDE
	elif altitude > 300:
		if moisture > 0.6: return Constants.BIOMES.SNOW_FORRESTS
		else: return Constants.BIOMES.SNOW_PLANES
	elif altitude > 50:
		if moisture > 0.6: return Constants.BIOMES.TEMPERATE_DECIDUOUS_FOREST
		elif moisture > 0.4: return Constants.BIOMES.WOODLANDS
		else: return Constants.BIOMES.GRASSLAND
	elif altitude > 0:
		if moisture > 0.65: return Constants.BIOMES.SWAMP_LANDS
		else: return Constants.BIOMES.GRASSLAND
	else:
		return Constants.BIOMES.GRASSLAND
	
func flatten_terrain(terrain_mesh_data: Array, pos: Vector3, shape: Array) -> Array:
	"""
	Taking a mesh as input apply the shape to the position on the mesh. Flattenning / smoothing the
	terrain to the height of pos. Also acts as a marker to not place random trees.
	"""

	var dist = vertex_seperation_distance
	var flattened = []
	for d in terrain_mesh_data:

		# check if this is a chunk edge and dont modify if it is
		if d.x == 0 - chunk_size.x/2 or d.x == chunk_size.x/2 or d.z == 0 - chunk_size.y/2 or d.z == chunk_size.y/2:
			flattened.append(d)
			continue
		else:
			for v in shape:
				var vec_2 = Vector2(pos.x + v.x, pos.z + v.y)
				if Vector2(d.x, d.z).distance_to(vec_2) < dist:
					d.y = pos.y
		flattened.append(d)

	return flattened

func generate_texture_data(chunk):

	var data := {}
	data.region_type = chunk.region_type
	data.splatmap_data = {}

	var rects_to_paint = splatmap_image_size / splatmap_brush_size
	for i in range(rects_to_paint):
		for j in range(rects_to_paint):
			var region_size_x = (chunk_size.x / rects_to_paint)
			var region_size_y = (chunk_size.y / rects_to_paint)
			var pos_x = region_size_x * i + chunk.position.x - (chunk_size.x / 2) 
			var pos_y = region_size_y * j + chunk.position.y - (chunk_size.y / 2) 

			var biome: int = get_biome(pos_x, pos_y)
			var brushes : Array = Constants.BIOME_BRUSHES[biome]
			var brush_idx: int
			if brushes.size() == 1:
				brush_idx = 0
			else:
				brush_idx = Rng.get_random_range(0, brushes.size()-1)
			data.splatmap_data[Vector2(i * splatmap_brush_size, j * splatmap_brush_size)] = {brush=brush_idx, biome=biome}
	
	return data


func generate_dungeon(possible_entrances: Dictionary, dungeon_types: Array):
	var dungeon_type: int = 0
	var dungeon_template: Dictionary
	if dungeon_types.size() > 1:
		dungeon_type = dungeon_types[Rng.get_random_range(0, dungeon_types.size())]
	
	match dungeon_type:
		Constants.DUNGEON_TYPES.CRYPT:
			dungeon_template = crypt_template

	var dungeon_rect: Rect2 = Rect2(Vector2(0, 0), Vector2(dungeon_template.width, dungeon_template.height))
	var bpt = bpt_generator.new()
	var tree = bpt.partition_rect(
		dungeon_rect,
		dungeon_template.partitions,
		dungeon_template.max_room_size,
		dungeon_template.min_room_size,
		dungeon_template.padding
	)

	var dungeon_grid: Dictionary = {}
	dungeon_grid = bpt.graph_as_grid(tree)
	for x in range(0, dungeon_template.width):
		for y in range(0, dungeon_template.height):
			dungeon_grid[Utilities.vec_as_key(Vector2(x,y))] = Constants.TILE_TYPES.BLOCKED #0

	var all_leaves = bpt.get_leaf_nodes(tree, tree.keys()[0])
	for l in all_leaves:
		for x in range(l.position.x, l.end.x):
			for y in range(l.position.y, l.end.y):
				dungeon_grid[Utilities.vec_as_key(Vector2(x,y))] = Constants.TILE_TYPES.OPEN #1

	for l in all_leaves:
		var corridor_grid = bpt.make_corridors(tree, l, {})
		for k in corridor_grid.keys():
			if dungeon_grid[k] == Constants.TILE_TYPES.BLOCKED:
				dungeon_grid[k] = corridor_grid[k]

	var new_grid := {}

	var possible_exits := []
	for n in dungeon_grid.keys():
		var vec = Utilities.key_as_vec(n)
		if vec.x == 0 or vec.y == 0:
			if dungeon_grid[n] == Constants.TILE_TYPES.OPEN:
				possible_exits.append(vec)
		var mask: int = Utilities.get_four_bit_bitmask_from_grid(dungeon_grid, vec)
		if dungeon_grid[n] == Constants.TILE_TYPES.OPEN and mask < 15:
			new_grid[n] = mask

	# exit_vec = possible_exits[Rng.get_random_range(0, possible_exits.size()-1)]
	# dungeon_grid[Utilities.vec_as_key(exit_vec)] = Constants.TILE_TYPES.EXIT# 2
	var entry = possible_entrances.keys()[Rng.get_random_range(0, possible_entrances.keys().size()-1)]
	
	
	return {
		layout=new_grid,
		entrance=Utilities.key_as_vec(entry)
	}

func place_npcs(grid: Dictionary, number_of_npcs: int) -> Array:
	
	var npc_spawn_points := []

	# Create an array of potential places. Each one is popped from the Array when used
	var placements := []
	for p in grid.keys():
		var vec = Utilities.key_as_vec(p)
		placements.append(vec)
	# for x in range(0, grid.size()-1):
	# 	for y in range(0, grid[x].size()-1):
	# 		placements.append(Vector2(x, y))

	for npc in number_of_npcs:
		var vec = Vector2(placements[Rng.get_random_range(0, placements.size()-1)])
		npc_spawn_points.append(vec)
		placements.pop_at(placements.find(vec))
	return npc_spawn_points


func build_city(template: Dictionary) -> Dictionary:
	# TODO city things walls, districts, palace etc
	return build_town(template)

func build_town(template: Dictionary) -> Dictionary:
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

	# get the bpt graph in 2d Array form
	# grid values of 0 represent streets of the town
	var street_grid: Dictionary = bpt.graph_as_grid(tree)

	var data := {}
	data.buildings = []
	data.grid=street_grid

	var houses: Array = []

	# apply some randomness to where buildings are placed
	var buildings = tree.keys()
	buildings.shuffle()

	for i in range(buildings.size()):
		var b: Rect2 = buildings[i]
		if tree[b].size() <= 0:
			var plot_type : int
			if i >= template.required_plots.size():
				plot_type = plot_types[Rng.get_random_range(0, plot_types.size()-1)]
			else:
				plot_type = template.required_plots[i]
			var orientations = [0, 1]
			var orientation = orientations[Rng.get_random_range(0, orientations.size()-1)]
			var floor_count = 0
			match plot_type:
				Constants.HOUSE_TYPES.BUILDING: floor_count = 1
				Constants.HOUSE_TYPES.TWO_STORY_BUILDING: floor_count = 2
				Constants.HOUSE_TYPES.THREE_STORY_BUILDING: floor_count = 3


			var layout := []
			if floor_count > 0:
				layout = build_building(b, orientation, floor_count)

			houses.append(b)
			data.buildings.append({
				rect=b, 
				type=plot_type, 
				culture=Constants.CULTURES.TUDOR, # TODO select culture based on region of world
				grid=layout
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

func get_valid_building_positions(mesh_data: Array, width: float, height:float) -> Array:
	"""
	A valid building spot is a spot where we are not too close to the edge of a chunk, 
	so we dont have flattened terain creeping over borders and creating holes in the mesh
	It is above sea level
	TODO: create a limit for building on steep terrain

	"""

	var arr := []
	for vert in mesh_data:
		if vert.y > modify_land_height(OCEAN_LEVEL):
			# TODO get correct vertex range. mesh verts are between -500 and 500
			if vert.x < 400 and vert.x > -400 and vert.z < 400 and vert.z > -400:
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
