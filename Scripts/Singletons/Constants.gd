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
