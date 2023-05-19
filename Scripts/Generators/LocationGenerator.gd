extends Node


var test_dungeon_scene = preload("res://Scenes/Dungeons/Test/TestDungeon.tscn")
var town_scene = preload("res://Scenes/Towns/Town.tscn")

func generate_location():
	if Rng.get_random_range(0,3) == 0: 
		return generate_town()
	else:
		return generate_dungeon()


func generate_town():
	var town_node = town_scene.instance()
	town_node.generate({width=10, height=10, partitions=10, padding=[3,2,1], number_of_npcs=5})

	return {
		location_node = town_node,
		location_padding = 140
	}


func generate_dungeon():
	var dungeon_node = test_dungeon_scene.instance()
	dungeon_node.generate({width=20, height=20, partitions=15, padding=[1], max_room_size=6, min_room_size=3})
	return {
		location_node = dungeon_node,
		location_padding = 90
	}	
