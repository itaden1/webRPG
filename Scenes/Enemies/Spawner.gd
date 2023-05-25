extends Spatial

export(float) var spawn_time = 20.0
export(PackedScene) var enemy_scene

onready var player = get_tree().root.get_node("World/Player")

var spawn_timer: Timer = Timer.new()
var spawned = false

var navigation_node: Navigation

func _ready():
	spawn_timer.wait_time = spawn_time
	add_child(spawn_timer)
	var _a: int = spawn_timer.connect("timeout", self, "spawn")
	spawn_timer.start()

func spawn():
	if can_spawn():
		var enemy_instance: KinematicBody = enemy_scene.instance()
		add_child(enemy_instance)
		var _r: int = enemy_instance.connect("tree_exited", self, "_on_enemy_exited_tree")
		spawned = true


func _on_enemy_exited_tree():
	spawned = false


func can_spawn():
	var distance_to_player: float = global_transform.origin.distance_to(player.global_transform.origin)
	return distance_to_player < 150 and distance_to_player > 10 and !spawned
		
