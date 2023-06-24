extends Spatial

const utilities = preload("res://Scripts/Utilities.gd")
var Utilities

var world_data: Dictionary

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _init():
	._init()
	Utilities = utilities.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	WorldData.generate_world()
	world_data = WorldData.world

	for k in world_data.chunks.keys():
		var chunk = world_data.chunks[k]
		var plane_mesh := PlaneMesh.new()
		var chunk_position = Utilities.key_as_vec(k)
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
			
			var location_node = Spatial.new()

			if location.type == Constants.LOCATION_TYPES.TOWN:
				location_node.transform.origin = Vector3(
					location.position.x + chunk_position.x, 
					location.position.y, 
					location.position.z + chunk_position.y
				)
				build_town(location.layout, location_node)
				add_child(location_node)
		for o in chunk.objects:
			var tree = Constants.BIOME_OBJECTS[o.biome][o.object_index].obj
			# var tree = load("res://Scenes/NatureObjects/Tree08winter.tscn")
			var tree_inst = tree.instance()
			add_child(tree_inst)
			tree_inst.transform.origin.x = o.location.x + chunk_position.x
			tree_inst.transform.origin.y = o.location.y
			tree_inst.transform.origin.z = o.location.z + chunk_position.y


func build_town(layout: Array, location_node: Spatial):
	"""
	iterate through each floor of each building and place the relevent tile based on bitmask value
	"""
	for l in layout:
		var building_node := Spatial.new()
		for f in range(l.grid.size()):
			var floor_layout = l.grid[f]
			var culture = l.culture
			var level = f
			var level_key = level
			if f >= l.grid.size() -1:
				level_key = "roof"

			var tile_data = WorldData.house_themes[culture][level_key]
			var offsets = WorldData.house_themes[culture]["offsets"]

			var floor_node = place_floor(floor_layout, tile_data, level, offsets)

			building_node.add_child(floor_node)

		location_node.add_child(building_node)


func place_floor(floor_layout: Dictionary, tile_data: Dictionary, level, offsets) -> Spatial:
	var node: Spatial = Spatial.new()
	for k in floor_layout.keys():
		var mask = floor_layout[k]
		var vec = Utilities.key_as_vec(k)
		var tile = tile_data[mask]
		if tile.has("scene"):
			var tile_inst = tile.scene.instance()
			tile_inst.rotate(Vector3.UP, deg2rad(tile.rotation))
			tile_inst.transform.origin = Vector3(
				vec.x * offsets.horizontal, 
				level * offsets.vertical, 
				vec.y * offsets.horizontal
			)
			node.add_child(tile_inst)

	return node

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
