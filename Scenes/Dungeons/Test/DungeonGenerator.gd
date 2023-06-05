extends Spatial


const bpt_generator = preload("res://Scripts/Generators/BinaryPartitionTree.gd")
var bpt = bpt_generator.new()

var dungeon_world_location_y := -500

const utilities = preload("res://Scripts/Utilities.gd")
var Utilities

var wall_block = preload("res://Scenes/Dungeons/Test/DungeonWall.tscn")
var corner_block = preload("res://Scenes/Dungeons/Test/DungeonWallCorner.tscn")
var corridor_block = preload("res://Scenes/Dungeons/Test/DungeonCorridor.tscn")
var floor_block = preload("res://Scenes/Dungeons/Test/DungeonFloor.tscn")

const blank_block = preload("res://Scenes/Towns/BuildingBlocks/Generic/Blank.tscn")


var dungeon_portal = preload("res://Scenes/Dungeons/DungeonPortal.tscn")

var outdoor_environment = preload("res://Environments/World.tres")
var indoor_environment = preload("res://Environments/Dungeon.tres")

var dungeon_interior_node: Spatial

var spawn_scene = preload("res://Scenes/Enemies/Spawner.tscn")


var offsets = {
	green_halls = {
		0: {horizontal = 9.5, vertical = 9.5}
	}
}
var themes = {
	green_halls = {
		0 : {
			0 : {},
			1 : {scene=wall_block, rotation=270},
			2 : {scene=wall_block, rotation=0},
			3 : {scene=corner_block, rotation=270},
			4 : {scene=wall_block, rotation=180},
			5 : {scene=corner_block, rotation=180},
			6 : {scene=corridor_block, rotation=180},
			7 : {},
			8 : {scene=wall_block, rotation=90},
			9 : {scene=corridor_block, rotation=90},
			10 : {scene=corner_block, rotation=0},
			11 : {},
			12 : {scene=corner_block, rotation=90},
			13 : {},
			14 : {},
			15 : {}
		}
	}
}

var dungeon: Dictionary = {}
var entrance: Spatial




func _init():
	._init()
	Utilities = utilities.new()

func _ready():
	pass
	# generate({width=25, height=25, partitions=10, padding=[3], max_room_size=6, min_room_size=3})
	# dungeon_interior_node.global_transform.origin.y = 0 # dungeon_world_location_y
	# yield(get_tree(), "idle_frame")
	# get_parent().navmesh = NavigationMesh.new()
	# get_parent().bake_navigation_mesh(false)


func generate(params: Dictionary):
	var dungeon_rect: Rect2 = Rect2(Vector2(0, 0), Vector2(params.width, params.height))
	var tree = bpt.partition_rect(
		dungeon_rect,
		params.partitions,
		params.max_room_size,
		params.min_room_size,
		params.padding
	)


	var grid: Dictionary = {}
	for x in range(0, params.width):
		for y in range(0, params.height):
			grid[Utilities.vec_as_key(Vector2(x,y))] = Constants.TILE_TYPES.BLOCKED #0

	var all_leaves = bpt.get_leaf_nodes(tree, tree.keys()[0])
	for l in all_leaves:
		for x in range(l.position.x, l.end.x):
			for y in range(l.position.y, l.end.y):
				grid[Utilities.vec_as_key(Vector2(x,y))] = Constants.TILE_TYPES.OPEN #1

	for l in all_leaves:
		var corridor_grid = make_corridors(tree, l, {})
		for k in corridor_grid.keys():
			if grid[k] == Constants.TILE_TYPES.BLOCKED:
				grid[k] = corridor_grid[k]

	var exit_vec: Vector2
	var possible_exits := []
	for n in grid.keys():
		var vec = Utilities.key_as_vec(n)
		if vec.x == 0 or vec.y == 0:
			if grid[n] == Constants.TILE_TYPES.OPEN:
				possible_exits.append(vec)

	exit_vec = possible_exits[Rng.get_random_range(0, possible_exits.size()-1)]
	grid[Utilities.vec_as_key(exit_vec)] = Constants.TILE_TYPES.EXIT# 2

	entrance = dungeon_portal.instance()
	add_child(entrance)
	
	var dungeon_exit = dungeon_portal.instance()
	add_child(dungeon_exit)

	var offset = offsets["green_halls"][0].horizontal

	entrance.exit = dungeon_exit.get_node("ExitPosition")
	entrance.exit_environment = indoor_environment
	dungeon_exit.exit_environment = outdoor_environment
	dungeon_exit.exit = entrance.get_node("ExitPosition")
	dungeon_exit.transform.origin = Vector3(exit_vec.x * offset + 4, dungeon_world_location_y, exit_vec.y * offset + 8)

	add_enemy_spawn_points(grid, offset)
	
	dungeon.layout = grid

