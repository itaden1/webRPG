extends Spatial

export(float) var spawn_time = 20.0
export(PackedScene) var enemy_scene

var player: KinematicBody

var spawn_timer: Timer = Timer.new()
var spawned = false

var navigation_node: Navigation

func _ready():

	spawn_timer.wait_time = spawn_time
	add_child(spawn_timer)
	var _a: int = spawn_timer.connect("timeout", self, "spawn")
	spawn_timer.start()

	var _b = GameEvents.connect("player_entered_dungeon", self, "set_player_instance")


func set_player_instance(player_inst: KinematicBody):
	player = player_inst
	spawn()

func spawn():
	if can_spawn():
		var enemy_instance: KinematicBody = enemy_scene.instance()
		add_child(enemy_instance)
		var _r: int = enemy_instance.connect("tree_exited", self, "_on_enemy_exited_tree")
		spawned = true


func _on_enemy_exited_tree():
	spawned = false


func can_spawn():
	if player != null:
		var distance_to_player: float = global_transform.origin.distance_to(player.global_transform.origin)
		return distance_to_player < 150 and distance_to_player > 10 and !spawned
	return false
		
