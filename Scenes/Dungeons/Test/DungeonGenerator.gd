extends Spatial


const bpt_generator = preload("res://Scripts/Generators/BinaryPartitionTree.gd")

var dungeon_world_location_y := -2000
var spawn_point: Spatial

var test_dungeon_interior = preload("res://Scenes/Dungeons/Test/TestDungeonInterior.tscn")

var dungeon_interior_node: Spatial

func _ready():
	generate({width=20, height=20, partitions=15, padding=[2]})
# 	dungeon_interior_node.global_transform.origin.y = dungeon_world_location_y


func generate(params: Dictionary):
	var bpt = bpt_generator.new()
	var dungeon_rect: Rect2 = Rect2(Vector2(0, 0), Vector2(params.width, params.height))
	var tree = bpt.partition_rect(
		dungeon_rect,
		params.partitions,
		6,
		2,
		params.padding
	)

	var grid: Dictionary = {}
	for x in range(0, params.width):
		for y in range(0, params.height):
			grid[Vector2(x,y)] = 0

	var all_leaves = bpt.get_leaf_nodes(tree, tree.keys()[0])
	for l in all_leaves:
		for x in range(l.position.x, l.end.x):
			for y in range(l.position.y, l.end.y):
				grid[Vector2(x,y)] = 1

		# make connecting corridoors
		var sibling = bpt.get_sibling(tree, l)
		var sibling_center = sibling.get_center()
		var leaf_center = l.get_center()
		if sibling.position.x >= l.end.x:
			# sibling is to the right
			for x in range(leaf_center.x, sibling_center.x):
				grid[Vector2(x,sibling_center.y)] = 1
		elif sibling.end.x <= l.position.x:
			# sibling is to the left
			for x in range(sibling_center.x, leaf_center.x):
				grid[Vector2(x,leaf_center.y)] = 1
		elif sibling.end.y <= l.position.y:
			# sibling is above leaf
			for y in range(sibling_center.y, leaf_center.y):
				grid[Vector2(sibling_center.x, y)] = 1
		else:
			# sibling is below leaf
			for y in range(leaf_center.y, sibling_center.y):
				grid[Vector2(sibling_center.x, y)] = 1
	
	for r in grid.keys():
		if grid[r] == 1:
			var block = test_dungeon_interior.instance()
			block.transform.origin.x = r.x * 20
			block.transform.origin.z = r.y * 20
			add_child(block)

	spawn_point = Spatial.new()

	spawn_point.transform.origin = Vector3(5, 10, 5)
	add_child(spawn_point)

	# dungeon_interior_node = test_dungeon_interior.instance()
	# dungeon_interior_node.transform.origin.y = -5#dungeon_world_location_y

	# add_child(dungeon_interior_node)
	get_node("DungeonEntrance").exit = get_node("DungeonInterior/SpawnPoint")

