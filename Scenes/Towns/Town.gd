extends Spatial

const utilities = preload("res://Scripts/Utilities.gd")
var Utilities


func _init():
	._init()
	Utilities = utilities.new()

func generate(location: Dictionary):
	var town: Spatial = build_town(location.buildings)
	add_child(town)

func build_town(layout: Array) -> Spatial:
	"""
	iterate through each floor of each building and place the relevent tile based on bitmask value
	"""
	var town_node: Spatial = Spatial.new()

	for l in layout:
		var building_node := Spatial.new()
		var grid_size = l.grid.size()
		var offsets = Constants.HOUSE_THEMES[l.culture]["offsets"]
		# if l.type == Constants.HOUSE_TYPES.TRAINING_GROUND:
		# 	# TODO create proper spawn zone
		# 	# place spawn point in empty lot for now
		# 	if player_placed == false:
		# 		var player_scene = load("res://assets/simple_fpsplayer/Player.tscn")
		# 		var player = player_scene.instance()
		# 		building_node.add_child(player)
		# 		player.transform.origin = Vector3(l.rect.position.x*offsets.horizontal, player.transform.origin.y, l.rect.position.y*offsets.horizontal)
		# 		player_placed = true
			
		for f in range(grid_size):
			var floor_layout = l.grid[f]
			var culture = l.culture
			var level = f
			var level_key = level
			if f >= l.grid.size() -1:
				level_key = "roof"

			var tile_data = Constants.HOUSE_THEMES[culture][level_key]

			var floor_node: Spatial = place_floor(floor_layout, tile_data, level, offsets)

			building_node.add_child(floor_node)

		town_node.add_child(building_node)
	return town_node


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
