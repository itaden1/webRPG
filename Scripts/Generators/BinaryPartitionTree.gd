extends Node


var graph: Dictionary
var rects: Array

func partition_rect(
	rect: Rect2, 
	max_partitions: int, 
	max_room_size: int,
	min_room_size: int,
	padding: Array = [],
	current_partition: int = 0
):

	graph[rect] = []

	if current_partition >= max_partitions:
		rects.append(rect)
		return

	var partition_directions = ["v", "h"]
	var direction = partition_directions[Rng.get_random_range(0,1)]
	
	if direction == "v":
		var left_partition_width = Rng.get_random_range(min_room_size, rect.size.x - min_room_size)
		var right_partition_width = rect.size.x - left_partition_width
		var new_rect_1 = Rect2(Vector2(rect.position.x, rect.position.y), Vector2(left_partition_width, rect.size.y))
		var new_rect_2 = Rect2(Vector2(rect.size.x - right_partition_width, rect.position.y), Vector2(right_partition_width, rect.size.y))

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
		var top_partition_height = Rng.get_random_range(min_room_size, rect.size.y - min_room_size)
		var bottom_partition_height = rect.size.y - top_partition_height
		var new_rect_1 = Rect2(Vector2(rect.position.x, rect.position.y), Vector2(rect.size.x, top_partition_height))
		var new_rect_2 = Rect2(Vector2(rect.position.x, rect.size.y - bottom_partition_height), Vector2(bottom_partition_height, rect.size.y))

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

