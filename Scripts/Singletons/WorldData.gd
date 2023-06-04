extends Node


const terrain_generator = preload("res://Scripts/Generators/TerrainDataGenerator.gd")

"""
world: {
	seed: 123,
	terrain_noise: SimplexNoise,
	precipitation_noise: SimplexNoise
	size: Vec2,
	chunks: [
		{
			position: vec2, # where this chunk is placed in the world
			mesh_data: [], # list of vec3 vertex data
			shader: Resource # which shader to use, determines the textures on the map
			texture_data: {}, # dictionary <vec2, brush>
			objects: [], # array of dicts describing position, model/scene, rotation of trees etc.
			spawn_points: [] # describe above ground encounters
			is_above_water: True, # whether this node is above the sea/ below the sea
			biome_type: snow/ desert etc. etc
		}
	]
}

"""

var world := {}

func _ready():
	pass # Replace with function body.


func generate_world():
	var generator = terrain_generator.new()
	world = generator.build_world(
		Vector2(4000, 4000),
		Vector2(1000, 1000),
		Vector2(60, 60),
		40,
		3
	)
	print(world)
