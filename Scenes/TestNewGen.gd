extends Spatial

const utilities = preload("res://Scripts/Utilities.gd")
var Utilities

var world_data: Dictionary


var town_scene: PackedScene = load("res://Scenes/Towns/Town.tscn")



# var player_placed := false

func _init():
	._init()
	Utilities = utilities.new()

func _ready():
	WorldData.generate_world()
	world_data = WorldData.world

	var player_spawn_points: Array = []

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
		var mesh_inst = MeshInstance.new()
		mesh_inst.mesh = terrain_mesh
		mesh_inst.material_override = Constants.REGION_MATERIALS[chunk.region_type].duplicate()

		mesh_inst.material_override.set_shader_param("splatmap", create_splatmap(chunk.texture_data))
		mesh_inst.create_trimesh_collision()

		var navigation_node: NavigationMeshInstance = get_node("NavigationMeshInstance")
		navigation_node.add_child(mesh_inst)

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
				add_child(location_node)
				var town_instance = town_scene.instance()
				town_instance.generate(location.layout)
				location_node.add_child(town_instance)
				player_spawn_points += get_player_spawn_points(
					location.layout.buildings, 
					chunk_position, 
					location_node.global_transform.origin
				)
				place_npcs(location.npc_spawn_points, location_node, location.culture)
			if location.type == Constants.LOCATION_TYPES.CITY:
				# TODO other city things
				location_node.transform.origin = Vector3(
					location.position.x + chunk_position.x, 
					location.position.y, 
					location.position.z + chunk_position.y
				)
				add_child(location_node)
				var town_instance = town_scene.instance()
				town_instance.generate(location.layout)
				location_node.add_child(town_instance)
				player_spawn_points += get_player_spawn_points(
					location.layout.buildings, 
					chunk_position, 
					location_node.global_transform.origin
				)
				place_npcs(location.layout.spawn_points, location_node, location.culture)
			if location.dungeon != null:
				var offsets = Constants.HOUSE_THEMES[location.culture]["offsets"]
				var entrance_vec = location.dungeon.entrance
				var entrance_scene = load("res://Scenes/Dungeons/Test/Entrance.tscn")
				var entrance = entrance_scene.instance()
				var px = (entrance_vec.x * offsets.horizontal) #+ (offsets.horizontal / 2)
				var py = (entrance_vec.y * offsets.horizontal) 
				entrance.transform.origin.x = px
				entrance.transform.origin.z = py
				location_node.add_child(entrance)

				

				var dungeon_scene = load("res://Scenes/Dungeons/Dungeon.tscn")
				var dungeon = dungeon_scene.instance()
				dungeon.data = location.dungeon
				dungeon.offset = offsets.horizontal

				# add dungeon to entrance so it can be rendered upon interaction
				entrance.dungeon=dungeon




		for o in chunk.objects:
			var idx = o.object_index
			if idx != null:
				var obj = Constants.BIOME_OBJECTS[o.biome][idx].obj		
				var obj_inst = obj.instance()
				navigation_node.add_child(obj_inst)
				obj_inst.transform.origin.x = o.location.x + chunk_position.x
				obj_inst.transform.origin.y = o.location.y
				obj_inst.transform.origin.z = o.location.z + chunk_position.y
	

	print("{{))++}}", player_spawn_points.size())
	var player_spawn_position: Vector3 = player_spawn_points[
		Rng.get_random_range(0, player_spawn_points.size() - 1)
	]

	var player_scene = load("res://assets/simple_fpsplayer/Player.tscn")
	var player = player_scene.instance()
	add_child(player)
	player.global_transform.origin = player_spawn_position

func get_player_spawn_points(layout: Array, chunk_position, location_position: Vector3) -> Array:
	var spawn_points := []
	for l in layout:
		# var building_node := Spatial.new()
		var offsets = Constants.HOUSE_THEMES[l.culture]["offsets"]
		if l.type == Constants.HOUSE_TYPES.TRAINING_GROUND:
			spawn_points.append(Vector3(
				l.rect.position.x*offsets.horizontal + location_position.x, 
				location_position.y+1, 
				l.rect.position.y*offsets.horizontal + location_position.z
			))
	return spawn_points

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
	var offsets = Constants.HOUSE_THEMES[culture]["offsets"]

	for p in spawn_points:
		var npc: Spatial = npc_scene.instance()
		var px = (p.x * offsets.horizontal) #+ (offsets.horizontal / 2)
		var py = (p.y * offsets.horizontal) #+ (offsets.horizontal / 2)
		npc.transform.origin = Vector3(px, 0, py)
		location_node.add_child(npc)


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
