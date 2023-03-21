extends Spatial


var mesh_inst_scene = preload("res://Scenes/WorldChunk.tscn")

enum biomes {
	TEMPERATE_DECIDUOUS_FOREST,
	SNOW,
	GRASSLAND
}

var biome_objects = {
	biomes.GRASSLAND : {
		objects = [
			{		
				obj=preload("res://Scenes/GrassBushFall.tscn"),
				chance=3
			}
		]
	},
	biomes.TEMPERATE_DECIDUOUS_FOREST : {
		objects = [
			{		
				obj=preload("res://Scenes/Tree01summer.tscn"),
				chance=9
			}
		]
	},
	biomes.SNOW : {
		objects = [
			{		
				obj=preload("res://Scenes/Tree08winter.tscn"),
				chance=6
			}
		]
	},
}


const OCEAN_LEVEL = 0.25
const TREE_LINE = 0.6

export (Vector2) var chunks_to_render = Vector2(3, 3)
export (float) var chunk_load_time = 1.2
export (Vector2) var world_size = Vector2(40000, 40000)
export (Vector2) var chunk_size = Vector2(2000, 2000)
export (Vector2) var chunk_divisions = Vector2(30, 30)
export (Vector2) var low_lod_chunk_divisions = Vector2(10, 10)
export (SpatialMaterial) var material

export (float) var hill_multiplyer = 20.0
export (float) var hill_exponent = 3
export (float) var hill_exponent_fudge = 1.8

onready var player: KinematicBody = get_node("Player")

var hill_noise := OpenSimplexNoise.new()
var biome_noise := OpenSimplexNoise.new()

var thread: Thread

var instanced_chunks = {}
var thread_timer := Timer.new()


func get_closest_multiple(n: int, x: int):
	if x > n:
		return x
	n = n + int(x/2)
	n = n - (n % x)
	return n
	

func _start_chunk_generation():
	_generation_thread_method(player.global_transform.origin)
#	if thread and thread.is_active():
#		thread.wait_to_finish()
#	thread = Thread.new()
#	if thread.start(self, "_generation_thread_method", player.global_transform.origin) != OK:
#		print("failed to start the thread")
	
func _generation_thread_method(player_position):
	var player_chunk_x = get_closest_multiple(int(player_position.x), chunk_size.x)
	var player_chunk_z = get_closest_multiple(int(player_position.z), chunk_size.y)
	print("player is at chunk ", player_chunk_x, "-", player_chunk_z)
	render_world_chunks(Vector2(player_chunk_x, player_chunk_z))

func render_world_chunks(start_pos: Vector2):
	var start_x = start_pos.x - chunks_to_render.x * chunk_size.x
	var end_x = start_pos.x + (chunks_to_render.x + 1) * chunk_size.x
	var start_y = start_pos.y - chunks_to_render.y * chunk_size.y
	var end_y = start_pos.y + (chunks_to_render.y + 1) * chunk_size.y
	
	for x in range(start_x, end_x, chunk_size.x):
		for y in range(start_y, end_y, chunk_size.y):
			if instanced_chunks.has(Vector2(
				x,
				y
			)):
				continue
			var plane_mesh := PlaneMesh.new()
			plane_mesh.subdivide_depth = chunk_divisions.y
			plane_mesh.subdivide_width = chunk_divisions.x
			plane_mesh.size = chunk_size

			var lod_mesh := PlaneMesh.new()
			lod_mesh.subdivide_depth = low_lod_chunk_divisions.y
			lod_mesh.subdivide_width = low_lod_chunk_divisions.x
			lod_mesh.size = chunk_size
				
			var mesh_inst : MeshInstance = mesh_inst_scene.instance()
			mesh_inst.lod_1_mesh = apply_heights_to_mesh(plane_mesh, x, y)
			mesh_inst.lod_2_mesh = apply_heights_to_mesh(lod_mesh, x, y)
			mesh_inst.player = player

			mesh_inst.transform.origin = Vector3(x, 0, y)
			mesh_inst.material_override = material
			instanced_chunks[Vector2(x,y)] = mesh_inst
			add_child(mesh_inst)

			call_deferred("place_trees", x, y, mesh_inst)


