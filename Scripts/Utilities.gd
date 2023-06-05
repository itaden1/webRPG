extends Node


func _init():
	._init()
	if not OS.has_feature("standalone") or OS.is_debug_build():
		_run_tests()

var four_bit_mask_offsets = {
		Vector2(0, -1): 1,
		Vector2(-1, 0): 2,
		Vector2(1, 0): 4,
		Vector2(0, 1): 8
	}

func get_four_bit_bitmask_from_grid(grid: Dictionary, tile: Vector2):
	return get_bitmask_from_grid(grid, tile, four_bit_mask_offsets)


func get_bitmask_from_grid(grid: Dictionary, tile: Vector2, values: Dictionary) -> int:
	var accumulation = 0
	for v in values.keys():
		var vec_to_check = Vector2(tile + v)
		var key = str(int(vec_to_check.x), ",", int(vec_to_check.y))
		if grid.has(key):
			if grid[key] == 0:
				accumulation += values[v]
		else:
			# not on grid is the same as a wall
			accumulation += values[v]

	return accumulation


func get_four_bit_bitmask_from_rect(rect: Rect2, tile: Vector2) -> int:
	return get_bitmask_from_rect(rect, tile, four_bit_mask_offsets)


func get_bitmask_from_rect(rect: Rect2, tile: Vector2, values: Dictionary) -> int:
	var accumulation = 0
	for v in values.keys():
		var rect_to_check = Rect2(tile + v, Vector2(1, 1))
		if not rect.intersects(rect_to_check):
			accumulation += values[v]
	return accumulation

func _run_tests():
	_test_four_bit_mask()

func _test_four_bit_mask():
	var rect = Rect2(Vector2(1, 1), Vector2(6, 6))
	var result = get_four_bit_bitmask_from_rect(rect, Vector2(2, 2))
	var message = "Expected 0, got %s"
	assert(result == 0, message % result)

	var rect2 = Rect2(Vector2(1, 1), Vector2(6, 6))
	var result2 = get_four_bit_bitmask_from_rect(rect2, Vector2(1, 1))
	var message2 = "Expected 3, got %s"
	assert(result2 == 3, message2 % result2)

	var rect3 = Rect2(Vector2(1, 1), Vector2(1, 1))
	var result3 = get_four_bit_bitmask_from_rect(rect3, Vector2(1, 1))
	var message3 = "Expected 15, got %s"
	assert(result3 == 15, message3 % result3)

	var rect4 = Rect2(Vector2(1, 1), Vector2(1, 1))
	var result4 = get_four_bit_bitmask_from_rect(rect4, Vector2(1, 1))
	var message4 = "Expected 15, got %s"
	assert(result4 == 15, message4 % result4)

	var rect5 = Rect2(Vector2(1, 1), Vector2(3, 3))
	var result5 = get_four_bit_bitmask_from_rect(rect5, Vector2(2, 3))
	var message5 = "Expected 8, got %s"
	assert(result5 == 8, message5 % result5)



func get_rect_difference(first_rect: Rect2, second_rect: Rect2) -> Vector2:
	# get the difference in size between 2 Rect2's.
	return Vector2(
		abs(first_rect.size.x - second_rect.size.x),
		abs(first_rect.size.y - second_rect.size.y)
	)


func normalize_to_zero_one_range(num: float):
	# get the value of num as a value between 0 - 1
	var max_num = 1
	var min_num = -1
	return (num - min_num) / (max_num - min_num)


func euclidean_squared_distance(x: float, y: float, width: float, height: float) -> float:
	# gets the euclidean squared distance from the vertex to the map border
	
	var nx = 2 * x/width - 1
	var ny = 2 * y/height - 1
	
	var distance = min(1, (pow(nx, 2) + pow(ny, 2)) / sqrt(2))

	return distance


func get_datatool_for_mesh(mesh: Mesh) -> MeshDataTool:
	# given a mesh return mesh data tool to edit it
	var st := SurfaceTool.new()
	st.create_from(mesh,0)
	var array_mesh : ArrayMesh = st.commit()
	
	var dt := MeshDataTool.new()
	var _a = dt.create_from_surface(array_mesh, 0)
	return dt


# A lot of the generation queries dictionaries with vector2
# These 2 functions facilitate transforming a vec2 into a string(key) and vice versa
func vec_as_key(vector: Vector2):
	return str(int(vector.x), ",", int(vector.y))

func key_as_vec(key: String):
	var parts = key.split(",")
	return Vector2(parts[0], parts[1])
