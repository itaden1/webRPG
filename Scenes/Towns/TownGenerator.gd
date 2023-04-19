extends Spatial

const bpt_generator = preload("res://Scripts/Generators/BinaryPartitionTree.gd")
const basic_block = preload("res://Scenes/Towns/BuildingBlocks/Generic/Block.tscn")

const offset := 6

func generate_town(params: Dictionary):
	var width: float = 12
	var height: float = 12
	var bpt = bpt_generator.new()
	var tree = bpt.partition_rect(
		Rect2(Vector2(0, 0), Vector2(width, height)),
		3,
		6,
		2,
		[3, 2]
	)
	for b in tree.keys():
		if tree[b].size() <= 0:
			build_house(b)


func build_house(rect: Rect2):

	for x in range(rect.position.x, rect.position.x + rect.size.x +1):
		for y in range(rect.position.y, rect.position.y + rect.size.y +1):
			var block = basic_block.instance()

			add_child(block)
			block.transform.origin.x = x * offset
			block.transform.origin.z = y * offset
			
	

