extends Spatial

const bpt_generator = preload("res://Scripts/Generators/BinaryPartitionTree.gd")

func _ready():

	pass # Replace with function body.

func generate_town(params: Dictionary):
	var width: float = 40
	var height: float = 40
	var bpt = bpt_generator.new()
	var tree = bpt.partition_rect(
		Rect2(Vector2(0, 0), Vector2(width, height)),
		4,
		4,
		6,
		2
	)
	print(tree)

