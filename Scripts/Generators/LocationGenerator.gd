extends Node

var test_town_scene = preload("res://Scenes/TestTown.tscn")


func generate_town():
	return {
		location_node = test_town_scene.instance(),
		location_padding = 100
	}


