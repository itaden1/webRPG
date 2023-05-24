extends MeshInstance

export (float) var lod_1_dist = 800.0
export (float) var lod_2_dist = 1000.0

var lod_1_mesh = null
var lod_2_mesh = null
var player = null


var navmesh_generated := false
var timer := Timer.new()

func _ready():
	timer.wait_time = 1
	var _a = timer.connect("timeout", self, "check_lod")
	add_child(timer)
	timer.start()

	var _b: int = GameEvents.connect("terrain_generation_complete", self, "create_nav")

func create_nav():
	#TODO: work out how to do this effectively
	pass
	# if !navmesh_generated:
	# 	var navmesh: NavigationMeshInstance = get_parent()
	# 	navmesh.bake_navigation_mesh()
	# 	print(navmesh.navmesh.get_polygon_count())
	# 	navmesh_generated = true


func ready_for_lod():
	return lod_1_mesh != null and lod_2_mesh != null and player != null 

func finalize():
	mesh = lod_1_mesh
	create_trimesh_collision()

	mesh = lod_2_mesh
	check_lod()

func check_lod():
	if ready_for_lod():
		var distance = global_transform.origin.distance_to(
						player.global_transform.origin)


		if distance < lod_1_dist:
			visible = true
			mesh = lod_1_mesh

			# global_transform.origin.y = 0
		elif distance < lod_2_dist:
			visible = true
			mesh = lod_2_mesh
			# global_transform.origin.y = -10
		else:
			visible = false
