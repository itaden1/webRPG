extends Spatial

const bpt_generator = preload("res://Scripts/Generators/BinaryPartitionTree.gd")
const door_block = preload("res://Scenes/Towns/BuildingBlocks/Tudor/WallDoor001.tscn")
const corner_block = preload("res://Scenes/Towns/BuildingBlocks/Tudor/GroundfloorCornerWindow001.tscn")
const wall_block = preload("res://Scenes/Towns/BuildingBlocks/Tudor/GroundFloorWall001.tscn")

const first_floor_corner_block = preload("res://Scenes/Towns/BuildingBlocks/Tudor/WallCornerUpper002.tscn")
const first_floor_wall_block = preload("res://Scenes/Towns/BuildingBlocks/Tudor/UpperFloorWall001.tscn")

const ground_floor = preload("res://Scenes/Towns/BuildingBlocks/Tudor/Floor001.tscn")
const first_floor = preload("res://Scenes/Towns/BuildingBlocks/Tudor/FloorUpper001.tscn")
const blank_block = preload("res://Scenes/Towns/BuildingBlocks/Generic/Blank.tscn")


const utilities = preload("res://Scripts/Utilities.gd")

var Utilities

const offset := 8.5

var width: float
var height: float

var themes = {
	tudor = {
		0 : {
			0 : {},
			1 : {scene=wall_block, rotation=180},
			2 : {scene=wall_block, rotation=270},
			3 : {scene=corner_block, rotation=0},
			4 : {scene=wall_block, rotation=90},
			5 : {scene=corner_block, rotation=270},
			6 : {},
			7 : {},
			8 : {scene=wall_block, rotation=0},
			9 : {},
			10 : {scene=corner_block, rotation=90},
			11 : {},
			12 : {scene=corner_block, rotation=180},
			13 : {},
			14 : {},
			15 : {}
		},
		1 : {
			0 : {},
			1 : {scene=first_floor_wall_block, rotation=180},
			2 : {scene=first_floor_wall_block, rotation=270},
			3 : {scene=first_floor_corner_block, rotation=0},
			4 : {scene=first_floor_wall_block, rotation=90},
			5 : {scene=first_floor_corner_block, rotation=270},
			6 : {},
			7 : {},
			8 : {scene=first_floor_wall_block, rotation=0},
			9 : {},
			10 : {scene=first_floor_corner_block, rotation=90},
			11 : {},
			12 : {scene=first_floor_corner_block, rotation=180},
			13 : {},
			14 : {},
			15 : {}
		}
	}
}

func generate_town(params: Dictionary):
	Utilities = utilities.new()
	width = params.width
	height = params.height
	var bpt = bpt_generator.new()
	var tree = bpt.partition_rect(
		Rect2(Vector2(0, 0), Vector2(width, height)),
		params.partitions,
		6,
		2,
		params.padding
	)

	for b in tree.keys():
		if tree[b].size() <= 0:
			build_house(b)

func get_block(mask: int, style: String, level: int) -> Dictionary:
	var block = themes[style][level][mask]
	if block.keys().size() <= 0:
		block = {scene=blank_block, rotation=0}
	return block
	
func get_floor_block(key: int) -> PackedScene:
	if key == 0:
		return ground_floor
	else:
		return first_floor


func build_house(rect: Rect2):

	var floors = Rng.get_random_range(1,2)
	# var start_x = rect.position.x - width/2
	# var start_y = rect.position.y - height/2
	build_floor(rect, 0)
	if floors == 2:
		build_floor(rect, 1)
	# for x in range(start_x, start_x + rect.size.x):
	# 	for z in range(start_y, start_y + rect.size.y):
	# 		var mask = Utilities.get_four_bit_bitmask(rect, Vector2(x + width/2, z + height/2))

	# 		var block = get_block(mask)
	# 		var inst: Spatial = block.scene.instance()
	# 		inst.rotate(Vector3.UP, deg2rad(block.rotation))

	# 		add_child(inst)
	# 		inst.transform.origin.x = x * offset
	# 		inst.transform.origin.z = z * offset

			
func build_floor(rect: Rect2, level: int):
	var start_x = rect.position.x - width/2
	var start_y = rect.position.y - height/2
	var floor_block = get_floor_block(level)
	for x in range(start_x, start_x + rect.size.x):
		for z in range(start_y, start_y + rect.size.y):
			var floor_inst: Spatial = floor_block.instance()

			add_child(floor_inst)
			floor_inst.transform.origin.x = x * offset
			floor_inst.transform.origin.z = z * offset
			floor_inst.transform.origin.y = level * offset


			var mask = Utilities.get_four_bit_bitmask(rect, Vector2(x + width/2, z + height/2))

			var block = get_block(mask, "tudor", level)
			var inst: Spatial = block.scene.instance()
			inst.rotate(Vector3.UP, deg2rad(block.rotation))

			add_child(inst)
			inst.transform.origin.x = x * offset
			inst.transform.origin.z = z * offset
			inst.transform.origin.y = level * offset
