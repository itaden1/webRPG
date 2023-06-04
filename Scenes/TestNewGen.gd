extends Spatial

const utilities = preload("res://Scripts/Utilities.gd")
var Utilities

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _init():
	._init()
	Utilities = utilities.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	WorldData.generate_world()
	var world = WorldData.world

	for chunk in world.chunks:
		var plane_mesh := PlaneMesh.new()
		plane_mesh.subdivide_depth = 50
		plane_mesh.subdivide_width = 50
		plane_mesh.size = Vector2(1000, 1000)
		var terrain_mesh = apply_heights_to_mesh(plane_mesh, chunk.mesh_data)
		var mesh_inst =MeshInstance.new()
		mesh_inst.mesh = terrain_mesh
		mesh_inst.material_override = SpatialMaterial.new()
		mesh_inst.material_override.albedo_texture = load("res://Materials/Dirt_15-128x128.png")
		add_child(mesh_inst)
		mesh_inst.global_transform.origin = Vector3(chunk.position.x, 0, chunk.position.y)
		if chunk.terrain_steepnes_score <= 150 and chunk.above_sea_level_score > 2:
			var sc = load("res://Scenes/NatureObjects/DEBUG/ForbiddenPlacement.tscn")
			var inst = sc.instance()
			mesh_inst.add_child(inst)

func apply_heights_to_mesh(
	mesh: PlaneMesh, 
	heights: Array
) -> ArrayMesh:

		var dt : MeshDataTool = Utilities.get_datatool_for_mesh(mesh)
		for i in range(dt.get_vertex_count()):
			var vertex = dt.get_vertex(i)
			vertex.y = heights[i].y
				
			dt.set_vertex(i, vertex)
		var terrain_mesh := ArrayMesh.new()
		var _b = dt.commit_to_surface(terrain_mesh)
		return terrain_mesh
