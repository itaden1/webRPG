extends Spatial

export(PackedScene) var tree_scene = load("res://Scenes/Tree01.tscn")

func _ready():
	var _a = GameEvents.connect("terrain_generation_complete", self, "place_trees")


func place_trees():

	var tree_inst = tree_scene.instance()		
	add_child(tree_inst)


	return
	var space_state: PhysicsDirectSpaceState = get_world().direct_space_state
	var from = global_transform.origin
	var to = Vector3(from.x, -200, from.z)

	var result = space_state.intersect_ray(from, to, [self])
	if result.has("position"):
		var tree_position = result.position
		get_tree().root.get_node("World").add_child(tree_inst)
		# add_child(tree_inst)
		tree_inst.global_transform.origin = tree_position
	
