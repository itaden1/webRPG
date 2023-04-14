extends Spatial


var mesh_inst_scene = preload("res://Scenes/WorldChunk.tscn")

enum biomes {
	TEMPERATE_DECIDUOUS_FOREST,
	SNOW_FORRESTS,
	SNOW_PLANES,
	GRASSLAND,
	WOODLANDS,
	SWAMP_LANDS,
	HIGH_ALTITUDE
}

export (Image) var red_brush
export (Image) var green_brush
export (Image) var blue_brush

onready var location_generator = load("res://Scripts/Generators/LocationGenerator.gd").new()
var player_placed = false

# var grass_2_texture: Image = preload("res://Materials/Grass_02-128x128.png")
# var grass_11_texture : Image = preload("res://Materials/Grass_11-128x128.png")
# var snow_01_texture : Image = preload("res://Materials/Snow_01-128x128.png") 

onready var biome_brushes = {
	biomes.GRASSLAND : [red_brush],
	biomes.WOODLANDS : [red_brush, green_brush],
	biomes.SWAMP_LANDS: [green_brush],
	biomes.TEMPERATE_DECIDUOUS_FOREST : [green_brush],
	biomes.SNOW_FORRESTS : [blue_brush],
	biomes.SNOW_PLANES : [blue_brush],
	biomes.HIGH_ALTITUDE : [blue_brush]
}

var biome_objects = {
	biomes.GRASSLAND : [
		{		
			obj=preload("res://Scenes/NatureObjects/GrassBushFall.tscn"),
			chance=70
		},
		{		
			obj=preload("res://Scenes/NatureObjects/Tree03summerSmall.tscn"),
			chance=1
		}
	],
	biomes.WOODLANDS : [
		{		
			obj=preload("res://Scenes/NatureObjects/GrassBushFall.tscn"),
			chance=70
		},
		{		
			obj=preload("res://Scenes/NatureObjects/Tree03summerSmall.tscn"),
			chance=20
		}
	],
	biomes.SWAMP_LANDS : [
		{		
			obj=preload("res://Scenes/NatureObjects/Tree01summer.tscn"),
			chance=30
		},
		{		
			obj=preload("res://Scenes/NatureObjects/Tree03summerSmall.tscn"),
			chance=5
		}
	],
	biomes.TEMPERATE_DECIDUOUS_FOREST : [
		{		
			obj=preload("res://Scenes/NatureObjects/Tree01summer.tscn"),
			chance=30
		},
		{		
			obj=preload("res://Scenes/NatureObjects/GrassBushFall.tscn"),
			chance=1
		},
		{		
			obj=preload("res://Scenes/NatureObjects/Tree03summer.tscn"),
			chance=34
		},
		{		
			obj=preload("res://Scenes/NatureObjects/Tree03summerSmall.tscn"),
			chance=35
		}
	],
	biomes.SNOW_FORRESTS : [
		{		
			obj=preload("res://Scenes/NatureObjects/Tree08winter.tscn"),
			chance=90
		},
		{		
			obj=preload("res://Scenes/NatureObjects/Stone01Large.tscn"),
			chance=1
		},
		{		
			obj=preload("res://Scenes/NatureObjects/Stone01Large.tscn"),
			chance=1
		}
	],
	biomes.SNOW_PLANES : [
		{		
			obj=preload("res://Scenes/NatureObjects/Tree08winter.tscn"),
			chance=10
		},
		{		
			obj=preload("res://Scenes/NatureObjects/Stone01Large.tscn"),
			chance=1
		},

	],
	biomes.HIGH_ALTITUDE : [
		{		
			obj=preload("res://Scenes/NatureObjects/Stone01Large.tscn"),
			chance=1
		}
	]
	
}


const OCEAN_LEVEL = 0.25

export (ShaderMaterial) var world_material = load("res://Materials/SplatMap.tres")
export (Vector2) var chunks_to_render = Vector2(3, 3)
export (float) var chunk_load_time = 1.2
export (Vector2) var world_size = Vector2(40000, 40000)
export (Vector2) var chunk_size = Vector2(2000, 2000)
export (Vector2) var chunk_divisions = Vector2(60, 60)
export (Vector2) var low_lod_chunk_divisions = Vector2(10, 10)

