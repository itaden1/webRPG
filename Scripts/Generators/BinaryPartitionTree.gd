extends Node


var graph: Dictionary
var rects: Array


func _init():
	._init()
	if not OS.has_feature("standalone") or OS.is_debug_build():
		_run_tests()

func partition_rect(
	rect: Rect2, 
	max_partitions: int, 
	max_room_size: int,
	min_room_size: int,
	padding: Array = [0],
	current_partition: int = 0
):

	graph[rect] = []

	if current_partition >= max_partitions:
		rects.append(rect)
		return

	var partition_directions = ["v", "h"]
	var padd = padding[padding.size()-1] # Default to the last value
	if current_partition <= padding.size() - 1:
		padd = padding[current_partition]

	# check if further split possible
	var direction = partition_directions[Rng.get_random_range(0,1)]
	if int(ceil(rect.size.x/2 - padd)) < min_room_size and int(ceil(rect.size.y/2 - padd)) < min_room_size:
		rects.append(rect)
		return
	elif int(ceil(rect.size.x/2 - padd)) < min_room_size:
		direction = "h"
	elif int(ceil(rect.size.y/2 - padd)) < min_room_size:
		direction = "v"

	if direction == "v":
		var left_partition_width = Rng.get_random_range(min_room_size, rect.size.x - min_room_size - padd)
		var right_partition_width = rect.size.x - left_partition_width - padd
		var new_rect_1 = Rect2(Vector2(rect.position.x, rect.position.y), Vector2(left_partition_width, rect.size.y))
		var new_rect_2 = Rect2(Vector2(rect.position.x + rect.size.x - right_partition_width, rect.position.y), Vector2(right_partition_width, rect.size.y))

		graph[rect].append(new_rect_1)
		graph[rect].append(new_rect_2)

		partition_rect(
			new_rect_1, 
			max_partitions, 
			max_room_size, 
			min_room_size,
			padding,
			current_partition + 1
		)

		partition_rect(
			new_rect_2, 
			max_partitions, 
			max_room_size, 
			min_room_size,
			padding,
			current_partition + 1
		)

	else:
		var top_partition_height = Rng.get_random_range(min_room_size, rect.size.y - min_room_size - padd)
		var bottom_partition_height = rect.size.y - top_partition_height - padd
		var new_rect_1 = Rect2(Vector2(rect.position.x, rect.position.y), Vector2(rect.size.x, top_partition_height))
		var new_rect_2 = Rect2(Vector2(rect.position.x, rect.position.y + rect.size.y - bottom_partition_height), Vector2(rect.size.x, bottom_partition_height))

		graph[rect].append(new_rect_1)
		graph[rect].append(new_rect_2)

		partition_rect(
			new_rect_1, 
			max_partitions, 
			max_room_size, 
			min_room_size,
			padding,
			current_partition + 1
		)

		partition_rect(
			new_rect_2, 
			max_partitions, 
			max_room_size, 
			min_room_size,
			padding,
			current_partition + 1
		)

	return graph

###########################################################
# Helper functions for working with a generated bpt graph #
###########################################################

func get_leaf_nodes(bpt_graph: Dictionary, branch: Rect2) -> Array:
	"""
	Return a list of all leaf nodes of the BPT graph from a given branch

	Params:
		graph(Dictionary): The graph we are searching in
		branch(Rect2): The branch whos leaves we are looking for
	Returns:
		Array<Rect2>

	"""
	if bpt_graph[branch].size() == 0:
		# we are the only leaf
		return [branch]

	var children=[]
	for child in bpt_graph[branch]:
		if bpt_graph[child].size() == 0:
			children.append(child)
		else:
			children += get_leaf_nodes(bpt_graph, child)
	return children

func get_parent_node(bpt_graph: Dictionary, branch: Rect2):
	"""
	get the parent node of branch on the BPT tree graph if it exists
	
	Params:
		graph(Dictionary): The graph we are searching in
		branch(Rect2): The branch whos parent we are looking for
	Returns:
		Rect2	
	"""

	for k in bpt_graph.keys():
		if bpt_graph[k].has(branch):
			return k


