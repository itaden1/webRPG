extends Node


var test_dungeon_scene = preload("res://Scenes/Dungeons/Test/TestDungeon.tscn")
var town_scene = preload("res://Scenes/Towns/Town.tscn")

func generate_location():
	# return generate_dungeon()
	if Rng.get_random_range(0,10) <= 2: 
		return generate_town()
	else:
		return generate_dungeon()


func generate_town():
	var town_node = town_scene.instance()
	town_node.generate({width=10, height=10, partitions=10, padding=[3,2,1], number_of_npcs=7})

	return {
		location_node = town_node,
		location_padding = 130
	}


func generate_dungeon():
	var dungeon_node_root = test_dungeon_scene.instance()
	var dungeon_node = dungeon_node_root.get_node("NavigationMeshInstance/Dungeon")
	dungeon_node.generate({width=15, height=15, partitions=15, padding=[1], max_room_size=6, min_room_size=3})
	return {
		location_node = dungeon_node_root,
		location_padding = 50
	}	
