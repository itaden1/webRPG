extends Spatial


var mesh_inst_scene = preload("res://Scenes/WorldChunk.tscn")
var tree_spawner_scene = preload("res://Scenes/TreeSpawner.tscn")


export (int) var chunk_count_x = 10
export (int) var chunk_count_y = 10
export (Vector2) var chunk_size = Vector2(500, 500)
export (Vector2) var chunk_divisions = Vector2(50, 50)
export (Vector2) var low_lod_chunk_divisions = Vector2(10, 10)
export (SpatialMaterial) var material

export (float) var hill_multiplyer = 100

onready var player: KinematicBody = get_node("Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	var hill_noise := OpenSimplexNoise.new()
	hill_noise.seed = randi()
	hill_noise.octaves = 4
	hill_noise.period = 800.0
	hill_noise.persistence = 0.8

	var biome_noise := OpenSimplexNoise.new()
	biome_noise.seed = randi()
	biome_noise.octaves = 4
	biome_noise.period = 1800.0
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
			mesh_inst.lod_1_mesh = apply_heights_to_mesh(hill_noise, plane_mesh, x, y, hill_multiplyer)
			mesh_inst.lod_2_mesh = apply_heights_to_mesh(hill_noise, lod_mesh, x, y, hill_multiplyer)
			mesh_inst.player = player

			add_child(mesh_inst)
			mesh_inst.global_transform.origin = Vector3(
				x * chunk_size.x, 
				0, 
				y * chunk_size.y
			)
			mesh_inst.material_override = material



			# place some trees
			if biome_noise.get_noise_3d(x, 0, y) > 0:
				print("things")
				var tree_spawner = tree_spawner_scene.instance()
				add_child(tree_spawner)
				tree_spawner.global_transform.origin.x = x * chunk_size.x
				tree_spawner.global_transform.origin.z = y * chunk_size.y
				tree_spawner.global_transform.origin.y = hill_noise.get_noise_3d(
					x * chunk_size.x, 0, y * chunk_size.y
				) * hill_multiplyer
	
	GameEvents.emit_signal("terrain_generation_complete")


func apply_heights_to_mesh(
	noise: OpenSimplexNoise, 
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
			vertex.y = noise.get_noise_3d(
				vertex.x + offset_x * chunk_size.x, 
				0, 
				vertex.z + offset_y * chunk_size.y) * multiplyer
				
			dt.set_vertex(i, vertex)
		var terrain_mesh := ArrayMesh.new()
		var _b = dt.commit_to_surface(terrain_mesh)
		return terrain_mesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