func get_sibling(bpt_graph: Dictionary, branch: Rect2):
	"""
	get the sibling of a branch on the BPT tree graph
	
	Params:
		graph(Dictionary): The graph we are searching in
		branch(Rect2): The branch whos parent we are looking for
	Returns:
		Rect2	
	"""
	var parent = get_parent_node(bpt_graph, branch)
	for c in bpt_graph[parent]:
		if c != branch:
			return c

func _run_tests():
	_test_get_children()
	_test_get_parent_node()
	_test_get_sibling()

func _test_get_sibling():
	var bpt_graph = {
		Rect2(Vector2(1,1), Vector2(1,1)): [
			Rect2(Vector2(2,2), Vector2(1,1)),
			Rect2(Vector2(3,3), Vector2(1,1))
		],
		Rect2(Vector2(2,2), Vector2(1,1)): [
			Rect2(Vector2(4,4), Vector2(1,1)),
			Rect2(Vector2(5,5), Vector2(1,1))
		],
		Rect2(Vector2(3,3), Vector2(1,1)): [],
		Rect2(Vector2(4,4), Vector2(1,1)): [],
		Rect2(Vector2(5,5), Vector2(1,1)): [],
	}
	var sibling = get_sibling(bpt_graph, Rect2(Vector2(3,3), Vector2(1,1)))
	var message = "Expected {a}, got {b}"
	assert(
		sibling == Rect2(Vector2(2,2), Vector2(1,1)), 
		message.format({"a": Rect2(Vector2(2,2), Vector2(1,1)), "b": sibling})
	)

func _test_get_parent_node():
	var bpt_graph = {
		Rect2(Vector2(1,1), Vector2(1,1)): [
			Rect2(Vector2(2,2), Vector2(1,1)),
			Rect2(Vector2(3,3), Vector2(1,1))
		],
		Rect2(Vector2(2,2), Vector2(1,1)): [
			Rect2(Vector2(4,4), Vector2(1,1)),
			Rect2(Vector2(5,5), Vector2(1,1))
		],
		Rect2(Vector2(3,3), Vector2(1,1)): [],
		Rect2(Vector2(4,4), Vector2(1,1)): [],
		Rect2(Vector2(5,5), Vector2(1,1)): [],
	}
	var parent: Rect2 = get_parent_node(bpt_graph, Rect2(Vector2(5,5), Vector2(1,1)))
	var message = "Expected {a}, got {b}"
	assert(
		parent == Rect2(Vector2(2,2), Vector2(1,1)), 
		message.format({"a": Rect2(Vector2(2,2), Vector2(1,1)), "b": parent})
	)


func _test_get_children():
	var bpt_graph = {
		Rect2(Vector2(1,1), Vector2(1,1)): [
			Rect2(Vector2(2,2), Vector2(1,1)),
			Rect2(Vector2(3,3), Vector2(1,1))
		],
		Rect2(Vector2(2,2), Vector2(1,1)): [
			Rect2(Vector2(4,4), Vector2(1,1)),
			Rect2(Vector2(5,5), Vector2(1,1))
		],
		Rect2(Vector2(3,3), Vector2(1,1)): [],
		Rect2(Vector2(4,4), Vector2(1,1)): [],
		Rect2(Vector2(5,5), Vector2(1,1)): [],
	}

	var list = get_leaf_nodes(bpt_graph, Rect2(Vector2(1,1), Vector2(1,1)))
	var expected_list = [
		Rect2(Vector2(3,3), Vector2(1,1)),
		Rect2(Vector2(4,4), Vector2(1,1)),
		Rect2(Vector2(5,5), Vector2(1,1))
	]
	var message = "Expected [{a}], got {d}"
	var formatted_message = message.format({"a":expected_list, "d": list})
	assert(list.sort() == expected_list.sort(), formatted_message)

	# test leaf node returns itself if has no children
	var only_leaf = get_leaf_nodes(bpt_graph, Rect2(Vector2(5,5), Vector2(1,1)))
	var formatted_message2 = message.format({"a":expected_list, "d": list})
	assert(only_leaf == [Rect2(Vector2(5,5), Vector2(1,1))], formatted_message2)
