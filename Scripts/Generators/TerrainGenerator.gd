extends Spatial


var mesh_inst_scene = preload("res://Scenes/WorldChunk.tscn")
var tree_spawner_scene = preload("res://Scenes/TreeSpawner.tscn")

const OCEAN_LEVEL = 0.35
const TREE_LINE = 0.45

export (int) var chunk_count_x = 20
export (int) var chunk_count_y = 20
export (Vector2) var chunk_size = Vector2(500, 500)
export (Vector2) var chunk_divisions = Vector2(30, 30)
export (Vector2) var low_lod_chunk_divisions = Vector2(5, 5)
export (SpatialMaterial) var material

export (float) var hill_multiplyer = 20.0
export (float) var hill_exponent = 3
export (float) var hill_exponent_fudge = 1.8

onready var player: KinematicBody = get_node("Player")

var hill_noise := OpenSimplexNoise.new()
var RNG := RandomNumberGenerator.new()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	RNG.randomize()
	hill_noise.seed = RNG.randi()
	hill_noise.octaves = 6
	hill_noise.period = 3100.0
	hill_noise.persistence = 0.5

	var biome_noise := OpenSimplexNoise.new()
	biome_noise.seed = randi()
	biome_noise.octaves = 4
	biome_noise.period = 500.0
	biome_noise.persistence = 0.8
	
	for x in chunk_count_x:
		for y in chunk_count_y:
			var plane_mesh := PlaneMesh.new()
			plane_mesh.subdivide_depth = chunk_divisions.y
			plane_mesh.subdivide_width = chunk_divisions.x
			plane_mesh.size = chunk_size

			var lod_mesh := PlaneMesh.new()
			lod_mesh.subdivide_depth = low_lod_chunk_divisions.y
			lod_mesh.subdivide_width = low_lod_chunk_divisions.x
			lod_mesh.size = chunk_size
				
			var mesh_inst = mesh_inst_scene.instance()
			mesh_inst.lod_1_mesh = apply_heights_to_mesh(plane_mesh, x, y, hill_multiplyer)
			mesh_inst.lod_2_mesh = apply_heights_to_mesh(lod_mesh, x, y, hill_multiplyer)
			mesh_inst.player = player

			add_child(mesh_inst)
			mesh_inst.global_transform.origin = Vector3(
				x * chunk_size.x, 
				0, 
				y * chunk_size.y
			)
			mesh_inst.material_override = material

			# place some trees
			var tree_spacing := 200.0
			var tree_line = modify_land_height(TREE_LINE)
			var ocean_line = modify_land_height(OCEAN_LEVEL + 0.001)
			for i in range(3):
				for l in range(3):
					var position_x : float = x * chunk_size.x + i * rand_range(0, tree_spacing-50)
					var position_y : float = y * chunk_size.y + l * rand_range(0, tree_spacing-50)
					if biome_noise.get_noise_3d(position_x, 0, position_y) > 0.0:

						var e = get_reshaped_elevation(position_x, position_y)
						if e > ocean_line and e < tree_line:
							var tree_spawner = tree_spawner_scene.instance()
							add_child(tree_spawner)
							tree_spawner.global_transform.origin.x = position_x
							tree_spawner.global_transform.origin.z = position_y
							tree_spawner.global_transform.origin.y = e

	
	GameEvents.emit_signal("terrain_generation_complete")
	get_node("Ocean").global_transform.origin.y = modify_land_height(OCEAN_LEVEL) -20

func apply_heights_to_mesh(
	mesh: PlaneMesh, 
	offset_x: int, 
	offset_y: int,
	multiplyer=80
) -> ArrayMesh:
	
		var st := SurfaceTool.new()
		st.create_from(mesh,0)
		var array_mesh : ArrayMesh = st.commit()
		
		var dt := MeshDataTool.new()
		var _a = dt.create_from_surface(array_mesh, 0)
		for i in range(dt.get_vertex_count()):
			var vertex = dt.get_vertex(i)
			var height = get_reshaped_elevation(
				vertex.x + offset_x * chunk_size.x,
				vertex.z + offset_y * chunk_size.y
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
	var width = chunk_count_x * chunk_size.x
	var height = chunk_count_y * chunk_size.y
	
	var nx = 2 * x/width - 1
	var ny = 2 * y/height - 1
	
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
	
