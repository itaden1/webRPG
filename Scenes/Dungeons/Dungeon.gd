extends Spatial

signal generation_complete(entrance)

var dungeon_world_location_y := -500

const utilities = preload("res://Scripts/Utilities.gd")
var Utilities


var data: Dictionary
var offset: float

# var wall_block = preload("res://Scenes/Dungeons/Test/DungeonWall.tscn")
# var corner_block = preload("res://Scenes/Dungeons/Test/DungeonWallCorner.tscn")
# var corridor_block = preload("res://Scenes/Dungeons/Test/DungeonCorridor.tscn")
var floor_block = preload("res://Scenes/Dungeons/Test/DungeonFloor.tscn")

# const blank_block = preload("res://Scenes/Towns/BuildingBlocks/Generic/Blank.tscn")


var exit_scene = load("res://Scenes/Dungeons/Test/Entrance.tscn")

var outdoor_environment = preload("res://Environments/World.tres")
var indoor_environment = preload("res://Environments/Dungeon.tres")

var dungeon_interior_node: Spatial

var spawn_scene = preload("res://Scenes/Enemies/Spawner.tscn")

onready var navmesh_node: NavigationMeshInstance = get_node("NavigationMeshInstance")


func _init():
	._init()
	Utilities = utilities.new()
	
func _ready():
	pass


func add_dungeon_to_world():
	var node: Spatial = build_dungeon()
	transform.origin.y = dungeon_world_location_y
	navmesh_node.add_child(node)
	navmesh_node.bake_navigation_mesh(false)

	var exit: Spatial =	exit_scene.instance()
	exit.transform.origin = Vector3(
		data.exit.x * offset,
		0,
		data.exit.y * offset
	)
	node.add_child(exit)
	emit_signal("generation_complete", exit)

func get_block(mask: int, style: int, level: int):
	var level_style = Constants.DUNGEON_THEMES[style]
	var block: Dictionary
	if level_style.has(level):
		block = Constants.DUNGEON_THEMES[style][level][mask]
	else:
		block = Constants.DUNGEON_THEMES[style]["roof"][mask]


	if block.keys().size() <= 0:
		return
	return block


func build_dungeon() -> Spatial:
	var base_node = Spatial.new()

	for r in data.layout.keys():
		# if grid[r] == 1:

		var vec = Utilities.key_as_vec(r)
		var f_block = floor_block.instance()
		f_block.transform.origin.x = vec.x * offset
		f_block.transform.origin.z = vec.y * offset
		base_node.add_child(f_block)
		# var mask = Utilities.get_four_bit_bitmask_from_grid(grid, vec)


		# roof
		var r_block = floor_block.instance()
		r_block.transform.origin.x = vec.x * offset
		r_block.transform.origin.z = vec.y * offset
		r_block.transform.origin.y = 10
		base_node.add_child(r_block)
		
		var block = get_block(data.layout[r], Constants.DUNGEON_TYPES.CRYPT, 0)
		
		if block == null:
			continue


		var inst: Spatial = block.scene.instance()
		inst.rotate(Vector3.UP, deg2rad(block.rotation))


		base_node.add_child(inst)
		inst.transform.origin.x = vec.x * offset
		inst.transform.origin.z = vec.y * offset



	return base_node
