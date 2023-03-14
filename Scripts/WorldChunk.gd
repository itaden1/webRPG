extends MeshInstance

export (float) var lod_1_dist = 800.0
export (float) var lod_2_dist = 1000.0

var lod_1_mesh = null
var lod_2_mesh = null
var player = null

var timer := Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	mesh = lod_1_mesh
	create_trimesh_collision()
	mesh = lod_2_mesh

	check_lod()

	timer.wait_time = 1
	var _a = timer.connect("timeout", self, "check_lod")
	add_child(timer)
	timer.start()

func ready_for_lod():
	return lod_1_mesh != null and lod_2_mesh != null and player != null 


func check_lod():
	if ready_for_lod():
		var distance = global_transform.origin.distance_to(
						player.global_transform.origin)
		if distance < lod_1_dist:
			visible = true
			mesh = lod_1_mesh
		elif distance < lod_2_dist:
			visible = true
			mesh = lod_2_mesh
		else:
			visible = false