func remove_dungeon_from_world():
	dungeon_interior_node.queue_free()

func add_dungeon_to_world():
	var offset = offsets["green_halls"][0].horizontal
	
	dungeon_interior_node = build_dungeon(dungeon.layout, offset)
	dungeon_interior_node.transform.origin.y = dungeon_world_location_y
	add_child(dungeon_interior_node)

func add_enemy_spawn_points(grid: Dictionary, offset: float):
	var grid_keys: Array = grid.keys()
	grid_keys.shuffle()
	var amount_of_enemies = Rng.get_random_range(7, 20)
	for i in range(amount_of_enemies):
		var enemy_spawn_point = spawn_scene.instance()
		enemy_spawn_point.transform.origin.x = Utilities.key_as_vec(grid_keys[i]).x * offset
		enemy_spawn_point.transform.origin.z = Utilities.key_as_vec(grid_keys[i]).y * offset
		enemy_spawn_point.transform.origin.y = dungeon_world_location_y

		enemy_spawn_point.dungeon = self

		enemy_spawn_point.navigation_node = get_parent().get_parent() # todo: clean this up 
		add_child(enemy_spawn_point)


func make_corridors(tree: Dictionary, branch: Rect2, grid: Dictionary):
	# TODO: Make a function in bpt script that describes corridor connections as a graph
	# TODO: Expiriment with looping paths
	var parent = bpt.get_parent_node(tree, branch)
	if !parent:
		return grid
	var branch_leaves = bpt.get_leaf_nodes(tree, branch)
	var sibling = bpt.get_sibling(tree, branch)
	var sibling_leaves = bpt.get_leaf_nodes(tree, sibling)

	for s in sibling_leaves:
		var s_center = s.get_center()
		var corridor_built = false
		for l in branch_leaves:
			var l_center = l.get_center()
			if s.position.x == l.position.x:
				# above/below eachother
				if s.position.y == l.end.y:
					# s is below l
					for y in range(l_center.y, s_center.y):
						grid[Utilities.vec_as_key(Vector2(s_center.x, y))] = 1
					corridor_built = true
					break
				else:
					# s is above l
					for y in range(s_center.y, l_center.y):
						grid[Utilities.vec_as_key(Vector2(s_center.x, y))] = 1
					corridor_built = true
					break
			elif s.position.y == l.position.y:
				# next to eachother
				if s.position.x == l.end.x:
					# s is to the right of l
					for x in range(l_center.x, s_center.x):
						grid[Utilities.vec_as_key(Vector2(x, s_center.y))] = 1
					corridor_built = true
					break
				else:
					# s is to the left of  l
					for x in range(s_center.x, l_center.x):
						grid[Utilities.vec_as_key(Vector2(x, s_center.y))] = 1
					corridor_built = true
					break
		if corridor_built:
			break
	return make_corridors(tree, parent, grid)

func get_block(mask: int, style: String, level: int) -> Dictionary:
	var level_style = themes[style]
	var block: Dictionary
	if level_style.has(level):
		block = themes[style][level][mask]
	else:
		block = themes[style]["roof"][mask]


	if block.keys().size() <= 0:
		block = {scene=blank_block, rotation=0}
	return block


func build_dungeon(grid: Dictionary, offset: float) -> Spatial:
	var base_node = Spatial.new()

	for r in grid.keys():
		if grid[r] == 1:
			var vec = Utilities.key_as_vec(r)
			var f_block = floor_block.instance()
			f_block.transform.origin.x = vec.x * offset
			f_block.transform.origin.z = vec.y * offset
			base_node.add_child(f_block)

			var mask = Utilities.get_four_bit_bitmask_from_grid(grid, vec)

			var block = get_block(mask, "green_halls", 0)
			var inst: Spatial = block.scene.instance()
			inst.rotate(Vector3.UP, deg2rad(block.rotation))


			base_node.add_child(inst)
			inst.transform.origin.x = vec.x * offset
			inst.transform.origin.z = vec.y * offset

			# roof
			var r_block = floor_block.instance()
			r_block.transform.origin.x = vec.x * offset
			r_block.transform.origin.z = vec.y * offset
			r_block.transform.origin.y = 10
			base_node.add_child(r_block)

	return base_node
