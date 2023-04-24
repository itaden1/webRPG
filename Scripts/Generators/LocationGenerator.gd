extends Node


var test_town_scene = preload("res://Scenes/Towns/TestTown.tscn")
var town_scene = preload("res://Scenes/Towns/Town.tscn")

func generate_location():
	return generate_town()


func generate_town():
	var town_node = town_scene.instance()
	town_node.generate_town({width=18, height=18, partitions=10, padding=[3,2,2,1]})

	return {
		location_node = town_node,
		location_padding = 140
	}


