extends Spatial


export (int) var chunk_count_x = 10
export (int) var chunk_count_y = 10
export (Vector2) var chunk_size = Vector2(500, 500)
export (Vector2) var chunk_divisions = Vector2(50, 50)
export (Vector2) var low_lod_chunk_divisions = Vector2(10, 10)
export (SpatialMaterial) var material

# Called when the node enters the scene tree for the first time.
func _ready():
	var noise: OpenSimplexNoise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 800.0
	noise.persistence = 0.8
	
	for x in chunk_count_x:
		for y in chunk_count_y:
			var plane_mesh: PlaneMesh = PlaneMesh.new()
			plane_mesh.subdivide_depth = chunk_divisions.y
			plane_mesh.subdivide_width = chunk_divisions.x
			plane_mesh.size = chunk_size
			
			
			var st := SurfaceTool.new()
			st.create_from(plane_mesh,0)
			var array_mesh : ArrayMesh = st.commit()
			
			var dt := MeshDataTool.new()
			dt.create_from_surface(array_mesh, 0)
			for i in range(dt.get_vertex_count()):
				var vertex = dt.get_vertex(i)
				vertex.y = noise.get_noise_3d(
					vertex.x + x * chunk_size.x, 
					0, 
					vertex.z + y * chunk_size.y) * 60
					
				dt.set_vertex(i, vertex)
			var terrain_mesh := ArrayMesh.new()
			dt.commit_to_surface(terrain_mesh)
			
			
			# create mesh instance
			var mesh_inst = MeshInstance.new()
			mesh_inst.mesh = terrain_mesh
			add_child(mesh_inst)
			mesh_inst.global_transform.origin = Vector3(x * chunk_size.x, 0, y * chunk_size.y)
		
			mesh_inst.material_override = material
			mesh_inst.create_trimesh_collision()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
