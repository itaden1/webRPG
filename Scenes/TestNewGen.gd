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

	for k in world.chunks.keys():
		var chunk = world.chunks[k]
		var plane_mesh := PlaneMesh.new()
		plane_mesh.subdivide_depth = 50
		plane_mesh.subdivide_width = 50
		plane_mesh.size = Vector2(1000, 1000)
		var terrain_mesh = apply_heights_to_mesh(plane_mesh, chunk.mesh_data)
		var mesh_inst =MeshInstance.new()
		mesh_inst.mesh = terrain_mesh
		mesh_inst.material_override = SpatialMaterial.new()
		var materials_map = {
			Constants.KINGDOM_TYPES.DESERT: load("res://Materials/Dirt_15-128x128.png"),
			Constants.KINGDOM_TYPES.SNOW: load("res://Materials/Snow_01-128x128.png"),
			Constants.KINGDOM_TYPES.GRASSLAND: load("res://Materials/Grass_02-128x128.png"),
		}
		mesh_inst.material_override.albedo_texture = materials_map[chunk.kingdom_type]
		add_child(mesh_inst)
		mesh_inst.global_transform.origin = Vector3(chunk.position.x, 0, chunk.position.y)
		for location in chunk.locations:
			var colors = {
				Constants.LOCATION_TYPES.CITY: Color.blue,
				Constants.LOCATION_TYPES.TOWN: Color.aqua,
				Constants.LOCATION_TYPES.VILLAGE: Color.brown
			}
			var sc = load("res://Scenes/NatureObjects/DEBUG/ForbiddenPlacement.tscn")
			var inst = sc.instance()
			var material = SpatialMaterial.new()
			material.albedo_color = colors[location.type]
			inst.get_node("MeshInstance").material_override = material
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
