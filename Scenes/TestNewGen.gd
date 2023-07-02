extends Spatial

const utilities = preload("res://Scripts/Utilities.gd")
var Utilities

var world_data: Dictionary


var player_placed := false
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

	#TODO remove this variable
	var debug_chunk_offset = 0
	for k in world_data.chunks.keys():
		# debug_chunk_offset += 1
		var chunk = world_data.chunks[k]
		var plane_mesh := PlaneMesh.new()
		var chunk_position = Utilities.key_as_vec(k)
		plane_mesh.subdivide_depth = world_data.chunk_divisions.x
		plane_mesh.subdivide_width = world_data.chunk_divisions.y
		plane_mesh.size = world_data.chunk_size
		var terrain_mesh = apply_heights_to_mesh(plane_mesh, chunk.mesh_data)
		var mesh_inst =MeshInstance.new()
		mesh_inst.mesh = terrain_mesh
		mesh_inst.material_override = Constants.REGION_MATERIALS[chunk.region_type].duplicate()

		mesh_inst.material_override.set_shader_param("splatmap", create_splatmap(chunk.texture_data))
		mesh_inst.create_trimesh_collision()

		add_child(mesh_inst)
		mesh_inst.global_transform.origin = Vector3(chunk.position.x+debug_chunk_offset, 0, chunk.position.y+debug_chunk_offset)
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
				build_town(location.layout.buildings, location_node)
				place_npcs(location.layout.spawn_points, location_node, location.culture)
				add_child(location_node)
			if location.type == Constants.LOCATION_TYPES.CITY:
				# TODO other city things
				location_node.transform.origin = Vector3(
					location.position.x + chunk_position.x, 
					location.position.y, 
					location.position.z + chunk_position.y
				)
				build_town(location.layout.buildings, location_node)
				place_npcs(location.layout.spawn_points, location_node, location.culture)
				add_child(location_node)
		for o in chunk.objects:
			var idx = o.object_index
			if idx != null:
				var obj = Constants.BIOME_OBJECTS[o.biome][idx].obj		
				var obj_inst = obj.instance()
				add_child(obj_inst)
				obj_inst.transform.origin.x = o.location.x + chunk_position.x
				obj_inst.transform.origin.y = o.location.y
				obj_inst.transform.origin.z = o.location.z + chunk_position.y

func create_splatmap(texture_data):
	var splat_texture := ImageTexture.new()
	var splat_image := Image.new()

	# TODO add these values to world data and retriev from there
	var image_size = 256
	var paint_rect_size = 8
	splat_image.create(image_size, image_size, false, Image.FORMAT_RGBA8)
	for k in texture_data.splatmap_data.keys():
		var brush = Constants.BIOME_BRUSHES[texture_data.splatmap_data[k].biome][texture_data.splatmap_data[k].brush]

		splat_image.blend_rect(brush, Rect2(Vector2(0, 0), Vector2(16,16)), Vector2(k.x, k.y))


	splat_texture.create_from_image(splat_image, 0)
	return splat_texture

func place_npcs(spawn_points: Array, location_node: Spatial, culture: int):
	"""
	place some npcs at locations

	"""
	var npc_scene: PackedScene = load("res://Scenes/NPC/Ben.tscn")
	var offsets = WorldData.house_themes[culture]["offsets"]

	for p in spawn_points:
		var npc: Spatial = npc_scene.instance()
		var px = (p.x * offsets.horizontal) #+ (offsets.horizontal / 2)
		var py = (p.y * offsets.horizontal) #+ (offsets.horizontal / 2)
		npc.transform.origin = Vector3(px, 0, py)
		location_node.add_child(npc)



func build_town(layout: Array, location_node: Spatial):
	"""
	iterate through each floor of each building and place the relevent tile based on bitmask value
	"""
	for l in layout:
		var building_node := Spatial.new()
		var grid_size = l.grid.size()
		var offsets = WorldData.house_themes[l.culture]["offsets"]
		if l.type == Constants.HOUSE_TYPES.TRAINING_GROUND:
			# TODO create proper spawn zone
			# place spawn point in empty lot for now
			if player_placed == false:
				var player_scene = load("res://assets/simple_fpsplayer/Player.tscn")
				var player = player_scene.instance()
				building_node.add_child(player)
				player.transform.origin = Vector3(l.rect.position.x*offsets.horizontal, player.transform.origin.y, l.rect.position.y*offsets.horizontal)
				player_placed = true
			
		for f in range(grid_size):
			var floor_layout = l.grid[f]
			var culture = l.culture
			var level = f
			var level_key = level
			if f >= l.grid.size() -1:
				level_key = "roof"

			var tile_data = WorldData.house_themes[culture][level_key]

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
