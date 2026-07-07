extends RefCounted
class_name MapGenerator

static func generate() -> Array:
	var floor_layouts := [
		[
			{"lane": -1.0, "type": "normal"},
			{"lane": 0.0, "type": "normal"},
			{"lane": 1.0, "type": "normal"}
		],
		[
			{"lane": -0.6, "type": "normal"},
			{"lane": 0.8, "type": "event"}
		],
		[
			{"lane": -1.1, "type": "normal"},
			{"lane": 0.0, "type": "elite"},
			{"lane": 1.1, "type": "shop"}
		],
		[
			{"lane": -0.7, "type": "event"},
			{"lane": 0.0, "type": "treasure"},
			{"lane": 0.7, "type": "elite"}
		],
		[
			{"lane": -1.0, "type": "elite"},
			{"lane": 0.0, "type": "rest"},
			{"lane": 1.0, "type": "normal"}
		],
		[
			{"lane": -0.55, "type": "elite"},
			{"lane": 0.55, "type": "event"}
		],
		[
			{"lane": 0.0, "type": "boss"}
		]
	]

	var nodes: Array = []
	for floor_index in range(floor_layouts.size()):
		var floor_nodes: Array = floor_layouts[floor_index]
		for node_index in range(floor_nodes.size()):
			var spec: Dictionary = floor_nodes[node_index]
			var node_type := str(spec.get("type", "normal"))
			nodes.append({
				"id": "f%d_%d" % [floor_index, node_index],
				"floor": floor_index,
				"lane": float(spec.get("lane", 0.0)),
				"type": node_type,
				"title": _title_for_type(node_type),
				"next": []
			})

	for i in range(nodes.size()):
		var node: Dictionary = nodes[i]
		var floor := int(node.get("floor", 0))
		if floor >= floor_layouts.size() - 1:
			continue
		node["next"] = _connections_for_node(node, _nodes_on_floor(nodes, floor + 1))
		nodes[i] = node

	return nodes

static func _nodes_on_floor(nodes: Array, floor: int) -> Array:
	var result: Array = []
	for node in nodes:
		if int(node.get("floor", 0)) == floor:
			result.append(node)
	return result

static func _connections_for_node(node: Dictionary, next_nodes: Array) -> Array:
	var result: Array = []
	var lane := float(node.get("lane", 0.0))
	for next_node in next_nodes:
		if abs(float(next_node.get("lane", 0.0)) - lane) <= 1.15:
			result.append(str(next_node.get("id", "")))
	if result.is_empty() and not next_nodes.is_empty():
		var nearest: Dictionary = next_nodes[0]
		var nearest_distance: float = abs(float(nearest.get("lane", 0.0)) - lane)
		for next_node in next_nodes:
			var distance: float = abs(float(next_node.get("lane", 0.0)) - lane)
			if distance < nearest_distance:
				nearest = next_node
				nearest_distance = distance
		result.append(str(nearest.get("id", "")))
	return result

static func _title_for_type(node_type: String) -> String:
	match node_type:
		"elite":
			return "精英"
		"boss":
			return "首领"
		"event":
			return "事件"
		"treasure":
			return "宝箱"
		"shop":
			return "坊市"
		"rest":
			return "休息"
	return "战斗"
