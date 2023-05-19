extends Spatial


const bpt_generator = preload("res://Scripts/Generators/BinaryPartitionTree.gd")
var bpt = bpt_generator.new()

var dungeon_world_location_y := -2000

# spawn point for testing
onready var spawn_point: Spatial = get_node("SpawnPoint")

var test_dungeon_interior = preload("res://Scenes/Dungeons/Test/TestDungeonInterior.tscn")

var dungeon_interior_node: Spatial


func _ready():
	pass
	#generate({width=20, height=20, partitions=5, padding=[3], max_room_size=6, min_room_size=3})
# 	dungeon_interior_node.global_transform.origin.y = dungeon_world_location_y


func generate(params: Dictionary):
	#var bpt = bpt_generator.new()
	var dungeon_rect: Rect2 = Rect2(Vector2(0, 0), Vector2(params.width, params.height))
	var tree = bpt.partition_rect(
		dungeon_rect,
		params.partitions,
		params.max_room_size,
		params.min_room_size,
		params.padding
	)

	var dungeon_interior_node = Spatial.new()

	var spawn_vec: Vector2
	var offset = 20

	var grid: Dictionary = {}
	for x in range(0, params.width):
		for y in range(0, params.height):
			grid[_as_key(Vector2(x,y))] = 0

	var all_leaves = bpt.get_leaf_nodes(tree, tree.keys()[0])
	for l in all_leaves:
		for x in range(l.position.x, l.end.x):
			for y in range(l.position.y, l.end.y):
				grid[_as_key(Vector2(x,y))] = 1
				if !spawn_vec:
					spawn_vec = Vector2(x,y)
	#print(grid)
	for l in all_leaves:
		var corridor_grid = make_corridors(tree, l, {}, params.padding)

		for k in corridor_grid.keys():
			if grid[k] == 0:
				grid[k] = corridor_grid[k]

	for r in grid.keys():
		if grid[r] == 1:
			var vec = _key_as_vec(r)
			var block = test_dungeon_interior.instance()
			block.transform.origin.x = vec.x * offset
			block.transform.origin.z = vec.y * offset
			dungeon_interior_node.add_child(block)

	# for testing only! should not begin game at dungeon entrance
#	spawn_point = Spatial.new()
#	spawn_point
	
	
	var dungeon_interior_spawn = Position3D.new()
	dungeon_interior_spawn.transform.origin = Vector3(spawn_vec.x * offset, 15, spawn_vec.y * offset)

	dungeon_interior_node.transform.origin.y = dungeon_world_location_y
	dungeon_interior_node.add_child(dungeon_interior_spawn)
	
	add_child(dungeon_interior_node)
	get_node("DungeonEntrance").exit = dungeon_interior_spawn


func make_corridors(tree: Dictionary, branch: Rect2, grid: Dictionary, seen=[]):
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