export (float) var hill_multiplyer = 20.0
export (float) var hill_exponent = 3.0
export (float) var hill_exponent_fudge = 1.8

onready var player: KinematicBody = get_node("Player")

var hill_noise := OpenSimplexNoise.new()
var biome_noise := OpenSimplexNoise.new()

var thread: Thread

var instanced_chunks = {}

var chunk_data := {}
var tree_free_zone := []
var thread_timer := Timer.new()

class ChunkData:
	var mesh_instance: MeshInstance
	
	func _init(mesh_inst: MeshInstance):
		mesh_instance = mesh_inst

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
			instanced_chunks[Vector2(x,y)] = mesh_inst

			chunk_data[Vector2(x,y)] = ChunkData.new(mesh_inst)

			add_child(mesh_inst)
			place_locations(x, y, mesh_inst)


			call_deferred("place_trees", x, y, mesh_inst)
			call_deferred("make_texture", x, y, mesh_inst)
			
			mesh_inst.finalize()
			# call_deferred("place_towns", x, y, mesh_inst)


func place_locations(x: int, y: int, mesh_inst: MeshInstance):
	var dt: MeshDataTool = get_datatool_for_mesh(mesh_inst.lod_1_mesh)
	var max_locations := 3
	var location_count := 0
	var max_attempts := 30
	var attempts := 0
	var locations : Dictionary = {}
	while location_count < max_locations:
		attempts += 1
		if attempts >= max_attempts:
			break

		var vert_idx = Rng.get_random_range(0, dt.get_vertex_count() -1 )

		var vert = dt.get_vertex(vert_idx)
		
		# allow some padding on chunk borders. make sure placement is within a certain distance from center of chunk
		var distance_from_center: float = Vector2(vert.x, vert.z).distance_to(Vector2(0, 0))
		if distance_from_center > chunk_size.x/3:
			continue

		# check for duplicate placement
		if locations.has(vert_idx):
			continue

		# check for too cloes placement
		var skip = false
		for e in locations.values():
			if e.distance_to(vert) < chunk_size.x/3:
				skip = true
		if skip:
			continue
		# check if underwater
		if vert.y <= modify_land_height(OCEAN_LEVEL + 0.001):
			continue

		var location_data = location_generator.generate_town()
		var location: Node = location_data.location_node
		var location_padding = location_data.location_padding
		
		for i in range(dt.get_vertex_count()):
			var vertex: Vector3 = dt.get_vertex(i)
			if Vector2(vertex.x, vertex.z).distance_to(Vector2(vert.x, vert.z)) < location_padding:
				vertex.y = vert.y
				dt.set_vertex(i, vertex)
		
		var terrain_mesh := ArrayMesh.new()
		var _a = dt.commit_to_surface(terrain_mesh)
		mesh_inst.lod_1_mesh = terrain_mesh

		mesh_inst.add_child(location)

		location.global_transform.origin.y = vert.y
		location.global_transform.origin.x = vert.x + x 
		location.global_transform.origin.z = vert.z + y

		locations[vert_idx] = vert
		location_count += 1

		tree_free_zone.append(
			Rect2(
				Vector2((vert.x + x) - location_padding, (vert.y + y) - location_padding), 
				Vector2(location_padding*3, location_padding*3)
			)
		)

		if not player_placed:
			player.global_transform.origin = location.get_node("Spawn").global_transform.origin
			player_placed = true

func make_texture(x: int, y: int, mesh_inst: MeshInstance):
	var splat_texture := ImageTexture.new()
	var splat_image := Image.new()

	var image_size = 256
	var paint_rect_size = 8
	var rects_to_paint = image_size / paint_rect_size
	splat_image.create(image_size, image_size, false, Image.FORMAT_RGBA8)
	for i in range(1, rects_to_paint):
		for j in range(1, rects_to_paint):
			var region_size_x = (chunk_size.x / rects_to_paint)
			var region_size_y = (chunk_size.y / rects_to_paint)
			var pos_x = region_size_x * i + x -1000 # no idea why this magic number works but it does....
			var pos_y = region_size_y * j + y -1000

			var biome: int = get_biome(pos_x, pos_y)
			var tiles : Array = biome_brushes[biome]
			var brush = tiles[Rng.get_random_range(0, tiles.size()-1)]
			splat_image.blend_rect(brush, Rect2(Vector2(0, 0), Vector2(16,16)), Vector2(i * paint_rect_size, j * paint_rect_size))


	splat_texture.create_from_image(splat_image, 0)
	var new_material: ShaderMaterial = world_material.duplicate()

	new_material.set_shader_param("splatmap", splat_texture)

	mesh_inst.material_override = new_material

