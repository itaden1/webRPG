extends Spatial

export(PackedScene) var tree_scene = load("res://Scenes/Tree01.tscn")

func _ready():
	var _a = GameEvents.connect("terrain_generation_complete", self, "place_trees")


func place_trees():

	var tree_inst = tree_scene.instance()		
	add_child(tree_inst)