func place_trees(x: int, y: int, mesh_inst: MeshInstance):
	# place some trees
	var tree_spacing := 160.0
	var tree_line = modify_land_height(TREE_LINE)
	var ocean_line = modify_land_height(OCEAN_LEVEL + 0.001)
	for i in range(int(chunk_size.x / tree_spacing)):
		for l in range(int(chunk_size.y / tree_spacing)):
			# TODO use the rng singleton and seed to reproduce results
			var position_x : float = x + i * Rng.get_random_range(tree_spacing-20, tree_spacing+20)
			var position_y : float = y + l * Rng.get_random_range(tree_spacing-20, tree_spacing+20)
			var biome_objects = get_objects_for_biome(position_x, position_y)
			
			var e = get_reshaped_elevation(position_x, position_y)
			if e > ocean_line and e < tree_line:
				var tree_scene = biome_objects.objects[0].obj
				var tree = tree_scene.instance()
				mesh_inst.add_child(tree)
				tree.global_transform.origin.x = position_x
				tree.global_transform.origin.z = position_y
				tree.global_transform.origin.y = e

func get_objects_for_biome(x: float, y: float):
	var altitude = get_reshaped_elevation(x, y)
	var moisture = normalize_to_zero_one_range(biome_noise.get_noise_3d(x, 0, y))

	if altitude > 300: 
		print("alt: ", altitude, " moist: ", moisture)
		if moisture > 0.6: return biome_objects[biomes.SNOW]
		else: return biome_objects[biomes.GRASSLAND]
	elif altitude > 0:
		print("alt: ", altitude, " moist: ", moisture)
		if moisture > 0.6: return biome_objects[biomes.TEMPERATE_DECIDUOUS_FOREST]
		else: return biome_objects[biomes.GRASSLAND]
	


func _ready():

	add_child(thread_timer)
	thread_timer.wait_time = chunk_load_time
	thread_timer.one_shot = false
	thread_timer.connect("timeout", self, "_start_chunk_generation")
	thread_timer.start()

	hill_noise.seed = Rng.get_random_int()
	hill_noise.octaves = 6
	hill_noise.period = 3100.0
	hill_noise.persistence = 0.5


	biome_noise.seed = Rng.get_random_int()
	biome_noise.octaves = 4
	biome_noise.period = 500.0
	biome_noise.persistence = 0.8
	
	_start_chunk_generation()
#	
	GameEvents.emit_signal("terrain_generation_complete")
	var ocean = get_node("Ocean")
	ocean.global_transform.origin.y = modify_land_height(OCEAN_LEVEL) -20
	ocean.scale = Vector3(world_size.x, 0, world_size.y)

func apply_heights_to_mesh(
	mesh: PlaneMesh, 
	offset_x: int, 
	offset_y: int
) -> ArrayMesh:
	
		var st := SurfaceTool.new()
		st.create_from(mesh,0)
		var array_mesh : ArrayMesh = st.commit()
		
		var dt := MeshDataTool.new()
		var _a = dt.create_from_surface(array_mesh, 0)
		for i in range(dt.get_vertex_count()):
			var vertex = dt.get_vertex(i)
			var height = get_reshaped_elevation(
				vertex.x + offset_x,
				vertex.z + offset_y
			)
			
			vertex.y = height
				
			dt.set_vertex(i, vertex)
		var terrain_mesh := ArrayMesh.new()
		var _b = dt.commit_to_surface(terrain_mesh)
		return terrain_mesh

func normalize_to_zero_one_range(num: float):
	var max_num = 1
	var min_num = -1
	return (num - min_num) / (max_num - min_num)
	
func get_raw_land_height(x: float, y: float):
	var val = hill_noise.get_noise_3d(x, 0, y)
	return normalize_to_zero_one_range(val)
	
func get_modified_land_height(x: float, y: float):
	var initial_height = get_raw_land_height(x, y)
	return modify_land_height(initial_height)

func modify_land_height(h: float):
	return pow(h * hill_multiplyer * hill_exponent_fudge, hill_exponent)

func euclidean_squared_distance(x: float, y: float) -> float:
	# gets the euclidean squared distance from the vertex to the map border
	
	var nx = 2 * x/world_size.x - 1
	var ny = 2 * y/world_size.y - 1
	
	var distance = min(1, (pow(nx, 2) + pow(ny, 2)) / sqrt(2))

	return distance

func get_reshaped_elevation(x: float, y: float) -> float:
	var distance = euclidean_squared_distance(x, y)
	var elevation = get_raw_land_height(x, y)
	elevation = elevation + (0-distance) / 2
	if elevation > OCEAN_LEVEL:
		#modify the exponent to have flatter lands above ocean level
		var e = elevation - OCEAN_LEVEL

		return pow(e * 25 * 1.2, 3) + modify_land_height(OCEAN_LEVEL) + 1
	
	return modify_land_height(elevation)
	
func _exit_tree():
	if thread:
		thread.wait_to_finish()
