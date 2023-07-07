extends Node

enum LOCATION_TYPES {
	CITY,
	TOWN,
	FARM,
	VILLAGE
}

enum HOUSE_TYPES {
	COTTAGE,
	EMPTY,
	TRAINING_GROUND,
	BUILDING,
	TWO_STORY_BUILDING,
	THREE_STORY_BUILDING,
	TOWER,
	KEEP,
	FIELD
}

enum TILE_TYPES {
	BLOCKED,
	OPEN,
	EXIT
}

enum REGION_TYPES {
	DESERT,
	GRASSLAND,
	SNOW
}

enum CULTURES {
	TUDOR
}

enum BIOMES {
	TEMPERATE_DECIDUOUS_FOREST,
	SNOW_FORRESTS,
	SNOW_PLANES,
	GRASSLAND,
	WOODLANDS,
	SWAMP_LANDS,
	HIGH_ALTITUDE
}

enum DUNGEON_TYPES {
	CRYPT
}

## Splatmaps ##

const REB_BRUSH_1 = preload("res://Materials/SplatBrushes/red_brush_1.png")
const GREEN_BRUSH_1 = preload("res://Materials/SplatBrushes/green_brush_1.png")
const BLUE_BRUSH_1 = preload("res://Materials/SplatBrushes/blue_brush_1.png")

const BIOME_BRUSHES = {
	BIOMES.GRASSLAND: [REB_BRUSH_1],
	BIOMES.WOODLANDS: [REB_BRUSH_1, GREEN_BRUSH_1],
	BIOMES.SWAMP_LANDS: [GREEN_BRUSH_1],
	BIOMES.TEMPERATE_DECIDUOUS_FOREST: [GREEN_BRUSH_1],
	BIOMES.SNOW_FORRESTS: [BLUE_BRUSH_1],
	BIOMES.SNOW_PLANES: [BLUE_BRUSH_1],
	BIOMES.HIGH_ALTITUDE: [BLUE_BRUSH_1]
}

const REGION_MATERIALS = {
	REGION_TYPES.DESERT: preload("res://Materials/GrassLandsSplatMap.tres"),
	REGION_TYPES.GRASSLAND: preload("res://Materials/GrassLandsSplatMap.tres"), # TODO new splatmaps
	REGION_TYPES.SNOW: preload("res://Materials/GrassLandsSplatMap.tres")

}

## Trees / rocks / grass
const BIOME_OBJECTS = {
	BIOMES.GRASSLAND : [
		{		
			obj=preload("res://Scenes/NatureObjects/GrassBushFall.tscn"),
			chance=70
		},
		{		
			obj=preload("res://Scenes/NatureObjects/Tree03summerSmall.tscn"),
			chance=1
		}
	],
	BIOMES.WOODLANDS : [
		{		
			obj=preload("res://Scenes/NatureObjects/GrassBushFall.tscn"),
			chance=70
		},
		{		
			obj=preload("res://Scenes/NatureObjects/Tree03summerSmall.tscn"),
			chance=20
		}
	],
	BIOMES.SWAMP_LANDS : [
		{		
			obj=preload("res://Scenes/NatureObjects/Tree01summer.tscn"),
			chance=30
		},
		{		
			obj=preload("res://Scenes/NatureObjects/Tree03summerSmall.tscn"),
			chance=5
		}
	],
	BIOMES.TEMPERATE_DECIDUOUS_FOREST : [
		{		
			obj=preload("res://Scenes/NatureObjects/Tree01summer.tscn"),
			chance=80
		},
		{		
			obj=preload("res://Scenes/NatureObjects/Tree03summer.tscn"),
			chance=19
		}
	],
	BIOMES.SNOW_FORRESTS : [
		{		
			obj=preload("res://Scenes/NatureObjects/Tree08winter.tscn"),
			chance=90
		},
		{		
			obj=preload("res://Scenes/NatureObjects/Stone01Large.tscn"),
			chance=1
		}
	],
	BIOMES.SNOW_PLANES : [
		{		
			obj=preload("res://Scenes/NatureObjects/Tree08winter.tscn"),
			chance=10
		},
		{		
			obj=preload("res://Scenes/NatureObjects/Stone01Large.tscn"),
			chance=1
		},

	],
	BIOMES.HIGH_ALTITUDE : [
		{		
			obj=preload("res://Scenes/NatureObjects/Stone01Large.tscn"),
			chance=1
		}
	]	
}



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

var HOUSE_THEMES = {
	CULTURES.TUDOR : {
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


###################################################
#          Dungeon resources                       
###################################################

var wall_block = preload("res://Scenes/Dungeons/Test/DungeonWall.tscn")
var corner_block = preload("res://Scenes/Dungeons/Test/DungeonWallCorner.tscn")
var corridor_block = preload("res://Scenes/Dungeons/Test/DungeonCorridor.tscn")

const blank_block = preload("res://Scenes/Towns/BuildingBlocks/Generic/Blank.tscn")


var DUNGEON_THEMES = {
	DUNGEON_TYPES.CRYPT: {
		0 : {
			0 : {},
			1 : {scene=wall_block, rotation=270},
			2 : {scene=wall_block, rotation=0},
			3 : {scene=corner_block, rotation=270},
			4 : {scene=wall_block, rotation=180},
			5 : {scene=corner_block, rotation=180},
			6 : {scene=corridor_block, rotation=180},
			7 : {},
			8 : {scene=wall_block, rotation=90},
			9 : {scene=corridor_block, rotation=90},
			10 : {scene=corner_block, rotation=0},
			11 : {},
			12 : {scene=corner_block, rotation=90},
			13 : {},
			14 : {},
			15 : {}
		}
	}
}
