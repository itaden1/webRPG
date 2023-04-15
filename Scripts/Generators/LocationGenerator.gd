extends Node


var test_town_scene = preload("res://Scenes/Towns/TestTown.tscn")


func generate_location():
	return generate_town()


func generate_town():
	return {
		location_node = test_town_scene.instance(),
		location_padding = 100
	}


