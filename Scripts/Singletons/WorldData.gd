extends Node


var terrain_generator: Script = load("res://Scripts/Generators/TerrainDataGenerator.gd")

"""
world: {
	seed: 123,
	terrain_noise: SimplexNoise,
	precipitation_noise: SimplexNoise
	size: Vec2,
	chunk_size: Vec2,
	chunk_divisions: Vec2
	chunks: [
		{
			position: vec2, # where this chunk is placed in the world
			kingdom_type: enum # what type of land this is and who is the ruler
			mesh_data: [], # list of vec3 vertex data
			shader: Resource # which shader to use, determines the textures on the map
			texture_data: {}, # dictionary <vec2, brush>
			objects: [], # array of dicts describing position, model/scene, rotation of trees etc.
			spawn_points: [] # describe above ground encounters
			is_above_water: True, # whether this node is above the sea/ below the sea
			biome_type: snow/ desert etc. etc
			locations : [
					{
						position: vec3,
						width=float,
						height=float,
						culture=int,
						type=int,
						name=String
						layout={
							buildings: Array [
								{
									rect=Rect2, 
									type=int, 
									culture=int
									grid=Array<Dictionary>
								}
							],
							grid: Array<Array<int>>
							spawn_points: Array<Vec2/3>
						}
					}
			]
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
		Vector2(15000, 15000),
		Vector2(1000, 1000),
		Vector2(16, 16),
		20,
		3
	)
	# print(world)
	