func place_trees(x: int, y: int, mesh_inst: MeshInstance):
	# place some trees
	var tree_spacing := 70.0
	var ocean_line = modify_land_height(OCEAN_LEVEL + 0.001)
	for i in range(int(chunk_size.x / tree_spacing )):
		for l in range(int(chunk_size.y / tree_spacing )):
			var position_x : float = x + i * tree_spacing#* Rng.get_random_range(tree_spacing-20, tree_spacing+20)
			var position_y : float = y + l * tree_spacing#* Rng.get_random_range(tree_spacing-20, tree_spacing+20)

			# skip if there is a town or other location around here
			var skip := false
			for z in tree_free_zone:
				if z.intersects(Rect2(Vector2(position_x, position_y) , Vector2(30,30))):
					skip = true
			if skip:
				continue
			
			var e = get_reshaped_elevation(position_x, position_y)
			if e > ocean_line:
				var _scene: PackedScene
				var _biome_objects: Array = biome_objects[get_biome(position_x, position_y)]

				var acc = 0
				var roll = Rng.get_random_range(1, 100)
				for o in _biome_objects:
					if not _scene:
						if roll > 100 - o.chance - acc:
							_scene = o.obj
							break

					acc += o.chance
				if not _scene:
					continue

				var instanced_scene = _scene.instance()
				mesh_inst.add_child(instanced_scene)
				instanced_scene.global_transform.origin.x = position_x
				instanced_scene.global_transform.origin.z = position_y
				instanced_scene.global_transform.origin.y = e

func get_biome(x: float, y: float):
	var altitude = get_reshaped_elevation(x, y)
	var moisture = normalize_to_zero_one_range(biome_noise.get_noise_3d(x, 0, y))

	# TODO get latitude or use varoni to create regions (snow, autumnal forrests, desert etc.)
	if altitude > 750:
		return biomes.HIGH_ALTITUDE
	elif altitude > 300:
		if moisture > 0.6: return biomes.SNOW_FORRESTS
		else: return biomes.SNOW_PLANES
	elif altitude > 100:
		if moisture > 0.6: return biomes.TEMPERATE_DECIDUOUS_FOREST
		elif moisture > 0.4: return biomes.WOODLANDS
		else: return biomes.GRASSLAND
	elif altitude > 0:
		if moisture > 0.65: return biomes.SWAMP_LANDS
		else: return biomes.GRASSLAND
	else:
		return biomes.GRASSLAND

func _ready():

	get_node("Player").global_transform.origin = Vector3(world_size.x/2, 1000, world_size.y/2)
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
	biome_noise.period = 3500.0
	biome_noise.persistence = 0.8
	
	_start_chunk_generation()
#	
	GameEvents.emit_signal("terrain_generation_complete")
	var ocean = get_node("Ocean")
	ocean.global_transform.origin.y = modify_land_height(OCEAN_LEVEL) -20
	ocean.scale = Vector3(world_size.x, 0, world_size.y)

func get_datatool_for_mesh(mesh: Mesh) -> MeshDataTool:
		var st := SurfaceTool.new()
		st.create_from(mesh,0)
		var array_mesh : ArrayMesh = st.commit()
		
		var dt := MeshDataTool.new()
		var _a = dt.create_from_surface(array_mesh, 0)
		return dt

func apply_heights_to_mesh(
	mesh: PlaneMesh, 
	offset_x: int, 
	offset_y: int
) -> ArrayMesh:

		var dt : MeshDataTool = get_datatool_for_mesh(mesh)
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
