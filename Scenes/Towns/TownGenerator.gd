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

const roof_edge_block = preload("res://Scenes/Towns/BuildingBlocks/Tudor/RoofEdge001.tscn")
const roof_corner_block_1 = preload("res://Scenes/Towns/BuildingBlocks/Tudor/RoofCornerNE001.tscn")
const roof_corner_block_2 = preload("res://Scenes/Towns/BuildingBlocks/Tudor/RoofCornerSE001.tscn")

const roof_peak = preload("res://Scenes/Towns/BuildingBlocks/Tudor/RoofPeak001.tscn")
const roof_peak_wall = preload("res://Scenes/Towns/BuildingBlocks/Tudor/RoofPeakWall001.tscn")


const utilities = preload("res://Scripts/Utilities.gd")

# const test_placement_scene = preload("res://Scenes/Towns/BuildingBlocks/Generic/TestPlacement.tscn")

var Utilities

var spawn_point: Spatial

var level_offsets := {
	tudor = {
		0: {horizontal = 8.25, vertical = 0},
		1: {horizontal = 9.8, vertical = 9},
		"default": {horizontal = 9.8, vertical = 9}
	}
}
func get_level_offset(key: String, level: int) -> Dictionary:
	if level_offsets.has(key):
		if level_offsets[key].has(level):
			return level_offsets[key][level]
	return level_offsets["tudor"]["default"]

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
			3 : {scene=first_floor_corner_block, rotation=270},
			4 : {scene=first_floor_wall_block, rotation=90},
			5 : {scene=first_floor_corner_block, rotation=180},
			6 : {},
			7 : {},
			8 : {scene=first_floor_wall_block, rotation=0},
			9 : {},
			10 : {scene=first_floor_corner_block, rotation=0},
			11 : {},
			12 : {scene=first_floor_corner_block, rotation=90},
			13 : {},
			14 : {},
			15 : {}
		},
		"roof" : {# Roof
			0 : {scene=roof_peak, rotation=0},
			1 : {scene=roof_peak_wall, rotation=0},#
			2 : {scene=roof_edge_block, rotation=180},
			3 : {scene=roof_corner_block_2, rotation=180},
			4 : {scene=roof_edge_block, rotation=0},
			5 : {scene=roof_corner_block_1, rotation=0},
			6 : {},
			7 : {},
			8 : {scene=roof_peak_wall, rotation=180},#
			9 : {},
			10 : {scene=roof_corner_block_1, rotation=180},
			11 : {},
			12 : {scene=roof_corner_block_2, rotation=0},#
			13 : {},
			14 : {},
			15 : {}
		}
	}
}

func _init():
	._init()
	Utilities = utilities.new()


func generate_town(params: Dictionary):
	width = params.width
	height = params.height
	var town_rect: Rect2 = Rect2(Vector2(0, 0), Vector2(width, height))
	var bpt = bpt_generator.new()
	var tree = bpt.partition_rect(
		town_rect,
		params.partitions,
		6,
		2,
		params.padding
	)

	for b in tree.keys():
		if tree[b].size() <= 0:
			build_house(b)

	# Place player spawn point at center of main street (or edge of the first partition)
	var first_partition: Rect2 = tree[tree.keys()[0]][0]
	spawn_point = Spatial.new()

	var offset_rect_pos_x = first_partition.end.x + 2 - width/2
	var offset_rect_pos_y = (first_partition.end.y - first_partition.size.y/2) - height/2
	spawn_point.transform.origin = Vector3(offset_rect_pos_x * 8, 1, offset_rect_pos_y * 8)
	add_child(spawn_point)

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
	
func get_floor_block(key: int) -> PackedScene:
	if key == 0:
		return ground_floor
	else:
		return first_floor


func build_house(rect: Rect2):

	var floors = Rng.get_random_range(1,2)

	var first_floor: Spatial = build_floor(rect, "tudor", 0)
	add_child(first_floor)
	if floors == 2:
		var second_floor: Spatial = build_floor(rect, "tudor", 1)
		## Attempt to keep both floors inline even if size is different
		var rect_diff = Utilities.get_rect_difference(
			rect.grow(level_offsets["tudor"][1].horizontal),
			rect.grow(level_offsets["tudor"][0].horizontal)
		)
		second_floor.transform.origin.x = first_floor.transform.origin.x - rect_diff.x/2
		second_floor.transform.origin.z = first_floor.transform.origin.z - rect_diff.y/2
		add_child(second_floor)
	
	var roof = build_roof(rect, "tudor", floors)
	var rect_diff = Utilities.get_rect_difference(
			rect.grow(get_level_offset("tudor", 1).horizontal),
			rect.grow(get_level_offset("tudor", 0).horizontal)
	)
	roof.transform.origin.x = first_floor.transform.origin.x - rect_diff.x/2
	roof.transform.origin.z = first_floor.transform.origin.z - rect_diff.y/2
	add_child(roof)

func build_roof(rect: Rect2, style: String, level: int):
	var offsets = get_level_offset(style, level)
	var base_node = Spatial.new()
	var rect_center = rect.get_center()

	var start_x = rect_center.x - width/2
	var start_y = rect_center.y - height/2

	base_node.transform.origin.x = start_x * offsets.horizontal
	base_node.transform.origin.z = start_y * offsets.horizontal
	base_node.transform.origin.y = level * offsets.vertical
	for x in range(0, rect.size.x):
		for z in range(0, rect.size.y):

			var mask = Utilities.get_four_bit_bitmask(rect, Vector2(rect.position.x+x, rect.position.y+z))

			var block = get_block(mask, style, 10)
			var inst: Spatial = block.scene.instance()
			inst.rotate(Vector3.UP, deg2rad(block.rotation))

			base_node.add_child(inst)
			inst.transform.origin.x = x * offsets.horizontal
			inst.transform.origin.z = z * offsets.horizontal
	
	return base_node


func build_floor(rect: Rect2, style: String, level: int) -> Spatial:
	var offsets = level_offsets[style][level]

	var base_node = Spatial.new()
	var rect_center = rect.get_center()

	var start_x = rect_center.x - width/2
	var start_y = rect_center.y - height/2

	base_node.transform.origin.x = start_x * offsets.horizontal
	base_node.transform.origin.z = start_y * offsets.horizontal
	base_node.transform.origin.y = level * offsets.vertical

	var floor_block = get_floor_block(level)
	for x in range(0, rect.size.x):
		for z in range(0, rect.size.y):
			var floor_inst: Spatial = floor_block.instance()

			base_node.add_child(floor_inst)
			floor_inst.transform.origin.x = x * offsets.horizontal
			floor_inst.transform.origin.z = z * offsets.horizontal


			var mask = Utilities.get_four_bit_bitmask(rect, Vector2(rect.position.x+x, rect.position.y+z))

			var block = get_block(mask, style, level)
			var inst: Spatial = block.scene.instance()
			inst.rotate(Vector3.UP, deg2rad(block.rotation))

			base_node.add_child(inst)
			inst.transform.origin.x = x * offsets.horizontal
			inst.transform.origin.z = z * offsets.horizontal
	
	return base_node
