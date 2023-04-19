extends Spatial

const bpt_generator = preload("res://Scripts/Generators/BinaryPartitionTree.gd")
const basic_block = preload("res://Scenes/Towns/BuildingBlocks/Generic/Block.tscn")

const offset := 8

func generate_town(params: Dictionary):
	var width: float = 12
	var height: float = 12
	var bpt = bpt_generator.new()
	var tree = bpt.partition_rect(
		Rect2(Vector2(0, 0), Vector2(width, height)),
		6,
		6,
		2,
		[3, 2]
	)
	for b in tree.keys():
		if tree[b].size() <= 0:
			build_house(b)


func build_house(rect: Rect2):

	# debug colours
	# var colours = [
	# 	Color(255, 0, 0), Color(0, 255, 0), Color(0, 0, 255),
	# 	Color(200, 100, 0), Color(0, 200, 100), Color(100, 0, 200)
	# ]
	# var material = SpatialMaterial.new()
	# material.albedo_color = colours[rand_range(0, colours.size())]

	var floors = Rng.get_random_range(1,2)
	for y in range(floors):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			for z in range(rect.position.y, rect.position.y + rect.size.y):
				var block = basic_block.instance()

				# block.material_override = material

				add_child(block)
				block.transform.origin.x = x * offset #+ rand_range(0, 0.4)
				block.transform.origin.z = z * offset #+ rand_range(0, 0.4)
				block.transform.origin.y += y * offset#+ rand_range(0, 0.4)

			
	

