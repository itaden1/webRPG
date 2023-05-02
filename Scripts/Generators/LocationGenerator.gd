extends Node


var test_town_scene = preload("res://Scenes/Towns/TestTown.tscn")
var town_scene = preload("res://Scenes/Towns/Town.tscn")

func generate_location():
	return generate_town()


func generate_town():
	var town_node = town_scene.instance()
	town_node.generate_town({width=12, height=12, partitions=10, padding=[3,2,1,1]})

	return {
		location_node = town_node,
		location_padding = 140
	}


