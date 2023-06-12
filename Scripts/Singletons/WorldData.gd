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
			kingdom_type: enum # what type of land this is and who is the ruler
			mesh_data: [], # list of vec3 vertex data
			shader: Resource # which shader to use, determines the textures on the map
			texture_data: {}, # dictionary <vec2, brush>
			objects: [], # array of dicts describing position, model/scene, rotation of trees etc.
			spawn_points: [] # describe above ground encounters
			is_above_water: True, # whether this node is above the sea/ below the sea
			biome_type: snow/ desert etc. etc
			locations : [
				layout: [
					{
						rect: Rect2,
						grid: [
							Dict<vec2: mask>
						]
					}
				],
				spawn_points: [],
				name:
				type: # town city dungeon cave etc. 
				...
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
		Vector2(10000, 10000),
		Vector2(1000, 1000),
		Vector2(50, 50),
		20,
		3
	)
	# print(world)
	

##############################################
#          Resources
##############################################
const corner_se_block = preload("res://Scenes/Towns/BuildingBlocks/Tudor/CornerSE001.tscn")
const corner_sw_block = preload("res://Scenes/Towns/BuildingBlocks/Tudor/CornerSW001.tscn")

const wall_ew_block = preload("res://Scenes/Towns/BuildingBlocks/Tudor/WallEW001.tscn")
const wall_ns_block = preload("res://Scenes/Towns/BuildingBlocks/Tudor/WallNS001.tscn")


const first_floor_corner_nw_block = preload("res://Scenes/Towns/BuildingBlocks/Tudor/UpperCornerNW001.tscn")
const first_floor_corner_sw_block = preload("res://Scenes/Towns/BuildingBlocks/Tudor/UpperCornerSW001.tscn")

const first_floor_wall_ns_block = preload("res://Scenes/Towns/BuildingBlocks/Tudor/UpperWallNS001.tscn")
const first_floor_wall_ew_block = preload("res://Scenes/Towns/BuildingBlocks/Tudor/UpperWallEW001.tscn")


const ground_floor = preload("res://Scenes/Towns/BuildingBlocks/Tudor/Floor001.tscn")
# const first_floor = preload("res://Scenes/Towns/BuildingBlocks/Tudor/FloorUpper001.tscn")
const floor_block = preload("res://Scenes/Towns/BuildingBlocks/Tudor/Floor001.tscn")

const roof_edge_block = preload("res://Scenes/Towns/BuildingBlocks/Tudor/Roof001.tscn")
const roof_corner_block_1 = preload("res://Scenes/Towns/BuildingBlocks/Tudor/RoofSECorner001.tscn")
const roof_corner_block_2 = preload("res://Scenes/Towns/BuildingBlocks/Tudor/RoofSWCorner001.tscn")

const roof_peak = preload("res://Scenes/Towns/BuildingBlocks/Tudor/RoofPeak001.tscn")
const roof_peak_wall = preload("res://Scenes/Towns/BuildingBlocks/Tudor/RoofPeakEdge001.tscn")

var house_themes = {
	Constants.CULTURES.TUDOR : {
		0 : {
			0 : {},
			1 : {scene=wall_ns_block, rotation=180},
			2 : {scene=wall_ew_block, rotation=180},
			3 : {scene=corner_se_block, rotation=0},
			4 : {scene=wall_ew_block, rotation=0},
			5 : {scene=corner_sw_block, rotation=180},
			6 : {},
			7 : {},
			8 : {scene=wall_ns_block, rotation=0},
			9 : {},
			10 : {scene=corner_sw_block, rotation=0},
			11 : {},
			12 : {scene=corner_se_block, rotation=180},
			13 : {},
			14 : {},
			15 : {}
		},
		1 : {
			0 : {},
			1 : {scene=first_floor_wall_ns_block, rotation=180},
			2 : {scene=first_floor_wall_ew_block, rotation=180},
			3 : {scene=first_floor_corner_nw_block, rotation=0},
			4 : {scene=first_floor_wall_ew_block, rotation=0},
			5 : {scene=first_floor_corner_sw_block, rotation=180},
			6 : {},
			7 : {},
			8 : {scene=first_floor_wall_ns_block, rotation=0},
			9 : {},
			10 : {scene=first_floor_corner_sw_block, rotation=0},
			11 : {},
			12 : {scene=first_floor_corner_nw_block, rotation=180},
			13 : {},
			14 : {},
			15 : {}
		},
		2 : {
			0 : {},
			1 : {scene=first_floor_wall_ns_block, rotation=180},
			2 : {scene=first_floor_wall_ew_block, rotation=180},
			3 : {scene=first_floor_corner_nw_block, rotation=0},
			4 : {scene=first_floor_wall_ew_block, rotation=0},
			5 : {scene=first_floor_corner_sw_block, rotation=180},
			6 : {},
			7 : {},
			8 : {scene=first_floor_wall_ns_block, rotation=0},
			9 : {},
			10 : {scene=first_floor_corner_sw_block, rotation=0},
			11 : {},
			12 : {scene=first_floor_corner_nw_block, rotation=180},
			13 : {},
			14 : {},
			15 : {}
		},
		"roof" : {# Roof
			0 : {scene=roof_peak, rotation=180},
			1 : {scene=roof_peak_wall, rotation=180},#
			2 : {scene=roof_edge_block, rotation=0},
			3 : {scene=roof_corner_block_2, rotation=0},
			4 : {scene=roof_edge_block, rotation=180},
			5 : {scene=roof_corner_block_1, rotation=180},
			6 : {},
			7 : {},
			8 : {scene=roof_peak_wall, rotation=0},#
			9 : {},
			10 : {scene=roof_corner_block_1, rotation=0},
			11 : {},
			12 : {scene=roof_corner_block_2, rotation=180},#
			13 : {},
			14 : {},
			15 : {}
		},
		"offsets": {horizontal = 10, vertical = 10}

	}
}
