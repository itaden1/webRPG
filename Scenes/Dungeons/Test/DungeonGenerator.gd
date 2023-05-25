extends Spatial


const bpt_generator = preload("res://Scripts/Generators/BinaryPartitionTree.gd")
var bpt = bpt_generator.new()

var dungeon_world_location_y := -2000

const utilities = preload("res://Scripts/Utilities.gd")
var Utilities

# spawn point for testing
onready var spawn_point: Spatial = get_node("SpawnPoint")

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

func _init():
	._init()
	Utilities = utilities.new()

func _ready():
	pass
	# generate({width=25, height=25, partitions=10, padding=[3], max_room_size=6, min_room_size=3})
	# dungeon_interior_node.global_transform.origin.y = 0 # dungeon_world_location_y


func generate(params: Dictionary):
	var dungeon_rect: Rect2 = Rect2(Vector2(0, 0), Vector2(params.width, params.height))
	var tree = bpt.partition_rect(
		dungeon_rect,
		params.partitions,
		params.max_room_size,
		params.min_room_size,
		params.padding
	)

	var offset = 9.5

	var dungeon_exit_vec: Vector2

	var grid: Dictionary = {}
	for x in range(0, params.width):
		for y in range(0, params.height):
			grid[_as_key(Vector2(x,y))] = 0

	var all_leaves = bpt.get_leaf_nodes(tree, tree.keys()[0])
	for l in all_leaves:
		for x in range(l.position.x, l.end.x):
			for y in range(l.position.y, l.end.y):
				grid[_as_key(Vector2(x,y))] = 1
				if !dungeon_exit_vec:
					dungeon_exit_vec = Vector2(l.position.x, l.position.y-1)

	for l in all_leaves:
		var corridor_grid = make_corridors(tree, l, {})

		for k in corridor_grid.keys():
			if grid[k] == 0:
				grid[k] = corridor_grid[k]

	dungeon_interior_node = build_dungeon(grid, offset)
	
	dungeon_interior_node.transform.origin.y = dungeon_world_location_y
	
	add_child(dungeon_interior_node)

	var dungeon_entrance = dungeon_portal.instance()
	add_child(dungeon_entrance)
	var dungeon_exit = dungeon_portal.instance()
	dungeon_interior_node.add_child(dungeon_exit)

	dungeon_entrance.exit = dungeon_exit.get_node("ExitPosition")
	dungeon_entrance.exit_environment = indoor_environment
	dungeon_exit.exit_environment = outdoor_environment
	dungeon_exit.exit = dungeon_entrance.get_node("ExitPosition")
	dungeon_exit.transform.origin = Vector3(dungeon_exit_vec.x * offset + 4, 0, dungeon_exit_vec.y * offset + 8)


	add_enemy_spawn_points(dungeon_interior_node, grid, offset)

func add_enemy_spawn_points(parent_node: Node, grid: Dictionary, offset: float):
	var grid_keys: Array = grid.keys()
	grid_keys.shuffle()
	for i in range(15):
		var enemy_spawn_point = spawn_scene.instance()
		enemy_spawn_point.transform.origin.x = _key_as_vec(grid_keys[i]).x * offset
		enemy_spawn_point.transform.origin.z = _key_as_vec(grid_keys[i]).y * offset
		enemy_spawn_point.navigation_node = get_parent().get_parent() # todo: clean this up 
		parent_node.add_child(enemy_spawn_point)


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
						grid[_as_key(Vector2(s_center.x, y))] = 1
					corridor_built = true
					break
				else:
					# s is above l
					for y in range(s_center.y, l_center.y):
						grid[_as_key(Vector2(s_center.x, y))] = 1
					corridor_built = true
					break
			elif s.position.y == l.position.y:
				# next to eachother
				if s.position.x == l.end.x:
					# s is to the right of l
					for x in range(l_center.x, s_center.x):
						grid[_as_key(Vector2(x, s_center.y))] = 1
					corridor_built = true
					break
				else:
					# s is to the left of  l
					for x in range(s_center.x, l_center.x):
						grid[_as_key(Vector2(x, s_center.y))] = 1
					corridor_built = true
					break
		if corridor_built:
			break
	return make_corridors(tree, parent, grid)


func _as_key(vector: Vector2):
	return str(int(vector.x), ",", int(vector.y))

func _key_as_vec(key: String):
	var parts = key.split(",")
	return Vector2(parts[0], parts[1])

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
			var vec = _key_as_vec(r)
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
