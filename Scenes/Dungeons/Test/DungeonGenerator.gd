extends Spatial


const bpt_generator = preload("res://Scripts/Generators/BinaryPartitionTree.gd")

var dungeon_world_location_y := -2000
var spawn_point: Spatial

var test_dungeon_interior = preload("res://Scenes/Dungeons/Test/TestDungeonInterior.tscn")

var dungeon_interior_node: Spatial

func _ready():
	dungeon_interior_node.global_transform.origin.y = dungeon_world_location_y


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
			
	for b in tree.keys():
		if tree[b].size() <= 0:
			for x in range(b.position.x, b.end.x):
				for y in range(b.position.y, b.end.y):
					grid[Vector2(x,y)] = 1
			for p in tree.keys():
				if tree[p].has(b):
					print("make coriddor between (", tree[p][0], ")-(", tree[p][1], ")")

	spawn_point = Spatial.new()

	spawn_point.transform.origin = Vector3(5, 10, 5)
	add_child(spawn_point)

	dungeon_interior_node = test_dungeon_interior.instance()
	add_child(dungeon_interior_node)
	get_node("DungeonEntrance").exit = get_node("DungeonInterior/SpawnPoint")

