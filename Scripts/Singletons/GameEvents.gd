extends Node

signal terrain_generation_complete


########################################
#          PlayerState
#
########################################
signal player_spawned(player)
signal player_entered_dungeon(player)
signal player_took_damage(damage_type)
signal player_died

########################################
#               Dialogue
#
########################################

signal npc_emitted_dialogue(npc, text)


signal enemy_slain
