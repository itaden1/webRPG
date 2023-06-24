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

enum KINGDOM_TYPES {
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
			chance=30
		},
		{		
			obj=preload("res://Scenes/NatureObjects/GrassBushFall.tscn"),
			chance=1
		},
		{		
			obj=preload("res://Scenes/NatureObjects/Tree03summer.tscn"),
			chance=34
		},
		{		
			obj=preload("res://Scenes/NatureObjects/Tree03summerSmall.tscn"),
			chance=35
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
